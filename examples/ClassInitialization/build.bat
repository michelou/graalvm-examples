@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging !
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _SOURCE_DIR=%_ROOT_DIR%src\main\java
set _TARGET_DIR=%_ROOT_DIR%target
set _CLASSES_DIR=%_TARGET_DIR%\classes

set "_JAVA_HOME=%GRAALVM_HOME%"

set _JAVAC_CMD=javac.exe
set _JAVAC_OPTS=-d %_CLASSES_DIR%

set _GRAALVM_LOG_FILE=%_TARGET_DIR%\graal_log.txt
set _GRAALVM_OPTS=-Dgraal.ShowConfiguration=info -Dgraal.PrintCompilation=true -Dgraal.LogFile=%_GRAALVM_LOG_FILE%

set _JAVA_CMD=java.exe
set _JAVA_OPTS=-cp %_CLASSES_DIR%

call :args %*
if %_HELP%==1 call :help & goto end
if not %_EXITCODE%==0 goto end

rem ##########################################################################
rem ## Main

if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto en
)
if %_COMPILE%==1 (
    call :compile
    if not !_EXITCODE!==0 goto end
)
if %_RUN%==1 (
    call :run
    if not !_EXITCODE!==0 goto end
)
goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter %*
:args
set _CLEAN=0
set _COMPILE=0
set _HELP=0
set _RUN=0
set _JVMCI=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="clean" ( set _CLEAN=1
) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
) else if /i "%__ARG%"=="help" ( set _HELP=1
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-jvmci" ( set _JVMCI=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG%
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      display commands executed by this script
echo     -jvmci      add JVMCI options
echo     -verbose    display progress messages
echo   Subcommands:
echo     clean       delete generated object files
echo     compile     compile Java source files
echo     help        display this help message
echo     run         execute main program
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

:rmdir
set __DIR=%~1
if not exist "%__DIR%" goto :eof
if %_DEBUG%==1 ( echo [%_BASENAME%] rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory !__DIR:%_ROOT_DIR%=! 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile
if not exist "%_CLASSES_DIR%" mkdir "%_CLASSES_DIR%"

set __SOURCE_LIST_FILE=%_TARGET_DIR%\source_list.txt
if exist "%__SOURCE_LIST_FILE%" del "%__SOURCE_LIST_FILE%"

for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%" *.java') do (
    echo %%f>> "%__SOURCE_LIST_FILE%"
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVAC_CMD% %_JAVAC_OPTS% @%__SOURCE_LIST_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Compile Java source files to directory !_CLASSES_DIR:%_ROOT_DIR%=! 1>&2
)
%_JAVAC_CMD% %_JAVAC_OPTS% @"%__SOURCE_LIST_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run
set __MAIN_CLASS=HelloStartupTime
set __MAIN_ARGS=

if %_DEBUG%==1 ( set __JAVA_OPTS=%_JAVA_OPTS% %_GRAALVM_OPTS%
) else ( set __JAVA_OPTS=%_JAVA_OPTS%
)
if %_JVMCI%==1 (
    if %_DEBUG%==1 ( echo [%_BASENAME%] GraalVM compiler is disabled 1>&2
    ) else if %_VERBOSE%==1 ( echo GraalVM compiler is disabled 1>&2
    )
    set __JAVA_OPTS=%_JAVA_OPTS% -XX:-UseJVMCICompiler
)

if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVA_CMD% %__JAVA_OPTS% %__MAIN_CLASS% %__MAIN_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute Java main class %__MAIN_CLASS% 1>&2
)
call "%_JAVA_CMD%" %__JAVA_OPTS% %__MAIN_CLASS% %__MAIN_ARGS%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 if exist "%_GRAALVM_LOG_FILE%" (
    if %_DEBUG%==1 ( echo [%_BASENAME%] Compilation log written to %_GRAALVM_LOG_FILE% 1>&2
    ) else if %_VERBOSE%==1 ( echo Compilation log written to !_GRAALVM_LOG_FILE:%_ROOT_DIR%=! 1>&2
    )
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
