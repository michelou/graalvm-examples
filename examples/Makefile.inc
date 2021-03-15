ifeq ($(OS),Windows_NT)
JAR        = $(subst \,/,$(JAVA_HOME))/bin/jar.exe
JAVA       = $(subst \,/,$(JAVA_HOME))/bin/java.exe
JAVAC      = $(subst \,/,$(JAVA_HOME))/bin/javac.exe
LOCAL_REPO = $(subst \,/,$(USERPROFILE)/.m2/repository)
PSEP       = ;
## We grab Cygwin version instead of C:\Windows\System32\find.exe
FIND_CMD   = /usr/bin/find.exe
else
JAR        = $(JAVA_HOME)/bin/jar
JAVA       = $(JAVA_HOME)/bin/java
JAVAC      = $(JAVA_HOME)/bin/javac
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
FIND_CMD   = find
endif

JMH_CORE_LIB_JAR = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-core-1.27.jar)
JMH_ANN_LIB_JAR  = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-generator-annprocess-1.27.jar)
JOPT_SIMPLE_JAR  = $(shell $(FIND_CMD) "$(LOCAL_REPO)/net/sf/jopt-simple" -name jopt-simple-5.0.4.jar)
COMMONS_MATH_JAR = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/apache/commons" -name commons-math3-3.2.jar)
HAMCREST_JAR     = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/hamcrest" -name hamcrest-2.2.jar)
JUNIT_JAR        = $(shell $(FIND_CMD) "$(LOCAL_REPO)/junit/junit" -name junit-4.13.2.jar)
