ifndef GIT_HOME
$(error Variable GIT_HOME is not set)
endif
ifndef GRAALVM_HOME
$(error Variable GRAALVM_HOME is not set)
endif
ifndef MSYS_HOME
$(error Variable MSYS_HOME is not set)
endif

ifeq ($(OS),Windows_NT)
JAR        = $(subst \,/,$(GRAALVM_HOME))/bin/jar.exe
JAVA       = $(subst \,/,$(GRAALVM_HOME))/bin/java.exe
JAVAC      = $(subst \,/,$(GRAALVM_HOME))/bin/javac.exe
JAVADOC    = $(subst \,/,$(GRAALVM_HOME))/bin/javadoc.exe
NATIVE_IMAGE = $(subst \,/,$(GRAALVM_HOME))/lib/svm/bin/native-image.exe
## GraalVM component "LLVM" is not available on Windows
CLANG      = $(subst \,/,$(LLVM_HOME))/bin/clang.exe
HOME       = $(subst \,/,$(USERPROFILE))
LOCAL_REPO = $(subst \,/,$(USERPROFILE))/.m2/repository
PSEP       = ;
## We grab Mingw version instead of C:\Windows\System32\curl.exe
CURL       = $(subst \,/,$(GIT_HOME))/mingw64/bin/curl.exe
ECHO       = $(subst \,/,$(GIT_HOME))/usr/bin/echo.exe
## We grab Mingw version instead of C:\Windows\System32\find.exe
FIND       = $(subst \,/,$(GIT_HOME))/usr/bin/find.exe
MAKE       = $(subst \,/,$(MSYS_HOME))/usr/bin/make.exe
MKDIR      = $(subst \,/,$(GIT_HOME))/usr/bin/mkdir.exe
RM         = $(subst \,/,$(GIT_HOME))/usr/bin/rm.exe
TOUCH      = $(subst \,/,$(GIT_HOME))/usr/bin/touch.exe
else
JAR        = $(GRAALVM_HOME)/bin/jar
JAVA       = $(GRAALVM_HOME)/bin/java
JAVAC      = $(GRAALVM_HOME)/bin/javac
JAVADOC    = $(GRAALVM_HOME)/bin/javadoc
NATIVE_IMAGE = $(GRAALVM_HOME)/lib/svm/bin/native-image
CLANG      = $(GRAALVM_HOME)/jre/languages/llvm/native/bin/clang
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
CURL       = curl
ECHO       = echo
FIND       = find
MAKE       = make
MKDIR      = mkdir
RM         = rm
TOUCH      = touch
endif

## https://mvnrepository.com/artifact/org.openjdk.jmh/jmh-core
JMH_VERSION = 1.37

JMH_CORE_LIB_JAR = $(shell $(FIND) "$(LOCAL_REPO)/org/openjdk/jmh" -name "jmh-core-$(JMH_VERSION).jar")
JMH_ANN_LIB_JAR  = $(shell $(FIND) "$(LOCAL_REPO)/org/openjdk/jmh" -name "jmh-generator-annprocess-$(JMH_VERSION).jar")
## 2 JMH depencencies: jopt-simple 5.0.4, commons-math3 3.2
JOPT_SIMPLE_JAR  = $(shell $(FIND) "$(LOCAL_REPO)/net/sf/jopt-simple" -name "jopt-simple-5.0.4.jar")
COMMONS_MATH_JAR = $(shell $(FIND) "$(LOCAL_REPO)/org/apache/commons" -name "commons-math3-3.2.jar")
## JUnit 4 depends on Hamcrest 1.3
HAMCREST_JAR     = $(shell $(FIND) "$(LOCAL_REPO)/org/hamcrest" -name "hamcrest-1.3.jar")
JUNIT_JAR        = $(shell $(FIND) "$(LOCAL_REPO)/junit/junit" -name "junit-4.13.2.jar")
