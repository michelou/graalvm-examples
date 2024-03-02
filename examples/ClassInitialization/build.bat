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
if %_LINT%==1 (
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
if %_DOC%==1 (
    call :doc
    if not !_EXITCODE!==0 goto end
)
if %_PACK%==1 (
    call :pack
    if not !_EXITCODE!==0 goto end
)
if %_RUN%==1 (
    call :run_%_TARGET%
    if not !_EXITCODE!==0 goto end
)
if %_TEST%==1 (
    call :test_%_TARGET%
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"
set _TIMER=0

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "_SOURCE_DIR=%_ROOT_DIR%src"
set "_TARGET_DIR=%_ROOT_DIR%target"
set "_CLASSES_DIR=%_TARGET_DIR%\classes"
set "_TARGET_DOCS_DIR=%_TARGET_DIR%\docs"
set "_TEST_CLASSES_DIR=%_TARGET_DIR%\test-classes"

set _PKG_NAME=org.graalvm.example
@rem both _MAIN_NAME and _MAIN_NATIVE_FILE are defined in args (option -native)

set "_BENCH_JAR_FILE=%_TARGET_DIR%\benchmarks.jar"

if not exist "%GRAALVM_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% GraalVM installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_JAR_CMD=%GRAALVM_HOME%\bin\jar.exe"
set "_JAVA_CMD=%GRAALVM_HOME%\bin\java.exe"
set "_JAVAC_CMD=%GRAALVM_HOME%\bin\javac.exe"
set "_JAVADOC_CMD=%GRAALVM_HOME%\bin\javadoc.exe"

if not exist "%MSVS_HOME%\VC\Auxiliary\Build\vcvarsall.bat" (
    echo %_ERROR_LABEL% MSVS installation not found 1>&2
    echo %_ERROR_LABEL% ^(MSVS_HOME="%MSVS_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_VCVARALL_BAT=%MSVS_HOME%\VC\Auxiliary\Build\vcvarsall.bat"

if not exist "%GRAALVM_HOME%\bin\native-image.cmd" (
    echo %_ERROR_LABEL% GraalVM omponent 'native-image' not installed 1>&2
    echo %_ERROR_LABEL% ^(GRAALVM="%GRAALVM_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_NATIVE_IMAGE_CMD=%GRAALVM_HOME%\bin\native-image.cmd"
set "_LLI_CMD=%GRAALVM_HOME%\lib\llvm\bin\lli.exe"
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

@rem output parameters: _CHECKSTYLE_VERSION
:props
@rem value may be overwritten if file build.properties exists
set _CHECKSTYLE_VERSION=10.12.4

for %%i in ("%~dp0\.") do set "_PROJECT_NAME=%%~ni"
set _PROJECT_URL=github.com/%USERNAME%/graalvm-examples
set _PROJECT_VERSION=1.0-SNAPSHOT

set "__PROPS_FILE=%_ROOT_DIR%build.properties"
if exist "%__PROPS_FILE%" (
    for /f "tokens=1,* delims==" %%i in (%__PROPS_FILE%) do (
        set __NAME=
        set __VALUE=
        for /f "delims= " %%n in ("%%i") do set __NAME=%%n
        @rem line comments start with "#"
        if defined __NAME if not "!__NAME:~0,1!"=="#" (
            @rem trim value
            for /f "tokens=*" %%v in ("%%~j") do set __VALUE=%%v
            set "_!__NAME:.=_!=!__VALUE!"
        )
    )
    if defined _checkstyle_version set _CHECKSTYLE_VERSION=!_checkstyle_version!
    if defined _project_name set _PROJECT_NAME=!_project_name!
    if defined _project_url set _PROJECT_URL=!_project_url!
    if defined _project_version set _PROJECT_VERSION=!_project_version!
)
goto :eof

@rem input parameter %*
:args
set _CACHED=0
set _CLEAN=0
set _COMPILE=0
set _DOC=0
set _HELP=0
set _JVMCI=0
set _LINT=0
set _PACK=0
set _RUN=0
set _TARGET=jvm
set _TEST=0
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
    if "%__ARG%"=="-cached" ( set _CACHED=1
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-jvmci" ( set _JVMCI=1
    ) else if "%__ARG%"=="-native" ( set _TARGET=native
    ) else if "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if "%__ARG%"=="doc" ( set _DOC=1
    ) else if "%__ARG%"=="help" ( set _HELP=1
    ) else if "%__ARG%"=="lint" ( set _LINT=1
    ) else if "%__ARG%"=="pack" ( set _COMPILE=1& set _PACK=1
    ) else if "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else if "%__ARG%"=="test" ( set _COMPILE=1& set _PACK=1& set _TEST=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto args_loop
:args_done
set _STDOUT_REDIRECT=1^>CON
if %_DEBUG%==0 if %_VERBOSE%==0 set _STDOUT_REDIRECT=1^>NUL

if %_CACHED%==1 ( set _MAIN_NAME=HelloCachedTime
) else ( set _MAIN_NAME=HelloStartupTime
)
if defined _PKG_NAME ( set _MAIN_CLASS=%_PKG_NAME%.%_MAIN_NAME%
) else ( set _MAIN_CLASS=%_MAIN_NAME%
)
set "_MAIN_NATIVE_FILE=%_TARGET_DIR%\%_MAIN_NAME%"

if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Properties : _PROJECT_NAME=%_PROJECT_NAME% _PROJECT_VERSION=%_PROJECT_VERSION% 1>&2
    echo %_DEBUG_LABEL% Options    : _CACHED=%_CACHED% _TARGET=%_TARGET% _TIMER=%_TIMER% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _DOC=%_DOC% _LINT=%_LINT% _PACK=%_PACK% _RUN=%_RUN% _TEST=%_TEST% 1>&2
    echo %_DEBUG_LABEL% Variables  : "GRAALVM_HOME=%GRAALVM_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "JAVA_HOME=%JAVA_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "LLVM_HOME=%LLVM_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "MSVS_HOME=%MSVS_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : _MAIN_CLASS=%_MAIN_CLASS% 1>&2
)
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%
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
echo     %__BEG_O%-cached%__END%     select main class with cached startup time
echo     %__BEG_O%-debug%__END%      print commands executed by this script
echo     %__BEG_O%-jvmci%__END%      add JVMCI options
echo     %__BEG_O%-native%__END%     generate both JVM files and native image
echo     %__BEG_O%-timer%__END%      print total execution time
echo     %__BEG_O%-verbose%__END%    print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%       delete generated files
echo     %__BEG_O%compile%__END%     compile Java source files
echo     %__BEG_O%doc%__END%         generate HTML documentation
echo     %__BEG_O%help%__END%        print this help message
echo     %__BEG_O%lint%__END%        analyze Java source files with %__BEG_N%CheckStyle%__END%
echo     %__BEG_O%run%__END%         execute main program "%__BEG_O%%_MAIN_CLASS%%__END%"
echo     %__BEG_O%test%__END%        execute JMH benchmarks
if %_VERBOSE%==0 goto :eof
echo.
echo   %__BEG_P%Generation of native image%__END% ^(option %__BEG_O%-native%__END%^):
echo     Command %__BEG_O%native-image.cmd%__END% is part of the GraalVM distribution;
echo     it relies on the two environment variables %__BEG_O%INCLUDE%__END% and %__BEG_O%LIB%__END%
echo     to access header/library files from the software tools
echo     %__BEG_N%Microsoft Visual Studio 10%_RESET% and %__BEG_N%Microsoft Windows SDK 7.1%__END%.
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

@rem input parameter: %1=directory path
:rmdir
set "__DIR=%~1"
if not exist "%__DIR%\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem see https://github.com/checkstyle/checkstyle/releases/
:checkstyle
set "__CHECKSTYLE_DIR=%USERPROFILE%\.graal"
if not exist "%__CHECKSTYLE_DIR%" mkdir "%__CHECKSTYLE_DIR%"

set "__XML_FILE=%__CHECKSTYLE_DIR%\graal_checks.xml"
if not exist "%__XML_FILE%" call :checkstyle_xml "%__XML_FILE%"

@rem "checkstyle-all" version not available from Maven Central
set __JAR_NAME=checkstyle-%_CHECKSTYLE_VERSION%-all.jar
set __JAR_URL=https://github.com/checkstyle/checkstyle/releases/download/checkstyle-%_CHECKSTYLE_VERSION%/%__JAR_NAME%
set "__JAR_FILE=%__CHECKSTYLE_DIR%\%__JAR_NAME%"
if exist "%__JAR_FILE%" goto checkstyle_analyze

set "__PS1_FILE=%__CHECKSTYLE_DIR%\webrequest.ps1"
if not exist "%__PS1_FILE%" call :checkstyle_ps1 "%__PS1_FILE%"

set __PS1_VERBOSE[0]=
set __PS1_VERBOSE[1]=-Verbose
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "& '%__PS1_FILE%' -Uri '%__JAR_URL%' -Outfile '%__JAR_FILE%'" 1>&2
) else if %_VERBOSE%==1 ( echo Download file "%__JAR_NAME%" 1>&2
)
powershell -c "& '%__PS1_FILE%' -Uri '%__JAR_URL%' -OutFile '%__JAR_FILE%' !__PS1_VERBOSE[%_VERBOSE%]!"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to download file "%__JAR_NAME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
:checkstyle_analyze
set __SOURCE_FILES=
set __N=0
for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%\main\java" *.java 2^>NUL') do (
    set __SOURCE_FILES=!__SOURCE_FILES! "%%f"
    set /a __N+=1
)
for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%\test\java" *.java 2^>NUL') do (
    set __SOURCE_FILES=!__SOURCE_FILES! "%%f"
    set /a __N+=1
)
if not defined __SOURCE_FILES (
    echo %_WARNING_LABEL% No Java source file found 1>&2
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVA_CMD%" -jar "%__JAR_FILE%" -c="%__XML_FILE%" %__SOURCE_FILES% 1>&2
) else if %_VERBOSE%==1 ( echo Analyze %__N% Java source files with CheckStyle configuration "!__XML_FILE:%USERPROFILE%=%%USERPROFILE%%%!" 1>&2
)
call "%_JAVA_CMD%" -jar "%__JAR_FILE%" -c="%__XML_FILE%" %__SOURCE_FILES%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile
if not exist "%_CLASSES_DIR%" mkdir "%_CLASSES_DIR%" 1>NUL

set "__TIMESTAMP_FILE=%_CLASSES_DIR%\.latest-build"

call :action_required "%__TIMESTAMP_FILE%" "%_SOURCE_DIR%\main\java\*.java" "%_SOURCE_DIR%\main\resources\*"
if %_ACTION_REQUIRED%==0 goto :eof

call :compile_java
if not %_EXITCODE%==0 goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% xcopy /y /s "%_SOURCE_DIR%\main\resources\*" "%_CLASSES_DIR%\" 1>&2
) else if %_VERBOSE%==1 ( echo Copy resource files to directory "!_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
)
if exist "%_SOURCE_DIR%\main\resources\*" (
    xcopy /y /s "%_SOURCE_DIR%\main\resources\*" "%_CLASSES_DIR%\" 1>NUL
    if not !ERRORLEVEL!==0 (
        echo %_ERROR_LABEL% Failed to copy resource files to directory "!_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
        set _EXITCODE=1
        goto :eof
    )
)
echo. > "%__TIMESTAMP_FILE%"
goto :eof

:compile_java
set "__OPTS_FILE=%_TARGET_DIR%\javac_opts.txt"
set "__CPATH=%_CLASSES_DIR%"
echo -deprecation -cp "%__CPATH:\=\\%" -d "%_CLASSES_DIR:\=\\%"> "%__OPTS_FILE%"

set "__SOURCES_FILE=%_TARGET_DIR%\javac_sources.txt"
if exist "%__SOURCES_FILE%" del "%__SOURCES_FILE%"
set __N=0
for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%\main\java" *.java') do (
    echo %%f>> "%__SOURCES_FILE%"
    set /a __N+=1
)
if %__N%==0 (
    echo %_WARNING_LABEL% No Java soure file found 1>&2
    goto :eof
) else if %__N%==1 ( set __N_FILES=%__N% Java source file
) else ( set __N_FILES=%__N% Java source files
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVAC_CMD%" "@%__OPTS_FILE%" "@%__SOURCES_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Compile %__N_FILES% to directory "!_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_JAVAC_CMD%" "@%__OPTS_FILE%" "@%__SOURCES_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to compile %__N_FILES% to directory "!_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem input parameter: 1=target file 2,3,..=path (wildcards accepted)
@rem output parameter: _ACTION_REQUIRED
:action_required
set "__TARGET_FILE=%~1"

set __PATH_ARRAY=
set __PATH_ARRAY1=
:action_path
shift
set "__PATH=%~1"
if not defined __PATH goto action_next
if defined __PATH_ARRAY set "__PATH_ARRAY=%__PATH_ARRAY%,"
set __PATH_ARRAY=%__PATH_ARRAY%'%__PATH%'
if defined __PATH_ARRAY1 set "__PATH_ARRAY1=%__PATH_ARRAY1%,"
set __PATH_ARRAY1=%__PATH_ARRAY1%'!__PATH:%_ROOT_DIR%=!'
goto action_path

:action_next
set __TARGET_TIMESTAMP=00000000000000
for /f "usebackq" %%i in (`powershell -c "gci -path '%__TARGET_FILE%' -ea Stop | select -last 1 -expandProperty LastWriteTime | Get-Date -uformat %%Y%%m%%d%%H%%M%%S" 2^>NUL`) do (
     set __TARGET_TIMESTAMP=%%i
)
set __SOURCE_TIMESTAMP=00000000000000
for /f "usebackq" %%i in (`powershell -c "$files=@(gci -recurse -path %__PATH_ARRAY% -ea SilentlyContinue); if($files.length -eq 0){exit}; $files | sort LastWriteTime | select -last 1 -expandProperty LastWriteTime | Get-Date -uformat %%Y%%m%%d%%H%%M%%S" 2^>NUL`) do (
    set __SOURCE_TIMESTAMP=%%i
)
call :newer %__SOURCE_TIMESTAMP% %__TARGET_TIMESTAMP%
set _ACTION_REQUIRED=%_NEWER%
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% %__TARGET_TIMESTAMP% Target : '!__TARGET_FILE:%_ROOT_DIR%=!' 1>&2
    echo %_DEBUG_LABEL% %__SOURCE_TIMESTAMP% Sources: %__PATH_ARRAY1% 1>&2
    echo %_DEBUG_LABEL% _ACTION_REQUIRED=%_ACTION_REQUIRED% 1>&2
) else if %_VERBOSE%==1 if %_ACTION_REQUIRED%==0 if %__SOURCE_TIMESTAMP% gtr 0 (
    echo No action required ^(%__PATH_ARRAY1%^) 1>&2
)
goto :eof

@rem output parameter: _NEWER
:newer
set __TIMESTAMP1=%~1
set __TIMESTAMP2=%~2

set __DATE1=%__TIMESTAMP1:~0,8%
set __TIME1=%__TIMESTAMP1:~-6%

set __DATE2=%__TIMESTAMP2:~0,8%
set __TIME2=%__TIMESTAMP2:~-6%

if %__DATE1% gtr %__DATE2% ( set _NEWER=1
) else if %__DATE1% lss %__DATE2% ( set _NEWER=0
) else if %__TIME1% gtr %__TIME2% ( set _NEWER=1
) else ( set _NEWER=0
)
goto :eof

@rem output parameter: _LIBS_CPATH
:libs_cpath
for %%f in ("%~dp0\.") do set "__BATCH_FILE=%%~dpfcpath.bat"
if not exist "%__BATCH_FILE%" (
    echo %_ERROR_LABEL% Batch file "%__BATCH_FILE%" not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% "%__BATCH_FILE%" %_DEBUG% 1>&2
call "%__BATCH_FILE%" %_DEBUG%
set "_LIBS_CPATH=%_CPATH%"
goto :eof

:doc
if not exist "%_TARGET_DOCS_DIR%" mkdir "%_TARGET_DOCS_DIR%" 1>NUL

call :action_required "%_TARGET_DOCS_DIR%\index.html" "%_SOURCE_DIR%\main\java\*.java"
if %_ACTION_REQUIRED%==0 goto :eof

set "__SOURCES_FILE=%_TARGET_DIR%\javadoc_sources.txt"
for /f %%i in ('dir /s /b "%_SOURCE_DIR%\main\java\*.java" 2^>NUL') do (
    echo %%i>> "%__SOURCES_FILE%"
)
set "__OPTS_FILE=%_TARGET_DIR%\javadoc_opts.txt"
echo -d "%_TARGET_DOCS_DIR:\=\\%" -doctitle "%_PROJECT_NAME%" -footer "%_PROJECT_URL%" -top "%_PROJECT_VERSION%" > "%__OPTS_FILE%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVADOC_CMD%" "@%__OPTS_FILE%" "@%__SOURCES_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Generate HTML documentation into directory "!_TARGET_DOCS_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_JAVADOC_CMD%" "@%__OPTS_FILE%" "@%__SOURCES_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to generate HTML documentation into directory "!_TARGET_DOCS_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:native_image
setlocal
if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_VCVARALL_BAT%" x64 1>&2
call "%_VCVARALL_BAT%" x64
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% INCLUDE="%INCLUDE%" 1>&2
    echo %_DEBUG_LABEL% LIB="%LIB%" 1>&2
    echo %_DEBUG_LABEL% LIBPATH="%LIBPATH%" 1>&2
)
if exist "%_MAIN_NATIVE_FILE%.exe" del "%_MAIN_NATIVE_FILE%.*"

set __NATIVE_IMAGE_OPTS=-cp "%_CLASSES_DIR%" --no-fallback
set __NATIVE_IMAGE_OPTS=%__NATIVE_IMAGE_OPTS% "--initialize-at-build-time=%_PKG_NAME%" "--initialize-at-run-time=%_PKG_NAME%.Startup"
if %_CACHED%==1 set __NATIVE_IMAGE_OPTS=--initialize-at-run-time=%_MAIN_CLASS% %__NATIVE_IMAGE_OPTS%
if %_DEBUG%==1 set __NATIVE_IMAGE_OPTS=--trace-class-initialization %__NATIVE_IMAGE_OPTS%

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_NATIVE_IMAGE_CMD%" %__NATIVE_IMAGE_OPTS% %_MAIN_CLASS% "%_MAIN_NATIVE_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Create native image "!_MAIN_NATIVE_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%_NATIVE_IMAGE_CMD%" %__NATIVE_IMAGE_OPTS% %_MAIN_CLASS% "%_MAIN_NATIVE_FILE%" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    endlocal
    echo %_ERROR_LABEL% Failed to create native image "!_MAIN_NATIVE_FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
endlocal
goto :eof

:pack
call :action_required "%_TARGET_DIR%\%_PROJECT_NAME%.jar" "%_SOURCE_DIR%\main\java\*.java" "%_SOURCE_DIR%\main\resources\*"
if %_ACTION_REQUIRED%==0 goto :eof

set "__MANIFEST_FILE=%_TARGET_DIR%\manifest.txt"
(
    echo Manifest-Version: 1.0
    echo Main-Class: %_MAIN_CLASS%
) > "%__MANIFEST_FILE%"

set __JAR_OPTS=cfm "%_TARGET_DIR%\%_PROJECT_NAME%.jar" "%__MANIFEST_FILE%" -C "%_CLASSES_DIR%" .

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAR_CMD%" %__JAR_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Create Java archive into directory "!__TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_JAR_CMD%" %__JAR_OPTS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to create Java archive into directory "!__TARGET_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run_jvm
set __MAIN_ARGS=

set __JAVA_OPTS=-cp "%_CLASSES_DIR%"
if %_DEBUG%==1 (
    set "__GRAAL_LOG_FILE=%_TARGET_DIR%\graal_log.txt"
    set __JAVA_OPTS=%__JAVA_OPTS% -Dgraal.ShowConfiguration=info -Dgraal.PrintCompilation=true -Dgraal.LogFile="!__GRAAL_LOG_FILE!"
)
if %_JVMCI%==1 (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% GraalVM compiler is disabled 1>&2
    ) else if %_VERBOSE%==1 ( echo GraalVM compiler is disabled 1>&2
    )
    set __JAVA_OPTS=%__JAVA_OPTS% -XX:-UseJVMCICompiler
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVA_CMD%" %__JAVA_OPTS% %_MAIN_CLASS% %__MAIN_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute Java main class %_MAIN_CLASS% %__MAIN_ARGS% 1>&2
)
call "%_JAVA_CMD%" %__JAVA_OPTS% %_MAIN_CLASS% %__MAIN_ARGS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to execute Java main class %_MAIN_CLASS% %__MAIN_ARGS% 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 if exist "%__GRAAL_LOG_FILE%" (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Compilation log written to file "%__GRAAL_LOG_FILE%" 1>&2
    ) else if %_VERBOSE%==1 ( echo Compilation log written to file "!__GRAAL_LOG_FILE:%_ROOT_DIR%=!" 1>&2
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
) else if %_VERBOSE%==1 ( echo Execute JMH benchmark "!__EXE_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to execute JMH benchmark "!__EXE_FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_jvm
call :test_compile
if not %_EXITCODE%==0 goto end

call :test_pack
if not %_EXITCODE%==0 goto end

set __TEST_JAVA_OPTS=-Xmx1G -jar "%_BENCH_JAR_FILE%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVA_CMD%" %__TEST_JAVA_OPTS% startupTime 1>&2
) else if %_VERBOSE%==1 ( echo Execute JMH benchmark ^(JVM^) 1>&2
)
@rem call "%_JAVA_CMD%" %__TEST_JAVA_OPTS% cachedTime
call "%_JAVA_CMD%" %__TEST_JAVA_OPTS% startupTime
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_compile
if not exist "%_TEST_CLASSES_DIR%" mkdir "%_TEST_CLASSES_DIR%" 1>NUL

set "__TEST_TIMESTAMP_FILE=%_TEST_CLASSES_DIR%\.latest-build"

call :action_required "%__TEST_TIMESTAMP_FILE%" "%_SOURCE_DIR%\test\java\*.java"
if %_ACTION_REQUIRED%==0 goto :eof

call :test_compile_java
if not %_EXITCODE%==0 goto :eof

echo. > "%__TEST_TIMESTAMP_FILE%"
goto :eof

:test_compile_java
call :libs_cpath
if not %_EXITCODE%==0 goto :eof

set "__TEST_OPTS_FILE=%_TARGET_DIR%\test_javac_opts.txt"
set "__CPATH=%_LIBS_CPATH%;%_CLASSES_DIR%;%_TEST_CLASSES_DIR%"
echo -cp "%__CPATH:\=\\%" -d "%_TEST_CLASSES_DIR:\=\\%" > "%__TEST_OPTS_FILE%"

set "__TEST_SOURCES_FILE=%_TARGET_DIR%\test_javac_sources.txt"
if exist "%__TEST_SOURCES_FILE%" del "%__TEST_SOURCES_FILE%"
set __N=0
for /f "delims=" %%f in ('where /r "%_SOURCE_DIR%\test\java" *.java') do (
    echo %%f>> "%__TEST_SOURCES_FILE%"
    set /a __N+=1
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVAC_CMD%" "@%__TEST_OPTS_FILE%" "@%__TEST_SOURCES_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Compile %__N% Java test source files to directory "!_TEST_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_JAVAC_CMD%" "@%__TEST_OPTS_FILE%" "@%__TEST_SOURCES_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to compile %__N% Java test source files to directory "!_TEST_CLASSES_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_pack
call :libs_cpath
if not %_EXITCODE%==0 goto :eof

call :action_required "%_BENCH_JAR_FILE%" "%_TEST_CLASSES_DIR%\*.class"
if %_ACTION_REQUIRED%==0 goto :eof

@rem The benchmark jar file contains class files from 3 locations:
@rem _CLASSES_DIR, _TEST_CLASSES_DIR and JMH library dependencies.
set "__MANIFEST_FILE=%_TARGET_DIR%\manifest.txt"
(
    echo Manifest-Version: 1.0
    echo Main-Class: org.openjdk.jmh.Main
) > "%__MANIFEST_FILE%"

set "__CPATH_TAIL=%_LIBS_CPATH%"
:pack_loop
for /f "delims=; tokens=1,*" %%f in ("%__CPATH_TAIL%") do (
    set "__JAR_FILE=%%f"
    if not "!__JAR_FILE:jopt-simple=!"=="!__JAR_FILE!" (
        pushd "%_TEST_CLASSES_DIR%"
        if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_JAR_CMD%" xf "!__JAR_FILE!" 1>&2
        call "%_JAR_CMD%" xf "!__JAR_FILE!"
        popd
    ) else if not "!__JAR_FILE:jmh-core=!"=="!__JAR_FILE!" (
        pushd "%_TEST_CLASSES_DIR%"
        if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_JAR_CMD%" xf "!__JAR_FILE!" 1>&2
        call "%_JAR_CMD%" xf "!__JAR_FILE!"
        popd
    ) else if not "!__JAR_FILE:commons-math3=!"=="!__JAR_FILE!" (
        pushd "%_TEST_CLASSES_DIR%"
        if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_JAR_CMD%" xf "!__JAR_FILE!" 1>&2
        call "%_JAR_CMD%" xf "!__JAR_FILE!"
        popd
    )
    set "__CPATH_TAIL=%%g"
    goto pack_loop
)
set __JAR_OPTS=cfm "%_BENCH_JAR_FILE%" "%__MANIFEST_FILE%" -C "%_TEST_CLASSES_DIR%" .

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAR_CMD%" %__JAR_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Create Java archive file "!_BENCH_JAR_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%_JAR_CMD%" %__JAR_OPTS%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
set __JAR_OPTS=uf "%_BENCH_JAR_FILE%" -C "%_CLASSES_DIR%" .

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAR_CMD%" %__JAR_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Update Java archive file "!_BENCH_JAR_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%_JAR_CMD%" %__JAR_OPTS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to update Java archive file "!_BENCH_JAR_FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_native
echo %_WARNING_LABEL% Native tests not yet implemented 1>&2
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
    echo Total execution time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
