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
if %_UPDATE%==1 (
    call :update
    if not !_EXITCODE!==0 goto end
)
if %_DIST%==1 (
    call :clone
    if not !_EXITCODE!==0 goto end

    call :dist
    if not !_EXITCODE!==0 goto end
)
goto :end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
@rem                    _GIT_CMD, _GIT_OPTS, _MX_CMD, _MX_OPTS, _TAR_CMD
:env
set _BASENAME=%~n0
for %%f in ("%~dp0\.") do set "_ROOT_DIR=%%~dpf"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "_TRAVIS_BUILD_DIR=%~dp0"
set "_TMP_DIR=%_ROOT_DIR%\tmp"

set _GRAAL_URL=https://github.com/oracle/graal.git
set "_GRAAL_PATH=%_TRAVIS_BUILD_DIR%"

set _MX_URL=https://github.com/graalvm/mx.git
set "_MX_PATH=%_ROOT_DIR%\mx"

set "_GIT_CMD=%GIT_HOME%\bin\git.exe"
set _GIT_OPTS=

set "_MX_CMD=%_MX_PATH%\mx.cmd"
set _MX_OPTS=

if not exist "%GIT_HOME%\usr\bin\tar.exe" (
    echo %_ERROR_LABEL% Git installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_TAR_CMD=%GIT_HOME%\usr\bin\tar.exe"

@rem see https://github.com/graalvm/openjdk8-jvmci-builder/releases
set _JVMCI_VERSION=jvmci-20.2-b03
set _JDK8_UPDATE_VERSION=262
set _JDK8_UPDATE_VERSION_SUFFIX=
@rem rule: <os_name>-<os_arch>, eg. darwin-amd64, linux-amd64, windows-amd64
set _JDK8_PLATFORM=windows-amd64
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

@rem output parameters: _INI, _INI_N
@rem see https://en.wikipedia.org/wiki/INI_file
@rem - properties: name=value
@rem - sections  : [section]
@rem - comments  : ; commented text
:props
set "__INI_FILE=%_GRAAL_PATH%%_BASENAME%.ini"
if not exist "%__INI_FILE%" goto :eof

set _INI=
set _INI_N=0
set __SECTION=global
for /f "delims=" %%f in (%__INI_FILE%) do (
    set __LINE=%%f
    if "!__LINE:~0,1!"==";" (
        @rem ignore comment
    ) else if "!__LINE:~0,1!"=="[" (
        if not "!__LINE:~-1!"=="]" (
            echo %_ERROR_LABEL% Section name must end with ']' in .ini file 1>&2
            set _EXITCODE=1
        )
        @rem section start/end
        set __SECTION=!__LINE:~1,-1!
        set /a _INI_N+=1
        set _INI[!_INI_N!]=!__SECTION!
    ) else (
        for /f "delims=^= tokens=1,*" %%i in ("!__LINE!") do (
            set !__SECTION![%%i]=%%~j
        )
    )
)
@rem properties defined outside a section are put into 'global'.
set /a _INI_N+=1
set _INI[%_INI_N%]=global
goto :eof

@rem input parameter: %*
@rem output paramter(s): _CLEAN, _DIST, _DIST_ENV, _HELP, _UPDATE, _VERBOSE
:args
set _CLEAN=0
set _DIST=0
set _DIST_ENV=env2
set _HELP=0
set _TIMER=0
set _UPDATE=0
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
    if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if "%__ARG%"=="dist" ( set _DIST=1
    ) else if "%__ARG%"=="help" ( set _HELP=1
    ) else if "%__ARG%"=="update" ( set _UPDATE=1
    ) else if "%__ARG:~0,5%"=="dist:" (
        set /a "__N_MAX=_INI_N-1"
        set /a "__N=%__ARG:~5%+0"
        if 1 leq !__N! if !__N! leq !__N_MAX! (
            set _DIST=1
            set "_DIST_ENV=env!__N!"
        ) else (
            echo %_ERROR_LABEL% Invalid environment ID !__N! ^(1..!__N_MAX!^) 1>&2
            set _EXITCODE=1
            goto args_done
        )
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
if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _DIST=%_DIST% _DIST_ENV=%_DIST_ENV% _UPDATE=%_UPDATE% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
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
set /a "__N_MAX=_INI_N-1"
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-debug%__END%       show commands executed by this batch file
echo     %__BEG_O%-timer%__END%       display total elapsed time
echo     %__BEG_O%-verbose%__END%     display progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%        delete generated files
echo     %__BEG_O%dist[:^<n^>]%__END%   generate distribution with environment n=1-%__N_MAX% ^(default=2^)
echo                  ^(see environment definitions in file %__BEG_O%build.ini%__END%^)
echo     %__BEG_O%help%__END%         display this help message
echo     %__BEG_O%update%__END%       fetch/merge local directories graal/mx
goto :eof

:clean
call :rmdir "%_TMP_DIR%"
for /f %%d in ('dir /ad /b "%_GRAAL_PATH%\CompilationWrapperTest_*" 2^>NUL') do (
    call :rmdir "%_GRAAL_PATH%\%%d"
)
for /f %%d in ('dir /ad /b "%_GRAAL_PATH%\DumpPathTest*" 2^>NUL') do (
    call :rmdir "%_GRAAL_PATH%\%%d"
)
for /f %%f in ('dir /a-d /b "%_GRAAL_PATH%\hs_err_pid*.log" 2^>NUL') do (
    call :del "%_GRAAL_PATH%\%%f"
)
@rem workaround: mx tool has troubles with long file paths on Windows.
if exist "%_GRAAL_PATH%\truffle\mxbuild\src" (
    call :rmdir "%_GRAAL_PATH%\truffle\mxbuild\src"
)
goto :eof

:rmdir
set "__DIR=%~1"
if not exist "%__DIR%\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Remove directory "!__DIR:%_ROOT_DIR%\=!" 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:del
set "__FILE=%~1"
if not exist "%__FILE%" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% del /q "%__FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Remove file "!__FILE:%_ROOT_DIR%\=!" 1>&2
)
del /q "%__FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:update
call :update_graal
if not %_EXITCODE%==0 goto :eof

call :update_mx
if not %_EXITCODE%==0 goto :eof
goto :eof

:update_graal
if not exist "%_GRAAL_PATH%\.travis.yml" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is "%_GRAAL_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Current directory is "!_GRAAL_PATH:%_ROOT_DIR%=!" 1>&2
)
pushd "%_GRAAL_PATH%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GIT_CMD%" %_GIT_OPTS% fetch upstream master 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update local directory %_GRAAL_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% fetch upstream master
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GIT_CMD%" %_GIT_OPTS% merge upstream/master 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update local directory %_GRAAL_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% merge upstream/master
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:update_mx
if not exist "%_MX_CMD%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is "%_MX_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Current directory is "!_MX_PATH:%_ROOT_DIR%=!" 1>&2
)
pushd "%_MX_PATH%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% fetch 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update MX suite repository into directory %_MX_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% fetch
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_GIT_CMD% %_GIT_OPTS% merge 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update MX suite repository into directory %_MX_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% merge
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:clone
call :clone_graal
if not %_EXITCODE%==0 goto :eof

call :clone_mx
if not %_EXITCODE%==0 goto :eof
goto :eof

:clone_graal
if exist "%_GRAAL_PATH%\.travis.yml" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GIT_CMD%" %_GIT_OPTS% clone %_GRAAL_URL% %_GRAAL_PATH% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Clone Graal repository into directory %_GRAAL_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% clone "%_GRAAL_URL%" "%_GRAAL_PATH%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to clone graal remote Git repository 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_GRAAL_HOME%\.travis.yml" (
    echo %_ERROR_LABEL% Travis configuration file not found ^(%_GRAAL_PATH%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:clone_mx
if exist "%_MX_CMD%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GIT_CMD%" %_GIT_OPTS% clone %_MX_URL% %_MX_PATH% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Clone MX suite repository into directory %_MX_PATH% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% clone "%_MX_URL%" "%_MX_PATH%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if not exist "%_MX_CMD%" (
    echo %_ERROR_LABEL% MX command not found ^(%_MX_PATH%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem depends on :dist_env
:style
if "%GATE:style=%"=="%GATE%" goto :eof

set "__TGZ_URL=https://archive.eclipse.org/eclipse/downloads/drops4/R-4.5.2-201602121500/eclipse-SDK-4.5.2-linux-gtk-x86_64.tar.gz"
set "__TGZ_FILE=%_ROOT_DIR%eclipse.tar.gz"
if exist "%__TGZ_FILE%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -C "wget -OutFile '%__TGZ_FILE%' -Uri '%__TGZ_URL%'" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Download Eclipse JDT archive to directory %_MX_PATH% 1>&2
)
powershell -C "$progressPreference='silentlyContinue'; wget -OutFile '%__TGZ_FILE%' -Uri '%__TGZ_URL%'"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)

goto :eof

@rem depends on :dist_env
:fullbuild
if "%GATE:fullbuild=%"=="%GATE%" goto :eof
if not %JDK%==jdk8 goto :eof

set "__JAR_URL=https://archive.eclipse.org/eclipse/downloads/drops4/R-4.5.2-201602121500/ecj-4.5.2.jar"
set "__JAR_FILE=%_MX_PATH%\ecj.jar"
if exist "%__JAR_FILE%" goto fullbuild_done

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -C "wget -OutFile '%__JAR_FILE%' -Uri '%__JAR_URL%'" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Download Eclipse JDT archive to directory %_MX_PATH% 1>&2
)
powershell -C "$progressPreference='silentlyContinue'; wget -OutFile '%__JAR_FILE%' -Uri '%__JAR_URL%'"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
:fullbuild_done
set "JDT=%__JAR_FILE%"
goto :eof

@rem depends on :dist_env
:jvmci
if not %JDK%==jdk8 goto :eof

set "__JDK_INSTALL_NAME=openjdk1.8.0_%_JDK8_UPDATE_VERSION%-%_JVMCI_VERSION%"
set "__JDK_TGZ_NAME=openjdk-8u%_JDK8_UPDATE_VERSION%%_JDK8_UPDATE_VERSION_SUFFIX%-%_JVMCI_VERSION%-%_JDK8_PLATFORM%.tar.gz"
set "__JDK_TGZ_URL=https://github.com/graalvm/openjdk8-jvmci-builder/releases/download/%_JVMCI_VERSION%/%__JDK_TGZ_NAME%"
set "__JDK_TGZ_FILE=%_ROOT_DIR%\%__JDK_TGZ_NAME%"

if exist "%_ROOT_DIR%\%__JDK_INSTALL_NAME%\" goto jvmci_done
if exist "%__JDK_TGZ_FILE%" goto jvmci_extract

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -C "wget -OutFile '%__JDK_TGZ_FILE%' -Uri '%__JDK_TGZ_URL%'" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Download OpenJDK 8 archive to directory %_ROOT_DIR% 1>&2
)
powershell -C "$progressPreference='silentlyContinue'; wget -OutFile '%__JDK_TGZ_FILE%' -Uri '%__JDK_TGZ_URL%'"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
:jvmci_extract
if not exist "%_TMP_DIR%" mkdir "%_TMP_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_TAR_CMD%" -C "%_TMP_DIR%" -xf "%__JDK_TGZ_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Extract archive %__JDK_TGZ_FILE% into directory %_ROOT_DIR% 1>&2
)
@rem NB. tar on Windows dislike it when <dir1>=<dir2>, given -xf <dir2>\*.tar.gz and -C <dir1>
call "%_TAR_CMD%" -C "%_TMP_DIR%" -xf "%__JDK_TGZ_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% move "%_TMP_DIR%\"%__JDK_INSTALL_NAME%" "%_ROOT_DIR%\" 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Move JDK installation directory to directory %_ROOT_DIR% 1>&2
)
move "%_TMP_DIR%\%__JDK_INSTALL_NAME%" "%_ROOT_DIR%\" 1>NUL
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
:jvmci_done
set "JAVA_HOME=%_ROOT_DIR%\%__JDK_INSTALL_NAME%"
goto :eof

:dist
setlocal
call :dist_env

set "__PRIMARY_PATH=%_TRAVIS_BUILD_DIR%\%PRIMARY%"
if not exist "%__PRIMARY_PATH%" (
    echo %_ERROR_LABEL% Primary directory not found ^(%PRIMARY%^) 1>&2
    set _EXITCODE=1
    goto dist_done
)
call :style
if not %_EXITCODE%==0 goto dist_done

call :fullbuild
if not %_EXITCODE%==0 goto dist_done

call :jvmci
if not %_EXITCODE%==0 goto dist_done

echo %JAVA_HOME%
call "%JAVA_HOME%\bin\java.exe" -version

if %_DEBUG%==1 ( set __MX_OPTS=-V %_MX_OPTS%
) else if %_VERBOSE%==1 ( set __MX_OPTS=-v %_MX_OPTS%
) else ( set __MX_OPTS=%_MX_OPTS%
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MX_CMD%" %__MX_OPTS% --primary-suite-path %PRIMARY% --java-home=%JAVA_HOME% gate --strict-mode --tags %GATE% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Create GraalVM build with tags %GATE% 1>&2
)
call "%_MX_CMD%" %__MX_OPTS% --primary-suite-path "%PRIMARY%" --java-home=%JAVA_HOME% gate --strict-mode --tags %GATE%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto dist_done
)
:dist_done
endlocal
goto :eof

@rem Defined variables are local to subroutine dist
:dist_env
call :dist_env_ini
if "%JDK%"=="jdk11" set JAVA_HOME=%JAVA11_HOME%

call :dist_env_msvc
@rem call :dist_env_msvc2019

@rem Official LLVM variables: https://llvm.org/docs/CMake.html#llvm-specific-variables
if defined LLVM_VERSION (
    set CLANG=clang-%LLVM_VERSION%.exe
    set CLANGXX=clang++-%LLVM_VERSION%.exe
    set OPT=opt-%LLVM_VERSION%.exe
    set LLVM_AS=llvm-as-%LLVM_VERSION%.exe
    set LLVM_LINK=llvm-link-%LLVM_VERSION%.exe
) else (
    set CLANG=clang.exe
    set CLANGXX=clang++.exe
    set OPT=opt.exe
    set LLVM_AS=llvm-as.exe
    set LLVM_LINK=llvm-link.exe
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% ===== B U I L D   V A R I A B L E S ===== 1>&2
    echo %_DEBUG_LABEL% JAVA_HOME="%JAVA_HOME%" 1>&2
    echo %_DEBUG_LABEL% INCLUDE="%INCLUDE%" 1>&2
    echo %_DEBUG_LABEL% LIB="%LIB%" 1>&2
    echo %_DEBUG_LABEL% LIBPATH="%LIBPATH%" 1>&2
    echo %_DEBUG_LABEL% ========================================= 1>&2
)
goto :eof

@rem both _INI and _INI_N are defined in subroutine :ini
:dist_env_ini
for /l %%i in (1, 1, %_INI_N%) do (
    set __SECTION=!_INI[%%i]!
    if "!__SECTION!"=="%_DIST_ENV%" (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% _SECTION=!__SECTION!
        for %%s in (!__SECTION!) do (
            set JDK=!%%s[JDK]!
            set GATE=!%%s[GATE]!
            set PRIMARY=!%%s[PRIMARY]!
            set DYNAMIC_IMPORTS=!%%s[DYNAMIC_IMPORTS]!
            set LLVM_VERSION=!%%s[LLVM_VERSION]!
            set DISABLE_POLYGLOT=!%%s[DISABLE_POLYGLOT]!
            set DISABLE_LIBPOLYGLOT=!%%s[DISABLE_LIBPOLYGLOT]!
            set NO_FEMBED_BITCODE=!%%s[NO_FEMBED_BITCODE]!
        )
    )
)
goto :eof

:dist_env_msvc
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set __MSVC_LIB=Lib\amd64
    set __NET_FRAMEWORK=Framework64\v4.0.30319
    set __SDK_LIB=lib\x64
    set __KIT_UCRT=ucrt\x64
) else (
    set __MSVC_LIB=Lib\x86
    set __NET_FRAMEWORK=Framework\v4.0.30319
    set __SDK_LIB=lib
    set __KIT_UCRT=ucrt\x86
)
@rem Variables MSVC_HOME, MSVS_HOME and SDK_HOME are defined by setenv.bat
set "INCLUDE=%MSVC_HOME%\include;%SDK_HOME%\include;%KIT_INC_DIR%\ucrt"
set "LIB=%MSVC_HOME%\%__MSVC_LIB%;%SDK_HOME%\%__SDK_LIB%;%KIT_LIB_DIR%\%__KIT_UCRT%"
set "LIBPATH=c:\WINDOWS\Microsoft.NET\%__NET_FRAMEWORK%;%MSVC_HOME%\%__MSVC_LIB%;%KIT_LIB_DIR%\%__KIT_UCRT%"
goto :eof

:dist_env_msvc2019
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set __MSVC_LIB=Lib\amd64
    set __NET_FRAMEWORK=Framework64\v4.0.30319
    set __SDK_LIB=lib\x64
    set __KIT_UCRT=ucrt\x66
) else (
    set __MSVC_LIB=Lib\x86
    set __NET_FRAMEWORK=Framework\v4.0.30319
    set __SDK_LIB=lib
    set __KIT_UCRT=ucrt\x86
)

@rem TODO Change hard-coded path
set "__MSVC_2019=%ProgramFiles(x86)%\MIB055~1\2019\COMMUN~1\VC\Tools\MSVC\1422~1.279\"

@rem Variables MSVC_HOME, MSVS_HOME and SDK_HOME are defined by setenv.bat
set "INCLUDE=%__MSVC_2019%\include;%SDK_HOME%\include;%KIT_INC_DIR%\ucrt"
set "LIB=%__MSVC_2019%\%__MSVC_LIB%;%SDK_HOME%\%__SDK_LIB%;%KIT_LIB_DIR%\%__KIT_UCRT%"
set "LIBPATH=c:\WINDOWS\Microsoft.NET\%__NET_FRAMEWORK%;%__MSVC_2019%\%__MSVC_LIB%;%KIT_LIB_DIR%\%__KIT_UCRT%"
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
