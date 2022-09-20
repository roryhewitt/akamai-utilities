@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
goto SET_PARM_DEFAULTS

REM Display help
:DSPHELP
echo Created by Rory Hewitt
echo.
echo rhewitt@akamai.com
echo ==============================================================================
echo This utility allows you to determine the current DNS entries for
echo one or more domains.
echo.
echo You may pass parameters to this utility in any order, by passing each
echo parameter with an immediately preceding 'flag', e.g.:
echo.
echo    -d example.com -s www_ftp -f dns_report -n no
echo.
echo Valid parameter flags are as follows:
echo.
echo   -d   Domain name, without subdomain (e.g. example.com)
echo   -s   Subdomain(s), separated by underscores (e.g. www_m_api)
echo   -n   Use authoritative nameserver (yes or no)
echo   -o   Output to separate file (yes or no)
echo   -h   Display this help text
echo.
echo If you do not pass all required parameters, you will be prompted to
echo enter values for them. In most cases, a default value will be
echo displayed in parentheses following the prompt text, e.g.
echo.
echo "Specify domain WITHOUT subdomain (Default: example.com):"
echo.
echo If you press Enter without entering a value, the default value
echo will be used.
echo.
echo The current default values in use by dnscheck are as follows:
echo.
echo    Subdomains: %dft_subdomains%
echo    Use authoritative nameserver: %dft_usenameserver%
echo    Output to separate file: %dft_outputtofile%
echo.
echo If you specify 'yes' to the authoritative nameserver option, only the first
echo DNS CNAME will be output. If you select 'no', the entire DNS chain including
echo any intermediate CNAMEs, right down to the IP address will be output.
echo.
goto EXIT

:SET_PARM_DEFAULTS
set domain=
set subdomains=
set usenameserver=
set outputtofile=
set dft_subdomains=(www m)
set dft_usenameserver=no
set dft_outputtofile=yes
set nameserver=@8.8.8.8

echo ==================
echo DNS lookup utility
echo ==================
echo.

:PROCESS_PARMS
if "%1" == ""   goto CHECK_OVERRIDES
if "%1" == "-d" set domain=%2
if "%1" == "-s" set subdomains=%2
if "%1" == "-n" set usenameserver=%2
if "%1" == "-o" set outputtofile=%2
if "%1" == "-h" goto DSPHELP
shift
shift
goto PROCESS_PARMS

:CHECK_OVERRIDES
if "%domain%" == ""         set /p domain=Specify domain WITHOUT subdomain (e.g. example.com):
if "%domain%" == ""         goto CHECK_OVERRIDES
if "%subdomains%" == ""     set /p subdomains=Specify one or more blank-separated subdomains (e.g. 'www m'):
if "%subdomains%" == ""     set subdomains=%dft_subdomains%
if "%usenameserver%" == ""  set /p usenameserver=Use authoritative nameserver? (Values: yes or no. Default value: '%dft_usenameserver%'):
if "%usenameserver%" == ""  set usenameserver=%dft_usenameserver%
if "%outputtofile%" == ""  set /p outputtofile=Output to file? (Values: yes or no. Default value: '%dft_outputtofile%'):
if "%outputtofile%" == ""  set outputtofile=%dft_outputtofile%

REM Convert underscores in subdomains argument value to blanks
set subdomains=%subdomains:_= %
REM Remove and re-add surrounding parentheses
set subdomains=%subdomains:(=%
set subdomains=%subdomains:)=%
set subdomains=(%subdomains%)

REM Get first authoritative nameserver
if "%usenameserver%" == "yes" (
    set nameserver=
    for /f "tokens=5" %%A in ('dig +noall +auth !domain! @l.gtld-servers.net.') do (
        if "!nameserver!"=="" (
            set nameserver=%%A
        )
    )
    echo.
    echo Using nameserver %nameserver%...
    echo.
)

set date_suffix=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%

set outputfile="&2"
if "%outputtofile%" == "yes" (
    set outputfile=C:\Temp\dsncheck-%domain%-%date_suffix%.output
)
goto PROCESS_DOMAINS

REM Process all the domains
:PROCESS_DOMAINS
echo DNS report for %domain% > %outputfile%
echo. >> %outputfile%
echo Date: %DATE% >> %outputfile%
echo Time: %TIME% >> %outputfile%
if "%usenameserver%" == "yes" (
    echo Using authoritative nameserver %nameserver% >> %outputfile%
    echo. >> %outputfile%
    set nameserver=@%nameserver%
)
echo Subdomains: %subdomains% >> %outputfile%

if "%outputtofile%" == "yes" (
    echo.
    echo Processing subdomains for %domain%...
)
echo. >> %outputfile%
echo ===================================== >> %outputfile%
echo Subdomains for %domain% >> %outputfile%
echo ===================================== >> %outputfile%
echo. >> %outputfile%

FOR %%B IN %subdomains% DO (
    set fqdn=%%B.%domain%
    if "%outputtofile%" == "yes" (
        echo Processing !fqdn!...
    )
    set outstring=""
    set done=0
    for /f "delims=" %%a in ('dig +noall +answer !fqdn! !nameserver!') do @set outstring=%%a
    if !outstring! == "" (
        set done=1
        set outstring=   *** No entry for %%B.!domain! ***
        echo !outstring! >> %outputfile%
    )
    if !done! == 0 (
        dig +noall +answer !fqdn! !nameserver! >> %outputfile%
    )
    echo. >> %outputfile%
)

if "%outputtofile%" == "yes" (
    echo.
    echo DNS report output to %outputfile%...
    echo.
)
goto EXIT

:EXIT

pause
ENDLOCAL
