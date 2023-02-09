@echo off
setlocal enabledelayedexpansion

@rem output parameter: _CPATH

if not defined _DEBUG set _DEBUG=%~1
if not defined _DEBUG set _DEBUG=0
set _VERBOSE=0

if not defined _MVN_CMD set "_MVN_CMD=%MVN_HOME%\bin\mvn.cmd"
if %_DEBUG%==1 echo [%~n0] "_MVN_CMD=%_MVN_CMD%" 1>&2

if %_DEBUG%==1 ( set _MVN_OPTS=
) else ( set _MVN_OPTS=--quiet
)
set _CENTRAL_REPO=https://repo1.maven.org/maven2
set "_LOCAL_REPO=%USERPROFILE%\.m2\repository"

set "_TEMP_DIR=%TEMP%\lib"
if not exist "%_TEMP_DIR%" mkdir "%_TEMP_DIR%"
if %_DEBUG%==1 echo [%~n0] "_TEMP_DIR=%_TEMP_DIR%"

set _LIBS_CPATH=

@rem https://mvnrepository.com/artifact/org.hamcrest/hamcrest
@rem JUnit 4 depends on Hamcrest 1.3
call :add_jar "org.hamcrest" "hamcrest-core" "1.3"

@rem https://mvnrepository.com/artifact/junit/junit
call :add_jar "junit" "junit" "4.13.2"


@rem 2 JMH depencencies: jopts-simple 5.0.4, commons-math3 3.2
set _JMH_VERSION=1.36

@rem https://mvnrepository.com/artifact/org.openjdk.jmh/jmh-core
call :add_jar "org.openjdk.jmh" "jmh-core" "%_JMH_VERSION%"

@rem https://mvnrepository.com/artifact/org.openjdk.jmh/jmh-generator-annprocess
call :add_jar "org.openjdk.jmh" "jmh-generator-annprocess" "%_JMH_VERSION%"

@rem https://mvnrepository.com/artifact/net.sf.jopt-simple/jopt-simple
call :add_jar "net.sf.jopt-simple" "jopt-simple" "5.0.4"

@rem https://mvnrepository.com/artifact/org.apache.commons/commons-math3 
call :add_jar "org.apache.commons" "commons-math3" "3.6.1"

@rem https://docs.micronaut.io/latest/api/
set _MICRONAUT_VERSION=3.8.4

@rem https://mvnrepository.com/artifact/io.micronaut/micronaut-core
call :add_jar "io.micronaut" "micronaut-core" "%_MICRONAUT_VERSION%"

@rem https://mvnrepository.com/artifact/io.micronaut/micronaut-inject
call :add_jar "io.micronaut" "micronaut-inject" "%_MICRONAUT_VERSION%"

@rem https://mvnrepository.com/artifact/io.micronaut.configuration/micronaut-picocli
call :add_jar "io.micronaut.configuration" "micronaut-picocli" "1.2.1"

@rem https://mvnrepository.com/artifact/javax.inject/javax.inject
call :add_jar "javax.inject" "javax.inject" "1"

@rem https://mvnrepository.com/artifact/info.picocli/picocli
call :add_jar "info.picocli" "picocli" "4.7.1"

set _LOG4J_VERSION=2.19.0

@rem https://mvnrepository.com/artifact/org.apache.logging.log4j/log4j-api
call :add_jar "org.apache.logging.log4j" "log4j-api" "%_LOG4J_VERSION%"

@rem https://mvnrepository.com/artifact/org.apache.logging.log4j/log4j-core
call :add_jar "org.apache.logging.log4j" "log4j-core" "%_LOG4J_VERSION%"

@rem https://mvnrepository.com/artifact/com.guicedee.services/slf4j
call :add_jar "com.guicedee.services" "slf4j" "1.2.2.1"

goto end

@rem #########################################################################
@rem ## Subroutines

@rem input parameters: %1=group ID, %2=artifact ID, %3=version
@rem global variable: _LIBS_CPATH
:add_jar
@rem https://mvnrepository.com/artifact/org.openjdk.jmh/jmh-core
set __GROUP_ID=%~1
set __ARTIFACT_ID=%~2
set __VERSION=%~3

set __JAR_NAME=%__ARTIFACT_ID%-%__VERSION%.jar
set __JAR_PATH=%__GROUP_ID:.=\%\%__ARTIFACT_ID:/=\%
set __JAR_FILE=
for /f "usebackq delims=" %%f in (`where /r "%_LOCAL_REPO%\%__JAR_PATH%" %__JAR_NAME% 2^>NUL`) do (
    set "__JAR_FILE=%%f"
)
if not exist "%__JAR_FILE%" (
    set __JAR_URL=%_CENTRAL_REPO%/%__GROUP_ID:.=/%/%__ARTIFACT_ID%/%__VERSION%/%__JAR_NAME%
    set "__JAR_FILE=%_TEMP_DIR%\%__JAR_NAME%"
    if not exist "!__JAR_FILE!" (
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "Invoke-WebRequest -Uri '!__JAR_URL!' -Outfile '!__JAR_FILE!'" 1>&2
        ) else if %_VERBOSE%==1 ( echo Download file %__JAR_NAME% to directory "!_TEMP_DIR:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
        )
        powershell -c "$progressPreference='silentlyContinue';Invoke-WebRequest -Uri '!__JAR_URL!' -Outfile '!__JAR_FILE!'"
        if not !ERRORLEVEL!==0 (
            echo %_ERROR_LABEL% Failed to download file %__JAR_NAME% 1>&2
            set _EXITCODE=1
            goto :eof
        )
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MVN_CMD%" install:install-file -Dfile="!__JAR_FILE!" -DgroupId="%__GROUP_ID%" -DartifactId=%__ARTIFACT_ID% -Dversion=%__VERSION% -Dpackaging=jar 1>&2
        ) else if %_VERBOSE%==1 ( echo Install Maven archive into directory "!_LOCAL_REPO:%USERPROFILE%=%%USERPROFILE%%!\%__SCALA_XML_PATH%" 1>&2
        )
        call "%_MVN_CMD%" %_MVN_OPTS% install:install-file -Dfile="!__JAR_FILE!" -DgroupId="%__GROUP_ID%" -DartifactId=%__ARTIFACT_ID% -Dversion=%__VERSION% -Dpackaging=jar
        if not !ERRORLEVEL!==0 (
            echo %_ERROR_LABEL% Failed to install Maven artifact into directory "!_LOCAL_REPO:%USERPROFILE%=%%USERPROFILE%%!" ^(error:!ERRORLEVEL!^) 1>&2
        )
        for /f "usebackq delims=" %%f in (`where /r "%_LOCAL_REPO%\%__JAR_PATH%" %__JAR_NAME% 2^>NUL`) do (
            set "__JAR_FILE=%%f"
        )
    )
)
set "_LIBS_CPATH=%_LIBS_CPATH%%__JAR_FILE%;"
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
endlocal & (
    set "_CPATH=%_LIBS_CPATH%"
)