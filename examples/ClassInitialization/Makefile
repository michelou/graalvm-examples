include ../Makefile.inc

SOURCE_DIR  = src
TARGET_DIR  = target
CLASSES_DIR = $(TARGET_DIR)/classes

JAVAC_FLAGS = -deprecation -classpath "$(JMH_CORE_LIB_JAR)$(PSEP)$(JMH_ANN_LIB_JAR)"
CPATH       = $(JMH_CORE_LIB_JAR)$(PSEP)$(JMH_ANN_LIB_JAR)$(PSEP)$(CLASSES_DIR)
LOG_FILE    = $(TARGET_DIR)/graal_log.txt
ifdef DEBUG
JAVA_FLAGS  = -classpath "$(CPATH)" -Dgraal.ShowConfiguration=info -Dgraal.PrintCompilation=true -Dgraal.LogFile=$(LOG_FILE)
else
JAVA_FLAGS = -classpath "$(CPATH)"
endif

##############################################################################
## main rules

SOURCES  = $(shell $(FIND) $(SOURCE_DIR)/main/java -name *.java)
TARGET   = $(TARGET_DIR)/.latest-build

OPTS_FILE    = $(TARGET_DIR)/javac_opts.txt
SOURCES_FILE = $(TARGET_DIR)/javac_sources.txt

MAIN_CLASS = org.graalvm.example.HelloCachedTime
MAIN_ARGS ?= 

all: build

build: $(TARGET)

$(TARGET): $(SOURCES)
	[ -d "$(CLASSES_DIR)" ] || $(MKDIR) -p "$(CLASSES_DIR)"
	@echo $(JAVAC_FLAGS) -d "$(CLASSES_DIR)" > "$(OPTS_FILE)"
	@echo $(SOURCES) > "$(SOURCES_FILE)"
	$(JAVAC) "@$(OPTS_FILE)" "@$(SOURCES_FILE)"
	@$(TOUCH) "$(TARGET)"

clean:
	rm -rf "$(TARGET_DIR)"

run: build
	$(JAVA) $(JAVA_FLAGS) $(MAIN_CLASS) $(MAIN_ARGS)
	@[ -f "$(LOG_FILE)" ] & echo Compilation log written to file "$(LOG_FILE)" 1>&2

help:
	@$(info Usage: make all|build|clean|help|lint|run|test)
	@$(info )
	@echo   Subcommands:
	@echo     all    alias for build
	@echo     build  compile Java source files
	@echo     clean  delete generated files
	@echo     help   display this help message
	@echo     run    execute main program $(MAIN_CLASS)
	@echo     test   execute unit tests with JUnit

##############################################################################
## doc rules

DOC_TARGET_DIR = $(TARGET_DIR)/docs
DOC_TARGET     = $(DOC_TARGET_DIR)/.latest-build

PROJECT_NAME    ?= $(shell basename $(CURDIR))
PROJECT_URL     ?= https://github.com/$(USERNAME)/graalvm-examples
PROJECT_VERSION ?= 1.0.0

DOC_OPTS_FILE    = $(TARGET_DIR)/javadoc_opts.txt
DOC_SOURCES_FILE = $(TARGET_DIR)/javadoc_sources.txt

$(DOC_TARGET): $(SOURCES)
	[ -d "$(DOC_TARGET_DIR)" ] || $(MKDIR) -p "$(DOC_TARGET_DIR)"
	@echo -siteroot "$(DOC_TARGET_DIR)" -project "$(PROJECT_NAME)" -project-url "$(PROJECT_URL)" -project-version "$(PROJECT_VERSION)" > "$(DOC_OPTS_FILE)"
	@echo "$(SOURCES)" > "$(DOC_SOURCES_FILE)"
	$(JAVADOC) "@$(DOC_OPTS_FILE)" "@$(DOC_SOURCES_FILE)"
	@$(TOUCH) "$(DOC_TARGET)"

doc: $(DOC_TARGET)

##############################################################################
## lint rules

LINT_SOURCES = $(shell $(FIND) $(SOURCE_DIR) -name *.java)
LINT_TARGET  = $(TARGET_DIR)/.latest-lint

CHECKSTYLE_CONFIG_FILE = $(shell $(FIND) $(HOME)/.checkstyle -name *.xml)
CHECKSTYLE_JAR_FILE    = $(shell $(FIND) $(HOME)/.checkstyle -name checkstyle*.jar)

lint: $(LINT_TARGET)

$(LINT_TARGET): $(LINT_SOURCES)
	$(JAVA) -jar $(CHECKSTYLE_JAR_FILE) -c=$(CHECKSTYLE_CONFIG_FILE) $^

##############################################################################
## test rules

TEST_SOURCES     = $(shell $(FIND) $(SOURCE_DIR)/test -name *.java)
TEST_CLASSES_DIR = $(TARGET_DIR)/test-classes
TEST_TARGET      = $(TARGET_DIR)/.latest-test-build

TEST_OPTS_FILE    = $(TARGET_DIR)/javac_test_opts.txt
TEST_SOURCES_FILE = $(TARGET_DIR)/javac_test_sources.txt

TEST_MAIN_CLASS  = $(MAIN_CLASS)JUnitTest
TEST_CPATH       = $(HAMCREST_JAR)$(PSEP)$(JUNIT_JAR)$(PSEP)$(CLASSES_DIR)$(PSEP)$(TEST_CLASSES_DIR)

$(TEST_TARGET): $(TEST_SOURCES)
	[ -d "$(TEST_CLASSES_DIR)" ] || $(MKDIR) -p "$(TEST_CLASSES_DIR)"
	@echo -classpath "$(TEST_CPATH)" -d "$(TEST_CLASSES_DIR)" > "$(TEST_OPTS_FILE)"
	@echo $(TEST_SOURCES) > "$(TEST_SOURCES_FILE)"
	$(JAVAC) "@$(TEST_OPTS_FILE)" "@$(TEST_SOURCES_FILE)"
	@$(TOUCH) "$(TEST_TARGET)"

test: build $(TEST_TARGET)
	$(JAVA) -classpath "$(TEST_CPATH)" org.junit.runner.JUnitCore $(TEST_MAIN_CLASS)

##############################################################################
## phony

.PHONY: all build clean doc help lint run test
