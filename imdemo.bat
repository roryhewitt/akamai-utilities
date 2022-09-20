@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
goto INIT

REM Display help
:DSPHELP
echo.
echo imdemo v1.0 (2020-11-11)
echo.
echo Created by Rory Hewitt (rhewitt@akamai.com)
echo.
echo ==============================================================================
echo THIS UTILITY IS PROVIDED AS-IS, WITH NO GUARANTEES AS TO ITS FUNCTIONALITY OR
echo USEFULNESS. IT IS NOT PROVIDED BY AKAMAI TECHNOLOGIES AS AN OFFICIAL PRODUCT
echo AND THEY ARE NOT RESPONSIBLE FOR ITS CONTENT. IF YOU HAVE ANY PROBLEMS WITH
echo IT, PLEASE CONTACT ME DIRECTLY AT RHEWITT@AKAMAI.COM. THANKS! RORY.
echo ==============================================================================
echo This utility allows you to run the curl command against an image (JPEG, GIF or
echo PNG) to see what benefits IM will provide.
echo.
echo    imdemo {parameters}
echo.
echo If you do not specify any parameters, you will be prompted to enter a URL, and
echo any options.
echo.
echo If the URL contains query parameters, you should pass a value of '*URL' and you
echo will be prompted to enter the full URL.
echo.
echo You may pass options in any order, by passing each option with an immediately
echo preceding flag, e.g.:
echo.
echo    imdemo {url} --domain www.example.com --quality mh --useragent chrome
echo.
echo Valid options are as follows:
echo.
echo   --url [image url] - note that if the URL is the first parameter , the --url flag is not required
echo.
echo   --domain [image domain]
echo.
echo   --quality [image quality - one of the following: 'l', 'ml', 'm', 'mh' or 'h']
echo.
echo   --useragent ['chrome', 'safari' or 'edge']
echo.
echo You may also pass '-h' in place of {url}. This will display this help text and
echo then exit, e.g.:
echo.
echo    imdemo -h
echo.
pause
goto EXIT

REM echo %var%|findstr /r "^[a-z][a-z]$ ^[a-z][a-z][a-z]$"
REM sed

:INIT

set url=%1

:CHECK_URL
if "%url%" == "--url" (
    set url=%2
    shift
)
if "%url%" == ""   set /p url=Specify URL (or type '-q' to quit or '-h' to view help):
if "%url%" == ""   goto CHECK_URL
if "%url%" == "-h" goto DSPHELP
if "%url%" == "-q" goto EXIT
goto GETPARMS

:GETPARMS
if "%2" == ""   goto OVERRIDES
if "%2" == "--domain" (
    set domain=%3
    shift
)
if "%2" == "--quality" (
    set quality=%3
    shift
)
if "%2" == "--useragent" (
    set useragent=%3
    shift
)
shift
goto GETPARMS

:OVERRIDES

if "%domain%" == ""    set /p domain=Enter image domain:
if "%domain%" == ""    goto OVERRIDES

if "%quality%" == ""   set /p quality=Enter image quality (l, ml, m, mh or h (Default:mh)):
if "%quality%" == ""   set quality=mediumHighpq

if "%useragent%" == ""   set /p useragent=Enter User Agent (chrome, safari, edge (Default: chrome)):
if "%useragent%" == ""   set useragent=chrome


if "%quality%" == "l"  set quality=lowpq
if "%quality%" == "ml" set quality=mediumLowpq
if "%quality%" == "m"  set quality=mediumpq
if "%quality%" == "mh" set quality=mediumHighpq
if "%quality%" == "h"  set quality=highpq

if "%useragent%" == "chrome" set useragent=Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.84 Safari/537.36
if "%useragent%" == "safari" set useragent=Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1
if "%useragent%" == "edge"   set useragent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134

:RUNCURL
set curlstmt=curl -vvvv -k -o NUL %url% -H "x-host: %domain%" -H "Pragma: akamai-x-ro-trace" -H "x-akamai-a2-disable: on" -H "x-akamai-ro-piez: on" -H "x-im-piez: on" -H "Cookie: im-demo=on" -H "improxy-pq: %quality%" --connect-to ::personal-improxy.web.akamaidemo.com -H "Host: personal-improxy.web.akamaidemo.com" -H "User-Agent: %useragent%"

%curlstmt%

echo.

REM pause
:EXIT

ENDLOCAL