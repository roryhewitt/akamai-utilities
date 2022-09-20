@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
goto INIT

REM Display help
:DSPHELP
echo.
echo akacurl v3.0
echo.
echo Created by Rory Hewitt
echo.
echo rhewitt@akamai.com
echo ==============================================================================
echo THIS UTILITY IS PROVIDED AS-IS, WITH NO GUARANTEES AS TO ITS FUNCTIONALITY OR
echo USEFULNESS. IT IS NOT PROVIDED BY AKAMAI TECHNOLOGIES AS AN OFFICIAL PRODUCT
echo AND THEY ARE NOT RESPONSIBLE FOR ITS CONTENT. IF YOU HAVE ANY PROBLEMS WITH
echo IT, PLEASE CONATCT ME DIRECTLY AT RHEWITT@AKAMAI.COM. THANKS! RORY.
echo ==============================================================================
echo This utility allows you to run the curl command using standard default values
echo for Akamai debugging.
echo.
echo    akacurl {url} [options...]
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
echo    akacurl www.example.com -# c:/temp/output.txt -r 3 -a cache -u iphone -L
echo.
echo Some flags (-L, -i etc.) do not have an associated value.
echo.
echo Valid options are as follows:
echo.
echo   -#   Output file to direct response to. Specifying a value here means that
echo        request headers and response headers will be sent to that file rather
echo        than to the screen.
echo.
echo   -D   Output file to dump reponse headers to. Note that response headers
echo        will also display in the console.
echo.
echo   -L   Whether to follow redirects. This flag has no associated option value.
echo.
echo   -r   Number of times to repeat the curl command. The default is 1.
echo.
echo   -a   Which Akamai response headers to return. Valid values are:
echo           'all'    All Akamai response headers are returned
echo           'noinfo' Same as 'all', except X-Akamai-Session-Info response headers
echo                    are not returned.
echo           'cache'  Only cache key-related response headers are specified
echo           'none'   No Akamai response headers are returned.
echo        The default is 'all'.
echo.
echo   -u   User-Agent string to pass. Valid values are:
echo           'chrome'    The User-Agent request header will identify the request as
echo                       coming from a Chrome browser running on Windows
echo           'iphone'    The User-Agent request header will identify the request as
echo                       coming from an iPhone
echo           'ipad'      The User-Agent request header will identify the request as
echo                       coming from an iPad
echo           'firefox'   The User-Agent request header will identify the request as
echo                       coming from a Firefox browser running on Windows
echo           'ie11'      The User-Agent request header will identify the request as
echo                       coming from an Internet Explorer 11 browser
echo           'opera'     The User-Agent request header will identify the request as
echo                       coming from an Opera browser
echo           'googlebot' The User-Agent request header will identify the request as
echo                       coming from Googlebot Crawler
echo           'ais'       The User-Agent request header will identify the request as
echo                       coming from an Akamai Image Server
echo           'bingbot'   The User-Agent request header will identify the request as
echo                       coming from BingBot crawler
echo           'im'        The User-Agent request header will identify the request as
echo                       coming from Akamai's Image Manager
echo.
echo        The default is to use the 'chrome' value.
echo.
echo   -O   Defines the value of the Origin request header to pass (if any). This must
echo        include the scheme as well as the domain, e.g.:
echo           -O http://www.google.com
echo.
echo   -s   Specifies whether an override to the Staging network should be used. The
echo        related value should be specified as
echo           {host-name}:{port}:{staging-ip-address}
echo.
echo   -o   Specifies where the output should go. Valid values are:
echo           'NUL'   The output will not be displayed or saved
echo           '-'      The output will be displayed on the screen
echo           location A file with optional folder, e.g. 'c:\temp\myoutput.txt'
echo        The default is to use 'NUL'.
echo.
echo   -*   Displays a prompt where you can specify further parameters as a string.
echo        This flag has no associated option value.
echo.
echo   -i   Displays information about the request, including timing values.
echo        This flag has no associated option value.
echo.
echo   -x   Don't run the curl command, just display the entire curl command with all
echo        parameters, for use by people without the akacurl tool :) This flag has no
echo        associated option value.
echo.
echo   -sr  Run this as a SRTO request, by passing X-Akamai-TestObject: true. This
echo        flag has no associated option value.
echo.
echo You may also pass '-h' in place of {url}. This will display this help text and
echo then exit, e.g.:
echo.
echo    akacurl -h
echo.
pause
goto EXIT

:INIT

:SETDFTPARMS
REM Set user-specific defaults (can be changed if you want)
set dftrepeat=1
set dftuseragent=chrome
set dftoutput=-o NUL
set dftakamai=all

REM Initialize global strings (don't change these!)
set noparms=false
set output=
set akamai_cache=akamai-x-get-request-id,akamai-x-cache-on,akamai-x-cache-remote-on,akamai-x-check-cacheable,akamai-x-get-cache-key,akamai-x-get-true-cache-key,akamai-x-get-cache-tags
set akamai_noinfo=akamai-x-get-ssl-client-session-id,akamai-x-serial-no
set useragent_chrome=Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.84 Safari/537.36
set useragent_iphone=Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1
set useragent_ipad=Mozilla/5.0 (iPad; CPU OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1
set useragent_firefox=Mozilla/5.0 (Windows NT 6.1; WOW64; rv:46.0) Gecko/20100101 Firefox/46.0
set useragent_ie11=Mozilla/5.0 (IE 11.0; Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko
set useragent_opera=Opera/9.80 (Windows NT 6.2; WOW64) Presto/2.12.388 Version/12.11
set useragent_googlebot=Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
set useragent_ais=Mozilla/5.0 (X11; U; Linux x86_64; en-US) AkamaiImageServer VelocitudeMP/1.0;IM/1.0
set useragent_bingbot=Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
set useragent_im=AkamaiImageServer
set outputparm=%dftoutput%
set useragentparm=%useragent_chrome%
set akamaiparm=%akamai_all%
set redirectsparm=
set headersparm=
set outputfile="&2"
set originparm=
set otherparms=
set moreparms=
set staging=
set stagingparm=
set info=
set infoparm=
set infofile=%~dp0curl-timing.txt
set norun=no
set srto=no
set srtoparm=

set url=%1
if "%url%" == "" set noparms=true

:CHECK_URL
if "%url%" == ""         set /p url=Specify URL (or type '-q' to quit or '-h' to view help):
if "%url%" == "*URL"     set /p url=Specify URL:
if "%url%" == ""         goto CHECK_URL
if "%url%" == "-h"       goto DSPHELP
if "%url%" == "-q"       goto EXIT
if "%url%" == "-x"  (
    set norun=yes
    set url=
    goto OVERRIDES
)
if "%noparms%" == "true" goto PROMPTPARMS
goto GETPARMS

:PROMPTPARMS
set /p outputfile=Specify output file (leave blank to output to console):
set /p output=Specify response output file (leave blank to hide response):
set /p repeat=Specify how many times to repeat the request (default: %dftrepeat%):
set /p akamai=Specify which Akamai headers to pass (all, none, cache or noinfo):
set /p useragent=Specify which User-Agent to simulate (chrome, iphone, ipad or leave blank for default):
set /p headers=Specify output to dump headers to (leave blank to output to console):
set /p redirects=Specify whether to follow redirects (yes or no) or use default value of no:
set /p origin=Specify whether to pass an Origin header and what value to use:
set /p staging=Specify whether to point to Staging:
set moreparms=yes

goto OVERRIDES

:GETPARMS
if "%2" == ""   goto OVERRIDES
if "%2" == "-*" set moreparms=yes
if "%2" == "-i" set info=yes
if "%2" == "-x" set norun=yes
if "%2" == "-L" set redirects=yes
if "%2" == "-sr" set srto=yes
if "%2" == "-s" (
    set staging=%3
    shift
)
if "%2" == "-#" (
    set outputfile=%3
    shift
)
if "%2" == "-o" (
    set output=%3
    shift
)
if "%2" == "-r" (
    set repeat=%3
    shift
)
if "%2" == "-a" (
    set akamai=%3
    shift
)
if "%2" == "-u" (
    set useragent=%3
    shift
)
if "%2" == "-D" (
    set headers=%3
    shift
)
if "%2" == "-O" (
    set origin=%3
    shift
)
shift
goto GETPARMS

:OVERRIDES
REM Use default akamai header value if user didn't specify one
if "%akamai%" == ""             set akamai=%dftakamai%
if "%akamai%" == "cache"        set akamaiparm=-H "Pragma: %akamai_cache%"
if "%akamai%" == "noinfo"       set akamaiparm=-H "Pragma: %akamai_cache%,%akamai_noinfo%"
if "%akamai%" == "all"          set akamaiparm=-H "Pragma: %akamai_cache%,%akamai_noinfo%,akamai-x-get-extracted-values"
if "%akamai%" == "none"         set akamaiparm=

REM Use default user agent value if user didn't specify one
if "%useragent%" == ""          set useragent=%dftuseragent%
if "%useragent%" == "chrome"    set useragentparm=-H "User-Agent: %useragent_chrome%"
if "%useragent%" == "iphone"    set useragentparm=-H "User-Agent: %useragent_iphone%"
if "%useragent%" == "ipad"      set useragentparm=-H "User-Agent: %useragent_ipad%"
if "%useragent%" == "firefox"   set useragentparm=-H "User-Agent: %useragent_firefox%"
if "%useragent%" == "ie11"      set useragentparm=-H "User-Agent: %useragent_ie11%"
if "%useragent%" == "opera"     set useragentparm=-H "User-Agent: %useragent_opera%"
if "%useragent%" == "googlebot" set useragentparm=-H "User-Agent: %useragent_googlebot%"
if "%useragent%" == "ais"       set useragentparm=-H "User-Agent: %useragent_ais%"
if "%useragent%" == "bingbot"   set useragentparm=-H "User-Agent: %useragent_bingbot%"
if "%useragent%" == "im"        set useragentparm=-H "User-Agent: %useragent_im%"

REM Set assorted options
if not "%headers%" == ""        set headersparm=-D %headers%
if "%repeat%" == ""             set repeat=%dftrepeat%
if "%redirects%" == "yes"       set redirectsparm=-L -c %USERPROFILE%\$nul-cookies
if not "%origin%" == ""         set originparm=-H "Origin: %origin%" -H "Access-Control-Request-Method: GET"
if not "%output%" == ""         set outputparm=-o %output%
if "%output%" == "*"            set outputparm=
if "%output%" == "-"            set outputparm=
if "%moreparms%" == "yes"       set /p otherparms=Enter other parameters:
REM if "%info%" == "yes"            set infoparm=-w "\n\tResponse code: %%{http_code}\n\n\tRequest size:         %%{size_request}\n\tResponse header size: %%{size_header}\n\tTotal response size:  %%{size_download}\n\n\ttime_namelookup:    %%{time_namelookup}\n\ttime_connect:       %%{time_connect}\n\ttime_appconnect:    %%{time_appconnect}\n\ttime_pretransfer:   %%{time_pretransfer}\n\ttime_redirect:      %%{time_redirect}\n\ttime_starttransfer: %%{time_starttransfer}\n\t----------\n\ttime_total:         %%{time_total}\n\n"
if "%info%" == "yes"            set infoparm=-w @%infofile%
if not "%staging%" == ""        set stagingparm=--connect-to ::%staging%
if "%srto%" == "yes"            set srtoparm=-H "X-Akamai-TestObject: true"

goto SET_CURL

:SET_CURL
REM By default, this curl command includes the following flags:
REM    -v Verbose - Make the operation more talkative
REM    -s Silent - Silent mode (don't output anything)
REM    -k Insecure - Allow connections to SSL sites without certs
REM    -i Include - Include protocol headers in the output
REM    -o NUL - Output the response body to 'nul'

set akacurlcommand=akacurl %url% -a %akamai% -u %useragent% -r %repeat% -s %staging% -# %outputfile%

set curlcommand=curl -vvvv -k %infoparm% %outputparm% %redirectsparm% %headersparm% -H "Accept-Language: en-US" -H "Cache-Control: dummy" %useragentparm% %akamaiparm% %originparm% %otherparms% %stagingparm% %srtoparm% %url%

:RUN_CURL
REM Add info to top of output file
if not %outputfile% == "&2" (
    echo Command: %akacurlcommand% >%outputfile%
    echo. >>%outputfile%
)

echo ========== >>%outputfile%
if %repeat% gtr 1 (
    echo Repeating %repeat% times: >>%outputfile%
    echo Beginning %repeat% requests...
    echo.
)
echo %curlcommand% >>%outputfile%
echo ========== >>%outputfile%
echo off
if "%norun%" == "yes" goto EXIT
FOR /L %%A IN (1,1,%repeat%) DO (
    echo. >>%outputfile%
    if %repeat% gtr 1 (
        echo =========== >>%outputfile%
        echo Request: %%A >>%outputfile%
        echo =========== >>%outputfile%
    )
    if %outputfile% == "&2" (
        %curlcommand%
    )
    if not %outputfile% == "&2" (
        if %repeat% gtr 1 (
            echo Processing request %%A...
        )
        %curlcommand% 2>>%outputfile%
    )
)
if not %outputfile% == "&2" (
    if %repeat% gtr 1 (
        echo.
        echo %repeat% requests completed. Results are available in "%outputfile%"...
    )
)

echo.
REM pause
:EXIT

ENDLOCAL