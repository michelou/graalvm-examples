ifeq ($(OS),Windows_NT)
JAVA_HOME0 = $(subst \,/,$(JAVA_HOME))
JAVAC      = $(JAVA_HOME0)/bin/javac.exe
JAVA       = $(JAVA_HOME0)/bin/java.exe
LOCAL_REPO = $(subst \,/,$(USERPROFILE)/.m2/repository)
PSEP       = ;
else
JAVAC      = $(JAVA_HOME)/bin/javac
JAVA       = $(JAVA_HOME)/bin/java
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
endif

JMH_CORE_LIB_JAR = $(shell find "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-core-1.23.jar)
JMH_ANN_LIB_JAR  = $(shell find "$(LOCAL_REPO)/org/openjdk/jmh" -name jmh-generator-annprocess-1.23.jar)
