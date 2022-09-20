@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
goto SET_GLOBALS

:DSPHELP
echo Created by Rory Hewitt
echo.
echo rhewitt@akamai.com
echo ========================================================================
echo This utility allows you to determine the current DNS entries for a given
echo domain, when attempting to access the Akamai Edge Staging Network (ESN).
echo.
echo You may pass parameters to this utility in any order, by passing each
echo parameter with an immediately preceding 'flag', e.g.:
echo.
echo    stagingcheck.bat -d example.com -s www_m_ftp_api
echo.
echo Valid parameter flags and their associated values are as follows:
echo.
echo   -d   Domain (without subdomain), e.g. example.com
echo   -s   Subdomains (separated by underscores), e.g. www_m_api
echo   -h   Display this help text
echo   -b   Return value (batch)
echo.
echo If you do not pass all required parameters, you will be prompted to
echo enter values for them. In most cases, a default value will be
echo displayed in parentheses following the prompt text, e.g.
echo.
echo "Specify subdomain (Default: '(www m)'):"
echo.
echo If you press Enter without entering a value, the default value
echo will be used.
echo.
echo The current default values in use by dnscheck are as follows:
echo.
echo    Domain: %dft_domain%
echo    Subdomains: %dft_subdomains%
echo.
goto EXIT

:SET_GLOBALS
set domain=
set subdomains=
set batchdft=no
set batch=%batchdft%
set dft_domain=example.com
set dft_subdomains=(www)

echo ==================================================
echo DNS lookup utility for Akamai Edge Staging Network
echo ==================================================
echo.

:PROCESS_PARMS
if "%1" == ""   goto CHECK_OVERRIDES
if "%1" == "-d" set domain=%2
if "%1" == "-s" set subdomains=%2
if "%1" == "-h" goto DSPHELP
if "%1" == "-b" set batch=%2
shift
shift
goto PROCESS_PARMS

:CHECK_OVERRIDES
if "%domain%" == ""     set /p domain=Specify domain WITHOUT subdomain (Default: %dft_domain%):
if "%domain%" == ""     set domain=%dft_domain%
if "%subdomains%" == "" set /p subdomains=Specify subdomain(s) (Default: %dft_subdomains%):
if "%subdomains%" == "" set subdomains=%dft_subdomains%

REM Convert underscores in subdomains argument value to blanks
set subdomains=%subdomains:_= %
REM Remove and re-add surrounding parentheses
set subdomains=%subdomains:(=%
set subdomains=%subdomains:)=%
set subdomains=(%subdomains%)

REM Process all the domains
:PROCESS_DOMAIN

FOR %%S IN %subdomains% DO (
    set outstring=""
    set akamaiedge=""
    set done=0
    set firstline=1
    REM First pass to get the name of the Akamai Edge Hostname
    for /f "tokens=5" %%A in ('dig +noall +answer %%S.!domain!') do (
        if !firstline! == 1 (
            set firstline=0
            REM Check if the domain is CNAMEd directly to edgekey.net or edgesuite.net
            set akamaiedge=%%A
            set dummy1=!akamaiedge:edge=xxxx!
            set dummy2=!akamaiedge!
            if !dummy1! == !dummy2! (
                REM It's not CNAMEd to Akamai, so check if it's using FastDNS. If so,
                REM try the next dig line. If not, throw an error message and display
                REM the entire dig response...
                set dummy1=!akamaiedge:akadns=xxxxxx!
                set dummy2=!akamaiedge!
                if !dummy1! == !dummy2! (
                    REM Second check for FastDNS
                    for /f "tokens=5" %%B in ('dig +noall +answer +auth -x %%A') do (
                        set akamaiedge=%%B
                        set dummy1=!akamaiedge:deploy.static.akamaitechnologies.com=xxxxxx!
                        set dummy2=!akamaiedge!
                        if not !dummy1! == !dummy2! (
                            if not !batch! == !batchdft! (
                                return ""
                            )
                            echo # %%S.!domain! uses Akamai FastDNS.
                            goto EXIT
                        )
                    )
                    if not !batch! == !batchdft! (
                        return ""
                    )
                    echo # %%S.!domain! is not CNAMEd to Akamai
                    echo.
                    dig +noall +answer %%S.!domain!
                    goto EXIT
                )
                set firstline=1
            )
        )
    )
    REM No record for the specified subdomain
    if "!akamaiedge!" == "" (
        if not !batch! == !batchdft! (
            return ""
        )
        echo # No DNS entry found for %%S.!domain!
        set done=1
    )
    if !done! == 0 (
        set akamaiedge=!akamaiedge:edgesuite.net=edgesuite-staging.net!
        set akamaiedge=!akamaiedge:edgekey.net=edgekey-staging.net!
        for /f "tokens=5" %%X in ('dig +noall +answer !akamaiedge!') do @set ipaddress=%%X
        if not !batch! == !batchdft! (
            return !ipaddress!
        )
        echo.
	echo === Copy the line below into your Hosts file ===
	echo.
	REM echo #---- Staging IP addresses for %domain% (%DATE% %TIME%)
        echo !ipaddress!	%%S.!domain!		# !akamaiedge!	%DATE% %TIME%
        goto FLUSH
    )
)

echo.
echo.
goto EXIT

:FLUSH
ipconfig /flushdns

:EXIT

ENDLOCAL