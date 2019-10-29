@echo off
setlocal enabledelayedexpansion

set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

call :remove_dirs
if not %_EXITCODE%==0 goto end

call :remove_files
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
:args
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N=+1
    if /i "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _DEBUG=%_DEBUG% _HELP=%_HELP% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      show commands executed by this script
echo     -verbose    display environment settings
echo   Subcommands:
echo     help        display this help message
goto :eof

:remove_dirs
set __N=0
for /f %%f in ('dir /ad /b "%_ROOT_DIR%CompilationWrapper*" "%_ROOT_DIR%DumpPathTest*" 2^>NUL') do (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% rmdir /s /q %%f 1>&2
    rmdir /s /q %%f
    if !ERRORLEVEL!==0 ( set /a __N=+1
    ) else if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Failed to remove directory %%f 1>&2
    )
)
if %_DEBUG%==1 if %__N% gtr 0 echo %_DEBUG_LABEL% Removed %__N% directories 1>&2
goto :eof

:remove_files
set __N=0
for /f %%f in ('dir /a-d /b "%_ROOT_DIR%hs_err_pid*.log" 2^>NUL') do (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% del /q %%f 1>&2
    del /q %%f
    if !ERRORLEVEL!==0 ( set /a __N=+1
    ) else if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Failed to remove file %%f 1>&2
    )
)
if %_DEBUG%==1 if %__N% gtr 0 echo %_DEBUG_LABEL% Removed %__N% files 1>&2
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
exit /b %_EXITCODE%
endlocal
