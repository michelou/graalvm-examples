ifndef MSYS_HOME
$(error Variable MSYS_HOME is not set)
endif
ifndef GRAALVM_HOME
$(error Variable GRAALVM_HOME is not set)
endif

ifeq ($(OS),Windows_NT)
JAR        = $(subst \,/,$(GRAALVM_HOME))/bin/jar.exe
JAVA       = $(subst \,/,$(GRAALVM_HOME))/bin/java.exe
JAVAC      = $(subst \,/,$(GRAALVM_HOME))/bin/javac.exe
JAVADOC    = $(subst \,/,$(GRAALVM_HOME))/bin/javadoc.exe
## GraalVM component "LLVM" is not available on Windows
CLANG      = $(subst \,/,$(LLVM_HOME))/bin/clang.exe
HOME       = $(subst \,/,$(USERPROFILE))
LOCAL_REPO = $(subst \,/,$(USERPROFILE))/.m2/repository
PSEP       = ;
## We grab MSYS version instead of C:\Windows\System32\curl.exe
CURL       = $(subst \,/,$(MSYS_HOME))/usr/bin/curl.exe
## We grab MSYS version instead of C:\Windows\System32\find.exe
ECHO       = $(subst \,/,$(MSYS_HOME))/usr/bin/echo.exe
FIND       = $(subst \,/,$(MSYS_HOME))/usr/bin/find.exe
MKDIR      = $(subst \,/,$(MSYS_HOME))/usr/bin/mkdir.exe
RM         = $(subst \,/,$(MSYS_HOME))/usr/bin/rm.exe
TOUCH      = $(subst \,/,$(MSYS_HOME))/usr/bin/touch.exe
else
JAR        = $(GRAALVM_HOME)/bin/jar
JAVA       = $(GRAALVM_HOME)/bin/java
JAVAC      = $(GRAALVM_HOME)/bin/javac
JAVADOC    = $(GRAALVM_HOME)/bin/javadoc
CLANG      = $(GRAALVM_HOME)/jre/languages/llvm/native/bin/clang
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
CURL       = curl
ECHO       = echo
FIND       = find
MKDIR      = mkdir
RM         = rm
TOUCH      = touch
endif

JMH_CORE_LIB_JAR = $(shell $(FIND) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-core-1.33.jar)
JMH_ANN_LIB_JAR  = $(shell $(FIND) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-generator-annprocess-1.33.jar)
## Two JMH depencencies: jopt-simple 4.6, commons-math3 3.2
JOPT_SIMPLE_JAR  = $(shell $(FIND) "$(LOCAL_REPO)/net/sf/jopt-simple" -name jopt-simple-4.6.jar)
COMMONS_MATH_JAR = $(shell $(FIND) "$(LOCAL_REPO)/org/apache/commons" -name commons-math3-3.2.jar)
HAMCREST_JAR     = $(shell $(FIND) "$(LOCAL_REPO)/org/hamcrest" -name hamcrest-2.2.jar)
JUNIT_JAR        = $(shell $(FIND) "$(LOCAL_REPO)/junit/junit" -name junit-4.13.2.jar)
