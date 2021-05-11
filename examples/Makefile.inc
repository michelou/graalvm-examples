ifndef GIT_HOME
$(error Variable GIT_HOME is not set)
endif
ifndef GRAALVM
$(error Variable GRAALVM is not set)
endif

ifeq ($(OS),Windows_NT)
JAR        = $(subst \,/,$(GRAALVM))/bin/jar.exe
JAVA       = $(subst \,/,$(GRAALVM))/bin/java.exe
JAVAC      = $(subst \,/,$(GRAALVM))/bin/javac.exe
CLANG      = $(subst \,/,$(LLVM_HOME))/bin/clang.exe
HOME       = $(subst \,/,$(USERPROFILE))
LOCAL_REPO = $(subst \,/,$(USERPROFILE))/.m2/repository
PSEP       = ;
## We grab Cygwin version instead of C:\Windows\System32\curl.exe
CURL       = $(subst \,/,$(GIT_HOME))/mingw64\bin\curl.exe
## We grab Cygwin version instead of C:\Windows\System32\find.exe
FIND       = $(subst \,/,$(GIT_HOME))/usr/bin/find.exe
MKDIR      = $(subst \,/,$(GIT_HOME))/usr/bin/mkdir.exe
TOUCH      = $(subst \,/,$(GIT_HOME))/usr/bin/touch.exe
else
JAR        = $(GRAALVM)/bin/jar
JAVA       = $(GRAALVM)/bin/java
JAVAC      = $(GRAALVM)/bin/javac
CLANG      = $(LLVM_HOME)/bin/clang
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
CURL       = curl
FIND       = find
MKDIR      = mkdir
TOUCH      = touch
endif

JMH_CORE_LIB_JAR = $(shell $(FIND) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-core-1.29.jar)
JMH_ANN_LIB_JAR  = $(shell $(FIND) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-generator-annprocess-1.29.jar)
JOPT_SIMPLE_JAR  = $(shell $(FIND) "$(LOCAL_REPO)/net/sf/jopt-simple" -name jopt-simple-4.6.jar)
COMMONS_MATH_JAR = $(shell $(FIND) "$(LOCAL_REPO)/org/apache/commons" -name commons-math3-3.2.jar)
HAMCREST_JAR     = $(shell $(FIND) "$(LOCAL_REPO)/org/hamcrest" -name hamcrest-2.2.jar)
JUNIT_JAR        = $(shell $(FIND) "$(LOCAL_REPO)/junit/junit" -name junit-4.13.2.jar)
