@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)

set _JAVA_HOME=
set _JAVA11_HOME=

set _MAVEN_PATH=
set _LLVM_PATH=
set _SDK_PATH=
set _CYGWIN_PATH=
set _GIT_PATH=

call :java8
if not %_EXITCODE%==0 goto end

call :java11
if not %_EXITCODE%==0 goto end

call :maven
if not %_EXITCODE%==0 goto end

call :python
if not %_EXITCODE%==0 goto end

call :llvm
if not %_EXITCODE%==0 goto end

@rem call :msvs
call :msvs_2019
if not %_EXITCODE%==0 goto end

call :sdk
if not %_EXITCODE%==0 goto end

call :kit
if not %_EXITCODE%==0 goto end

call :wabt
if not %_EXITCODE%==0 goto end

call :cygwin
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set _DRIVE_NAME=G
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _RESET=[0m
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m

@rem normal foreground colors
set _NORMAL_FG_BLACK=[30m
set _NORMAL_FG_RED=[31m
set _NORMAL_FG_GREEN=[32m
set _NORMAL_FG_YELLOW=[33m
set _NORMAL_FG_BLUE=[34m
set _NORMAL_FG_MAGENTA=[35m
set _NORMAL_FG_CYAN=[36m
set _NORMAL_FG_WHITE=[37m

@rem normal background colors
set _NORMAL_BG_BLACK=[40m
set _NORMAL_BG_RED=[41m
set _NORMAL_BG_GREEN=[42m
set _NORMAL_BG_YELLOW=[43m
set _NORMAL_BG_BLUE=[44m
set _NORMAL_BG_MAGENTA=[45m
set _NORMAL_BG_CYAN=[46m
set _NORMAL_BG_WHITE=[47m

@rem strong foreground colors
set _STRONG_FG_BLACK=[90m
set _STRONG_FG_RED=[91m
set _STRONG_FG_GREEN=[92m
set _STRONG_FG_YELLOW=[93m
set _STRONG_FG_BLUE=[94m
set _STRONG_FG_MAGENTA=[95m
set _STRONG_FG_CYAN=[96m
set _STRONG_FG_WHITE=[97m

@rem strong background colors
set _STRONG_BG_BLACK=[100m
set _STRONG_BG_RED=[101m
set _STRONG_BG_GREEN=[102m
set _STRONG_BG_YELLOW=[103m
set _STRONG_BG_BLUE=[104m
goto :eof

@rem input parameter: %*
:args
set _BASH=0
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-bash" ( set _BASH=1
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto args_loop
:args_done
call :subst %_DRIVE_NAME% "%_ROOT_DIR%"
if not %_EXITCODE%==0 goto :eof
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options  : _BASH=%_BASH% _HELP=%_HELP% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Variables: _DRIVE_NAME=%_DRIVE_NAME% 1>&2
)
goto :eof

@rem input parameter(s): %1: drive letter, %2: path to be substituted
:subst
set __DRIVE_NAME=%~1
set "__GIVEN_PATH=%~2"

if not "%__DRIVE_NAME:~-1%"==":" set __DRIVE_NAME=%__DRIVE_NAME%:
if /i "%__DRIVE_NAME%"=="%__GIVEN_PATH:~0,2%" goto :eof

if "%__GIVEN_PATH:~-1%"=="\" set "__GIVEN_PATH=%__GIVEN_PATH:~0,-1%"
if not exist "%__GIVEN_PATH%" (
    echo %_ERROR_LABEL% Provided path does not exist ^(%__GIVEN_PATH%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    set "__SUBST_PATH=%%h"
    if "!__SUBST_PATH!"=="!__GIVEN_PATH!" (
        set __MESSAGE=
        for /f %%i in ('subst ^| findstr /b "%__DRIVE_NAME%\"') do "set __MESSAGE=%%i"
        if defined __MESSAGE (
            if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__MESSAGE! 1>&2
            ) else if %_VERBOSE%==1 ( echo !__MESSAGE! 1>&2
            )
        )
        goto :eof
    )
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% subst "%__DRIVE_NAME%" "%__GIVEN_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo Assign path %__GIVEN_PATH% to drive %__DRIVE_NAME% 1>&2
)
subst "%__DRIVE_NAME%" "%__GIVEN_PATH%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to assigned drive %__DRIVE_NAME% to path 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%%_UNDERSCORE%
    set __BEG_O=%_STRONG_FG_GREEN%
    set __BEG_N=%_NORMAL_FG_YELLOW%
    set __END=%_RESET%
) else (
    set __BEG_P=
    set __BEG_O=
    set __BEG_N=
    set __END=
)
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-bash%__END%       start Git bash shell instead of Windows command prompt
echo     %__BEG_O%-debug%__END%      show commands executed by this script
echo     %__BEG_O%-verbose%__END%    display environment settings
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%help%__END%        display this help message
goto :eof

@rem input parameter: %1=Java version
@rem output parameter: _GRAALVM_HOME
:graal
set __JAVA_VERSION=%~1
set _GRAALVM_HOME=

set __JAVAC_CMD=
for /f %%f in ('where javac.exe 2^>NUL') do set "__JAVAC_CMD=%%f"
if defined __JAVAC_CMD (
    for %%i in ("%__JAVAC_CMD%") do set "__GRAAL_BIN_DIR=%%~dpi"
    for %%f in ("!__GRAAL_BIN_DIR!\.") do set "_GRAALVM_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of javac executable found in PATH 1>&2
    goto :eof
) else if defined GRAAL_HOME (
    set "_GRAALVM_HOME=%GRAAL_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GRAAL_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%__JAVA_VERSION%*" 2^>NUL') do set "_GRAALVM_HOME=!__PATH!\%%f"
    if not defined _GRAALVM_HOME (
        set "__PATH=%ProgramFiles%"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%__JAVA_VERSION%*" 2^>NUL') do set "_GRAALVM_HOME=!__PATH!\%%f"
    )
)
if not exist "%_GRAALVM_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% Executable javac.exe not found ^(%_GRAALVM_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_GRAALVM_HOME%\bin\polyglot.cmd" (
    echo %_ERROR_LABEL% Executable polyglot.cmd not found ^(%_GRAALVM_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:java8
call :graal java8
if not %_EXITCODE%==0 goto :eof
if defined _GRAALVM_HOME set "_GRAALVM_HOME=%_GRAALVM_HOME%"
goto :eof

:java11
call :graal java11
if not %_EXITCODE%==0 goto :eof
if defined _GRAALVM_HOME set "_GRAALVM11_HOME=%_GRAALVM_HOME%"
goto :eof

@rem output parameters: _MAVEN_HOME, _MAVEN_PATH
:maven
set _MAVEN_HOME=
set _MAVEN_PATH=

set __MVN_CMD=
for /f %%f in ('where mvn.cmd 2^>NUL') do set "__MVN_CMD=%%f"
if defined __MVN_CMD (
    for %%i in ("%__MVN_CMD%") do set "__MAVEN_BIN_DIR=%%~dpi"
    for %%f in ("!__MAVEN_BIN_DIR!\.") do set "_MAVEN_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Maven executable found in PATH 1>&2
    goto :eof
) else if defined MAVEN_HOME (
    set "_MAVEN_HOME=%MAVEN_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable MAVEN_HOME 1>&2
) else (
    set _PATH=C:\opt
    for /f %%f in ('dir /ad /b "!_PATH!\apache-maven-*" 2^>NUL') do set "_MAVEN_HOME=!_PATH!\%%f"
    if defined _MAVEN_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Maven installation directory !_MAVEN_HOME! 1>&2
    )
)
if not exist "%_MAVEN_HOME%\bin\mvn.cmd" (
    echo %_ERROR_LABEL% Maven executable not found ^(%_MAVEN_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MAVEN_PATH=;%_MAVEN_HOME%\bin"
goto :eof

@rem output parameter: _PYTHON_HOME
:python
set _PYTHON_HOME=

set __PYTHON_CMD=
for /f %%f in ('where python.exe 2^>NUL') do (
    set "__PYTHON_CMD=%%f"
    if not "!__PYTHON_CMD:WindowsApps=!"=="!__PYTHON_CMD!" set __PYTHON_CMD=
)
if defined __PYTHON_CMD (
    for /f "delims=" %%i in ("%__PYTHON_CMD%") do set "_PYTHON_HOME=%%~dpi"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Python executable found in PATH 1>&2
    goto :eof
) else if defined PYTHON_HOME (
    set "_PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable PYTHON_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set "_PYTHON_HOME=!__PATH!\Python"
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Python-2*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        if not defined _PYTHON_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Python-2*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_PYTHON_HOME%\python.exe" (
    echo %_ERROR_LABEL% Python executable not found ^(%_PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_PYTHON_HOME%\Scripts\pylint.exe" (
    echo %_ERROR_LABEL% Pylint executable not found ^(%_PYTHON_HOME%^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_PYTHON_PATH=;%_PYTHON_HOME%;%_PYTHON_HOME%\Scripts"
goto :eof

@rem output parameter(s): _LLVM_HOME, _LLVM_PATH
:llvm
set _LLVM_HOME=
set _LLVM_PATH=

set __LLVM_VERSION=10
set __CLANG_CMD=
for /f %%f in ('where clang.exe 2^>NUL') do set "__CLANG_CMD=%%f"
if defined __CLANG_CMD (
    for /f "delims=" %%i in ("%__CLANG_CMD%") do set "__LLVM_BIN_DIR=%%~dpi"
    for %%f in ("!__LLVM_BIN_DIR!\.") do set "_LLVM_HOME=%%~dpf"
    @rem keep _LLVM_PATH undefined since executable already in path
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Clang executable found in PATH 1>&2
    goto :eof
) else if defined LLVM_HOME (
    set "_LLVM_HOME=%LLVM_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable LLVM_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\LLVM-%__LLVM_VERSION%*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    if not defined _LLVM_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\LLVM-%__LLVM_VERSION%*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    )
)
if not exist "%_LLVM_HOME%\bin\clang.exe" (
    echo %_ERROR_LABEL% clang executable not found ^(%_LLVM_HOME%^) 1>&2
    set _LLVM_HOME=
    set _EXITCODE=1
    goto :eof
)
set "_LLVM_PATH=;%_LLVM_HOME%\bin"
goto :eof

@rem output parameters: _MSVC_HOME, _MSVC_HOME
@rem Visual Studio 10
:msvs
set _MSVC_HOME=
set _MSVS_HOME=

for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio 10.0") do (
    set "_MSVS_HOME=%%~f"
)
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MSVC_HOME=%_MSVS_HOME%\VC"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __MSVC_ARCH=\amd64
) else ( set __MSVC_ARCH=
)
if not exist "%_MSVC_HOME%\bin%__MSVC_ARCH%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_HOME=
set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
if not exist "%__MSBUILD_HOME%\MSBuild.exe" (
    echo %_ERROR_LABEL% Could not find Microsoft builder 1>&2
    set _EXITCODE=1
    goto :eof
)
@rem set "_MSVS_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%;%__MSBUILD_HOME%"
goto :eof

@rem output parameter(s): _MSVC_BIN_DIR, _MSVC_HOME, _MSVS_CMAKE_CMD, _MSVS_HOME
@rem Visual Studio 2019
:msvs_2019
set _MSVC_BIN_DIR=
set _MSVC_HOME=
set _MSVS_CMAKE_CMD=
set _MSVS_HOME=

set "__WSWHERE_CMD=%_ROOT_DIR%bin\vswhere.exe"
for /f "delims=" %%f in ('"%__WSWHERE_CMD%" -property installationPath 2^>NUL') do set "_MSVS_HOME=%%~f"
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 2019 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
call :subst_path "%_MSVS_HOME%"
if not %_EXITCODE%==0 goto :eof
set "_MSVS_HOME=%_SUBST_PATH%"

set "__PATH=%_MSVS_HOME%\VC\Tools\MSVC"
for /f %%f in ('dir /ad /b "%__PATH%" 2^>NUL') do set "_MSVC_HOME=%__PATH%\%%f"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set "_MSVC_BIN_DIR=%_MSVC_HOME%\bin\Hostx64\x64"
) else ( set "_MSVC_BIN_DIR=%_MSVC_HOME%\bin\Hostx86\x86"
)
if not exist "%_MSVC_BIN_DIR%\cl.exe" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft C/C++ compiler 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__PATH=%_MSVS_HOME%\MSBuild\Current"
for /f "delims=" %%i in ('where /r "!__PATH!" msbuild.exe ^| findstr amd64') do set "__MSBUILD_BIN_DIR=%%~dpi"
if not exist "%__MSBUILD_BIN_DIR%\MSBuild.exe" (
    echo %_ERROR_LABEL% Could not find Microsoft builder 1>&2
    set _MSBUILD_HOME=
    set _EXITCODE=1
    goto :eof
)
set "__PATH=%_MSVS_HOME%\Common7\IDE\CommonExtensions\Microsoft\CMake"
for /f "delims=" %%i in ('where /r "!__PATH!" cmake.exe') do set "__CMAKE_BIN_DIR=%%~dpi"
for %%f in ("!__CMAKE_BIN_DIR!..") do set _CMAKE_HOME=%%~sf
if not exist "%__CMAKE_BIN_DIR%\cmake.exe" (
    echo %_ERROR_LABEL% Could not find Microsoft CMake ^(%_CMAKE_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MSVS_CMAKE_CMD=%__CMAKE_BIN_DIR%\cmake.exe"
@rem set "_MSVS_PATH=;%_MSVC_BIN_DIR%;%__MSBUILD_BIN_DIR%"
goto :eof

@rem input parameter(s): %1=directory path
@rem output parameter: _SUBST_PATH
:subst_path
set "_SUBST_PATH=%~1"
set __DRIVE_NAME=X:
set __ASSIGNED_PATH=
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    if not "%%h"=="%_SUBST_PATH%" (
        echo %_WARNING_LABEL% Drive %__DRIVE_NAME% already assigned to %%h 1>&2
        goto :eof
    )
    set "__ASSIGNED_PATH=%%h"
)
if not defined __ASSIGNED_PATH (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% subst "%__DRIVE_NAME%" "%_SUBST_PATH%" 1>&2
    subst "%__DRIVE_NAME%" "%_SUBST_PATH%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set _SUBST_PATH=%__DRIVE_NAME%
goto :eof

@rem output parameter: _SDK_HOME
@rem native-image dependency
:sdk
set _SDK_HOME=

set "__SDK_PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows"
for /f %%i in ('dir /ad /b "%__SDK_PATH%\v*"') do set "_SDK_HOME=%__SDK_PATH%\%%i"
if not exist "%_SDK_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Windows SDK 7.1 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem output parameter(s): _KIT_INC_DIR, _KIT_LIB_DIR
@rem native-image dependency
:kit
set _KIT_INC_DIR=
set _KIT_LIB_DIR=

set "__KIT_HOME=%ProgramFiles(x86)%\Windows Kits\10"
set "__MANIFEST_FILE=%__KIT_HOME%\SDKManifest.xml"
if not exist "%__MANIFEST_FILE%" (
    echo %_ERROR_LABEL% Manifest file not found ^("%__KIT_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "delims== tokens=1,*" %%i in ('powershell -c "$p='%__MANIFEST_FILE%';$xml=[xml](Get-Content $p); $xml.FileList.PlatformIdentity"') do set "__KIT_VERSION=%%j"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __KIT_ARCH=\x64
) else ( set __KIT_ARCH=\x86
)
set "_KIT_INC_DIR=%__KIT_HOME%\Include\%__KIT_VERSION%"
set "_KIT_LIB_DIR=%__KIT_HOME%\Lib\%__KIT_VERSION%"
goto :eof

@rem output parameter: _WABT_HOME
:wabt
set _WABT_HOME=

if defined WABT_HOME (
    set "_WABT_HOME=%WABT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable WABT_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\wabt-1*" 2^>NUL') do set "_WABT_HOME=!__PATH!\%%f"
)
if not exist "%_WABT_HOME%\bin\wat2wasm.exe" (
    echo %_ERROR_LABEL% Wat2WASM executable not found ^("%_WABT_HOME%"^) 1>&2
    set _WABT_HOME=
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem output parameter(s): _CYGWIN_HOME, _CYGWIN_PATH
:cygwin
set _CYGWIN_HOME=
set _CYGWIN_PATH=

set __MAKE_CMD=
for /f %%f in ('where make.exe 2^>NUL') do set "__MAKE_CMD=%%f"
if defined __MAKE_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of GNU Make executable found in PATH 1>&2
    for /f "delims=" %%i in ("%__MAKE_CMD%") do set "__MAKE_BIN_DIR=%%~dpi"
    for %%f in ("!__MAKE_BIN_DIR!..\.") do set "_CYGWIN_HOME=%%~dpf"
    @rem keep _CYGWIN_PATH undefined since executable already in path
    goto :eof
) else if defined CYGWIN_HOME (
    set "_CYGWIN_HOME=%CYGWIN_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable CYGWIN_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Cygwin*" 2^>NUL') do set "_CYGWIN_HOME=!__PATH!\%%f"
    if not defined _CYGWIN_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\Cygwin*" 2^>NUL') do set "_CYGWIN_HOME=!__PATH!\%%f"
    )
)
if not exist "%_CYGWIN_HOME%\bin\make.exe" (
    echo %_ERROR_LABEL% GNU Make executable not found ^("%_CYGWIN_HOME%"^) 1>&2
    set _CYGWIN_HOME=
    set _EXITCODE=1
    goto :eof
)
set "_CYGWIN_PATH=;%_CYGWIN_HOME%\bin"
goto :eof

@rem output parameters: _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    for %%i in ("%__GIT_CMD%") do set "__GIT_BIN_DIR=%%~dpi"
    for %%f in ("!__GIT_BIN_DIR!\.") do set "_GIT_HOME=%%~dpf"
    @rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for %%f in ("!_GIT_HOME!\..") do set "_GIT_HOME=%%f"
    )
    @rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^("%_GIT_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory %_GIT_HOME% 1>&2

set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

:print_env
set __VERBOSE=%1
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
set "__VERSIONS_LINE3=  "
set __WHERE_ARGS=

where /q "%JAVA_HOME%\bin:javac.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%JAVA_HOME%\bin\javac.exe" -version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% javac %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%JAVA_HOME%\bin:javac.exe"
)
where /q "%JAVA11_HOME%\bin:javac.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%JAVA11_HOME%\bin\javac.exe" -version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% javac %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%JAVA11_HOME%\bin:javac.exe"
)
where /q "%PYTHON_HOME%:python.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%PYTHON_HOME%\python.exe" --version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% python %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%PYTHON_HOME%:python.exe"
)
where /q "%PYTHON_HOME%\Scripts:pylint.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%PYTHON_HOME%\Scripts\pylint.exe" --version 2^>^NUL ^| findstr pylint') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% pylint %%j"
    set __WHERE_ARGS=%__WHERE_ARGS% "%PYTHON_HOME%\Scripts:pylint.exe"
)
where /q make.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('make.exe --version 2^>^&1 ^| findstr Make') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% make %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% make.exe
)
where /q "%LLVM_HOME%\bin:clang.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%LLVM_HOME%\bin\clang.exe" --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% clang %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%LLVM_HOME%\bin:clang.exe"
)
where /q "%LLVM_HOME%\bin:opt.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%LLVM_HOME%\bin\opt.exe" --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% opt %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%LLVM_HOME%\bin:opt.exe"
)
where /q "%MSVC_BIN_DIR%:cl.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-6,7,*" %%i in ('"%MSVC_BIN_DIR%\cl.exe" -version 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cl %%o,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSVC_BIN_DIR%:cl.exe"
)
where /q cmake.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('cmake.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cmake %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% cmake.exe
)
where /q msbuild.exe
if %ERRORLEVEL%==0 (
    for /f %%i in ('msbuild.exe -version ^| findstr /b "[0-9]"') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% msbuild %%i,"
    set __WHERE_ARGS=%__WHERE_ARGS% msbuild.exe
)
where /q "%MSVC_BIN_DIR%:link.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-5,*" %%i in ('"%MSVC_BIN_DIR%\link.exe" ^| findstr Version 2^>^NUL') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% link %%n,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSVC_BIN_DIR%:link.exe"
)
where /q "%MSVC_BIN_DIR%:nmake.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-7,*" %%i in ('"%MSVC_BIN_DIR%\nmake.exe" /? 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% nmake %%o,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSVC_BIN_DIR%:nmake.exe"
)
where /q "%GIT_HOME%\bin:git.exe"
if %ERRORLEVEL%==0 (
   for /f "tokens=1,2,*" %%i in ('"%GIT_HOME%\bin\git.exe" --version') do set __VERSIONS_LINE3=%__VERSIONS_LINE3% git %%k
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:git.exe"
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
echo %__VERSIONS_LINE3%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    @rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
    echo Environment variables: 1>&2
    if defined GIT_HOME echo    "GIT_HOME=%GIT_HOME%" 1>&2
    if defined GRAALVM_HOME echo    "GRAALVM_HOME=%GRAALVM_HOME%" 1>&2
    if defined GRAALVM11_HOME echo    "GRAALVM11_HOME=%GRAALVM11_HOME%" 1>&2
    if defined LLVM_HOME echo    "LLVM_HOME=%LLVM_HOME%" 1>&2
    if defined MAVEN_HOME echo    "MAVEN_HOME=%MAVEN_HOME%" 1>&2
    if defined MSVC_BIN_DIR echo    "MSVC_BIN_DIR=%MSVC_BIN_DIR%" 1>&2
    if defined MSVC_HOME echo    "MSVC_HOME=%MSVC_HOME%" 1>&2
    if defined MSVS_HOME echo    "MSVS_HOME=%MSVS_HOME%" 1>&2
    if defined PYTHON_HOME echo    "PYTHON_HOME=%PYTHON_HOME%" 1>&2
    if defined WABT_HOME echo    "WABT_HOME=%WABT_HOME%" 1>&2
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined GIT_HOME set "GIT_HOME=%_GIT_HOME%"
        if not defined GRAALVM_HOME set "GRAALVM_HOME=%_GRAALVM_HOME%"
        if not defined GRAALVM11_HOME set "GRAALVM11_HOME=%_GRAALVM11_HOME%"
        @rem JAVA_HOME needed for Maven
        if not defined JAVA_HOME set "JAVA_HOME=%_GRAALVM_HOME%"
        if not defined JAVA11_HOME set "JAVA11_HOME=%_GRAALVM11_HOME%"
        if not defined LLVM_HOME set "LLVM_HOME=%_LLVM_HOME%"
        if not defined MAVEN_HOME set "MAVEN_HOME=%_MAVEN_HOME%"
        if not defined MSVC_BIN_DIR set "MSVC_BIN_DIR=%_MSVC_BIN_DIR%"
        if not defined MSVC_HOME set "MSVC_HOME=%_MSVC_HOME%"
        if not defined MSVS_CMAKE_CMD set "MSVS_CMAKE_CMD=%_MSVS_CMAKE_CMD%"
        if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
        if not defined PYTHON_HOME set "PYTHON_HOME=%_PYTHON_HOME%"
        if not defined SDK_HOME set "SDK_HOME=%_SDK_HOME%"
        if not defined KIT_INC_DIR set "KIT_INC_DIR=%_KIT_INC_DIR%"
        if not defined KIT_LIB_DIR set "KIT_LIB_DIR=%_KIT_LIB_DIR%"
        if not defined CYGWIN_HOME set "CYGWIN_HOME=%_CYGWIN_HOME%"
        if not defined WABT_HOME set "WABT_HOME=%_WABT_HOME%"
        set "PATH=%PATH%%_MAVEN_PATH%%_LLVM_PATH%%_CYGWIN_PATH%%_GIT_PATH%;%~dp0bin"
        call :print_env %_VERBOSE%
        if not "%CD:~0,2%"=="%_DRIVE_NAME%:" (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% cd /d %_DRIVE_NAME%: 1>&2
            cd /d %_DRIVE_NAME%:
        )
        if %_BASH%==1 (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\bin\bash.exe --login 1>&2
            call "%_GIT_HOME%\bin\bash.exe" --login
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
