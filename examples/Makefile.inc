ifeq ($(OS),Windows_NT)
JAR        = $(subst \,/,$(JAVA_HOME))/bin/jar.exe
JAVAC      = $(subst \,/,$(JAVA_HOME))/bin/javac.exe
JAVA       = $(subst \,/,$(JAVA_HOME))/bin/java.exe
LOCAL_REPO = $(subst \,/,$(USERPROFILE)/.m2/repository)
PSEP       = ;
## We grab Cygwin version instead of C:\Windows\System32\find.exe
FIND_CMD   = /usr/bin/find.exe
else
JAR        = $(JAVA_HOME)/bin/jar
JAVAC      = $(JAVA_HOME)/bin/javac
JAVA       = $(JAVA_HOME)/bin/java
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
FIND_CMD   = find
endif

JMH_CORE_LIB_JAR = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-core-1.23.jar)
JMH_ANN_LIB_JAR  = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-generator-annprocess-1.23.jar)
JOPT_SIMPLE_JAR  = $(shell $(FIND_CMD) "$(LOCAL_REPO)/net/sf/jopt-simple" -name jopt-simple-5.0.4.jar)
COMMONS_MATH_JAR = $(shell $(FIND_CMD) "$(LOCAL_REPO)/org/apache/commons" -name commons-math3-3.2.jar)