@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :props
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)
if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_CHECKSTYLE%==1 (
    call :checkstyle
    if not !_EXITCODE!==0 goto end
)
if %_COMPILE%==1 (
    call :compile
    if not !_EXITCODE!==0 goto end
    if %_TARGET%==native (
        call :native_image
        if not !_EXITCODE!==0 goto end
    )
)
if %_PACK%==1 (
    call :pack
    if not !_EXITCODE!==0 goto end
)
if %_RUN%==1 (
    call :run_%_TARGET%
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

set "_SOURCE_DIR=%_ROOT_DIR%src\main\java"
set "_TARGET_DIR=%_ROOT_DIR%target"
set "_CLASSES_DIR=%_TARGET_DIR%\classes"

set _PKG_NAME=
set _MAIN_NAME=CountUppercase
set "_MAIN_NATIVE_FILE=%_TARGET_DIR%\%_MAIN_NAME%"

set "_JAVAC_CMD=%JAVA_HOME%\bin\javac.exe"
set _JAVAC_OPTS=

set "_NATIVE_IMAGE_CMD=%JAVA_HOME%\bin\native-image.cmd"
set _NATIVE_IMAGE_OPTS=-cp "%_CLASSES_DIR%" --no-fallback

set "_GRAALVM_LOG_FILE=%_TARGET_DIR%\graal_log.txt"
set _GRAALVM_OPTS=-Dgraal.ShowConfiguration=info -Dgraal.PrintCompilation=true -Dgraal.LogFile=%_GRAALVM_LOG_FILE%

set "_JAVA_CMD=%JAVA_HOME%\bin\java.exe"
set _JAVA_OPTS=-cp "%_CLASSES_DIR%"

set "_JAR_CMD=%JAVA_HOME%\bin\jar.exe"
set _JAR_OPTS=
goto :eof

@rem output parameters: _CHECKSTYLE_VERSION
:props
@rem value may be overwritten if file build.properties exists
set _CHECKSTYLE_VERSION=8.33

set "__PROPS_FILE=%_ROOT_DIR%build.properties"
if exist "%__PROPS_FILE%" (
    for /f "tokens=1,* delims==" %%i in (%__PROPS_FILE%) do (
        for /f "delims= " %%n in ("%%i") do set __NAME=%%n
        @rem line comments start with "#"
        if not "!__NAME!"=="" if not "!__NAME:~0,1!"=="#" (
            @rem trim value
            for /f "tokens=*" %%v in ("%%~j") do set __VALUE=%%v
            set "_!__NAME:.=_!=!__VALUE!"
        )
    )
    if defined _checkstyle_version set _CHECKSTYLE_VERSION=!_checkstyle_version!
)
goto :eof

@rem input parameter %*
:args
set _CHECKSTYLE=0
set _CLEAN=0
set _COMPILE=0
set _HELP=0
set _JVMCI=0
set _PACK=0
set _RUN=0
set _TARGET=jvm
set _TIMER=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    @rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-jvmci" ( set _JVMCI=1
    ) else if /i "%__ARG%"=="-native" ( set _TARGET=native
    ) else if /i "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="check" ( set _CHECKSTYLE=1
    ) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="pack" ( set _COMPILE=1& set _PACK=1
    ) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto :args_loop
:args_done
set _STDOUT_REDIRECT=1^>CON
if %_DEBUG%==0 if %_VERBOSE%==0 set _STDOUT_REDIRECT=1^>NUL

if defined _PKG_NAME ( set _MAIN_CLASS=%_PKG_NAME%.%_MAIN_NAME%
) else ( set _MAIN_CLASS=%_MAIN_NAME%
)
set "_MAIN_NATIVE_FILE=%_TARGET_DIR%\%_MAIN_NAME%"

if %_DEBUG%==1 set _NATIVE_IMAGE_OPTS=-H:+TraceClassInitialization %_NATIVE_IMAGE_OPTS%

if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% _TARGET=%_TARGET% _TIMER=%_TIMER% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -debug      display commands executed by this script
echo     -jvmci      add JVMCI options
echo     -native     generate both JVM files and native image
echo     -timer      display total elapsed time
echo     -verbose    display progress messages
echo.
echo   Subcommands:
echo     clean       delete generated object files
echo     check       analyze Java source files with CheckStyle
echo     compile     compile Java source files
echo     help        display this help message
echo     run         execute main program
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

:rmdir
set "__DIR=%~1"
if not exist "%__DIR%" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:checkstyle
set "__USER_GRAAL_DIR=%USERPROFILE%\.graal"
if not exist "%__USER_GRAAL_DIR%" mkdir "%__USER_GRAAL_DIR%"

set "__XML_FILE=%__USER_GRAAL_DIR%\graal_checks.xml"
if not exist "%__XML_FILE%" call :checkstyle_xml "%__XML_FILE%"

@rem "checkstyle-all" version not available from Maven Central
set __JAR_NAME=checkstyle-%_CHECKSTYLE_VERSION%-all.jar
set __JAR_URL=https://github.com/checkstyle/checkstyle/releases/download/checkstyle-%_CHECKSTYLE_VERSION%/%__JAR_NAME%
set "__JAR_FILE=%__USER_GRAAL_DIR%\%__JAR_NAME%"
if exist "%__JAR_FILE%" goto checkstyle_analyze

set "__PS1_FILE=%__USER_GRAAL_DIR%\webrequest.ps1"
if not exist "%__PS1_FILE%" call :checkstyle_ps1 "%__PS1_FILE%"

set __PS1_VERBOSE[0]=
set __PS1_VERBOSE[1]=-Verbose
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "& '%__PS1_FILE%' -Uri '%__JAR_URL%' -Outfile '%__JAR_FILE%'" 1>&2
) else if %_VERBOSE%==1 ( echo Download file %__JAR_NAME% 1>&2
)
powershell -c "& '%__PS1_FILE%' -Uri '%__JAR_URL%' -OutFile '%__JAR_FILE%' !__PS1_VERBOSE[%_VERBOSE%]!"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to download file %__JAR_NAME% 1>&2
    set _EXITCODE=1
    goto :eof
)
:checkstyle_analyze
set __SOURCE_FILES=
for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%" *.java') do set __SOURCE_FILES=!__SOURCE_FILES! %%f

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_JAVA_CMD% -jar "%__JAR_FILE%" -c="%__XML_FILE%" %__SOURCE_FILES% 1>&2
) else if %_VERBOSE%==1 ( echo Analyze Java source files with CheckStyle configuration !__XML_FILE:%USERPROFILE%\=! 1>&2
)
call "%_JAVA_CMD%" -jar "%__JAR_FILE%" -c="%__XML_FILE%" %__SOURCE_FILES%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile
if not exist "%_CLASSES_DIR%" mkdir "%_CLASSES_DIR%"

set "__OPTS_FILE=%_TARGET_DIR%\javac_opts.txt"
echo %_JAVAC_OPTS% -d "%_CLASSES_DIR:\=\\%" > "%__OPTS_FILE%"

set "__SOURCES_FILE=%_TARGET_DIR%\javac_sources.txt"
if exist "%__SOURCES_FILE%" del "%__SOURCES_FILE%"
for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%" *.java') do (
    echo %%f>> "%__SOURCES_FILE%"
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVAC_CMD%" "@%__OPTS_FILE%" "@%__SOURCES_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Compile Java source files to directory "!_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_JAVAC_CMD%" "@%__OPTS_FILE%" "@%__SOURCES_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:native_image
setlocal
call :native_env_msvc

if exist "%_MAIN_NATIVE_FILE%.exe" del "%_MAIN_NATIVE_FILE%.*"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_NATIVE_IMAGE_CMD%" %_NATIVE_IMAGE_OPTS% %_MAIN_CLASS% %_MAIN_NATIVE_FILE% 1>&2
) else if %_VERBOSE%==1 ( echo Create native image "!_MAIN_NATIVE_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%_NATIVE_IMAGE_CMD%" %_NATIVE_IMAGE_OPTS% %_MAIN_CLASS% %_MAIN_NATIVE_FILE% %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    endlocal
    echo %_ERROR_LABEL% Failed to create native image !_MAIN_NATIVE_FILE:%_ROOT_DIR%=! 1>&2
    set _EXITCODE=1
    goto :eof
)
endlocal
goto :eof

:native_env_msvc
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set __MSVC_ARCH=\amd64
    set __NET_ARCH=Framework64\v4.0.30319
    set __SDK_ARCH=\x64
    set __KIT_ARCH=\x64
) else (
    set __MSVC_ARCH=\x86
    set __NET_ARCH=Framework\v4.0.30319
    set __SDK_ARCH=
    set __KIT_ARCH=\x86
)
@rem Variables MSVC_HOME, MSVS_HOME and SDK_HOME are defined by setenv.bat
set "INCLUDE=%MSVC_HOME%\include;%SDK_HOME%\include"
set "LIB=%MSVC_HOME%\Lib%__MSVC_ARCH%;%SDK_HOME%\lib%__SDK_ARCH%"
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% ===== B U I L D   V A R I A B L E S ===== 1>&2
    echo %_DEBUG_LABEL% INCLUDE="%INCLUDE%" 1>&2
    echo %_DEBUG_LABEL% LIB="%LIB%" 1>&2
    echo %_DEBUG_LABEL% ========================================= 1>&2
)
goto :eof

:pack
goto :eof

:run_jvm
set __MAIN_ARGS=In 2019 I would like to run ALL languages in one VM.
set __ITERATIONS=5

if %_DEBUG%==1 ( set __JAVA_OPTS=%_JAVA_OPTS% -Diterations=%__ITERATIONS% %_GRAALVM_OPTS%
) else ( set __JAVA_OPTS=%_JAVA_OPTS% -Diterations=%__ITERATIONS%
)
if %_JVMCI%==1 (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% GraalVM compiler is disabled 1>&2
    ) else if %_VERBOSE%==1 ( echo GraalVM compiler is disabled 1>&2
    )
    set __JAVA_OPTS=%_JAVA_OPTS% -XX:-UseJVMCICompiler
)

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVA_CMD%" %__JAVA_OPTS% %_MAIN_CLASS% %__MAIN_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute Java main class %_MAIN_CLASS% %__MAIN_ARGS% 1>&2
)
call "%_JAVA_CMD%" %__JAVA_OPTS% %_MAIN_CLASS% %__MAIN_ARGS%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 if exist "%_GRAALVM_LOG_FILE%" (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Compilation log written to "%_GRAALVM_LOG_FILE%" 1>&2
    ) else if %_VERBOSE%==1 ( echo Compilation log written to "!_GRAALVM_LOG_FILE:%_ROOT_DIR%=!" 1>&2
    )
)
goto :eof

:run_native
set "__EXE_FILE=%_MAIN_NATIVE_FILE%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable not found ^(%__EXE_FILE%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% "%__EXE_FILE%" 1>&2
call "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem input parameter: %1=XML file path
@rem NB. Archive checkstyle-*-all.jar contains 2 configuration files:
@rem     google_checks.xml, sun_checks.xml.
:checkstyle_xml
set "__XML_FILE=%~1"
(
    echo ^<?xml version="1.0"?^>
    echo ^<^^!DOCTYPE module PUBLIC
    echo           "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
    echo           "https://checkstyle.org/dtds/configuration_1_3.dtd"^>
    echo.
    echo ^<module name="Checker"^>
    echo     ^<property name="localeCountry" value="US"/^>
    echo     ^<property name="localeLanguage" value="en"/^>
    echo     ^<property name="severity" value="error"/^>
    echo     ^<property name="fileExtensions" value="java, properties, xml"/^>
    echo     ^<^^!-- See https://checkstyle.org/config_whitespace.html --^>
    echo     ^<module name="FileTabCharacter"/^>
    echo     ^<module name="TreeWalker"^>
    echo         ^<^^!-- See https://checkstyle.org/config_import.html --^>
    echo         ^<module name="AvoidStarImport"/^>
    echo         ^<module name="IllegalImport"/^> ^<^^!-- defaults to sun.* packages --^>
    echo         ^<module name="RedundantImport"/^>
    echo         ^<module name="UnusedImports"^>
    echo             ^<property name="processJavadoc" value="false"/^>
    echo         ^</module^>
    echo         ^<^^!-- See https://checkstyle.org/config_whitespace.html --^>
    echo         ^<module name="EmptyForIteratorPad"/^>
    echo         ^<module name="GenericWhitespace"/^>
    echo         ^<module name="MethodParamPad"/^>
    echo         ^<module name="NoWhitespaceAfter"/^>
    echo         ^<module name="NoWhitespaceBefore"/^>
    echo         ^<module name="OperatorWrap"/^>
    echo         ^<module name="ParenPad"/^>
    echo         ^<module name="TypecastParenPad"/^>
    echo         ^<module name="WhitespaceAfter"/^>
    echo         ^<module name="WhitespaceAround"/^>
    echo     ^</module^>
    echo ^</module^>
) > "%__XML_FILE%"
goto :eof

@rem input parameter: %1=PS1 file path
:checkstyle_ps1
set "__PS1_FILE=%~1"
@rem see https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
@rem NB. cURL is a standard tool only from Windows 10 build 17063 and later.
(
    echo Param^(
    echo    [Parameter^(Mandatory=$True,Position=1^)]
    echo    [string]$Uri,
    echo    [Parameter^(Mandatory=$True^)]
    echo    [string]$OutFile
    echo ^)
    echo Add-Type ^@^"
    echo using System.Net;
    echo using System.Security.Cryptography.X509Certificates;
    echo public class TrustAllCertsPolicy : ICertificatePolicy {
    echo     public bool CheckValidationResult^(
    echo         ServicePoint srvPoint, X509Certificate certificate,
    echo         WebRequest request, int certificateProblem^) {
    echo         return true;
    echo     }
    echo }
    echo ^"^@
    echo $Verbose=$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
    echo $AllProtocols=[System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    echo [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    echo [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    echo $progressPreference='silentlyContinue'
    echo Invoke-WebRequest -TimeoutSec 60 -Uri $Uri -Outfile $OutFile
) > "%__PS1_FILE%"
goto :eof

@rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
