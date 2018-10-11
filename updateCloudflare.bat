@echo off
REM Script to update DNS with cloudflare
REM Version 1.0
REM Requires CURL for windows exe and dll https://curl.haxx.se/download.html
REM Tested with CURL version 7.61.1
REM Sets the date in form YYYYMMDD
SET MYDATE=%date:~-4%%date:~7,2%%date:~4,2%

REM **********USER INPUTS**************
REM Cloudflare account email eg addr@domain.com
SET EMAIL="X-Auth-Email:INPUTACCOUNTEMAILHERE"
REM Cloudflare API key (under my Profile) eg 94ac73425e00ee566662c159ab1c0067
SET APIKEY="X-Auth-Key:INPUTAPIKEYHERE"
REM Domain eg domain.com
SET DOMAIN=INPUTDOMAINHERE
REM DNS record you want to update eg mail.domain.com
SET DNSRECORD=INPUTDNSRECORDHERE
REM DNS zone ID eg 94ac73425e00ee566662c159ab1c0067, retrieve using 
REM curl -X GET "https://api.cloudflare.com/client/v4/zones?name=%DOMAIN%" -H %EMAIL% -H %APIKEY% -H "Content-Type:application/json" 
SET ZONEID=INPUTZONEIDHERE
REM DNS record ID, eg 94ac73425e00ee566662c159ab1c0067, retrieve using 
REM curl -X GET "https://api.cloudflare.com/client/v4/zones/%ZONEID%/dns_records?name=%DNSRECORD%" -H %EMAIL% -H %APIKEY% -H "Content-Type:application/json" 
SET DNSRECORDID=INPUTDNSRECORDIDHERE

REM **********END USER INPUTS**************

REM Sets the public ip address or if no public IP logs error and jumps to the end
SET /p OLDPUBIP=<temp.txt 
REM Alternate URL = http://ipinfo.io/ip
curl "http://myexternalip.com/raw" > temp.txt
SET /p NEWPUBIP=<temp.txt 
IF "%NEWPUBIP%"=="" (
  ECHO %MYDATE% %TIME% ERROR NO PUBLIC IP FOUND >> %MYDATE%UpdateCloudFlare.log
  ECHO: >> %MYDATE%UpdateCloudFlare.log
  GOTO :END
)

REM If public IP has changed, update A record
IF NOT [%NEWPUBIP%]==[%OLDPUBIP%] (
  ECHO %MYDATE% %TIME% Updating Cloudflare  >> %MYDATE%UpdateCloudFlare.log
  curl -X PUT "https://api.cloudflare.com/client/v4/zones/%ZONEID%/dns_records/%DNSRECORDID%" -H %EMAIL% -H %APIKEY% -H "Content-Type:application/json" --data "{\"type\":\"A\",\"name\":\"%DNSRECORD%\",\"content\":\"%NEWPUBIP%\",\"ttl\":300,\"proxied\":false}" >> %MYDATE%UpdateCloudFlare.log
  ECHO: >> %MYDATE%UpdateCloudFlare.log
  ECHO: >> %MYDATE%UpdateCloudFlare.log
  GOTO :END
)

REM Log if no change to public IP
ECHO %MYDATE% %TIME% No change to public IP, old %OLDPUBIP% new %NEWPUBIP% >> %MYDATE%UpdateCloudFlare.log
ECHO: >> %MYDATE%UpdateCloudFlare.log

:END