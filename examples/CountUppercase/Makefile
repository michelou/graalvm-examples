include ../Makefile.inc

SOURCE_DIR  = src
TARGET_DIR  = target
CLASSES_DIR = $(TARGET_DIR)/classes

LOG_FILE    = $(TARGET_DIR)/graal_log.txt
JAVAC_FLAGS = -deprecation -classpath "$(JMH_CORE_LIB_JAR)$(PSEP)$(JMH_ANN_LIB_JAR)"
JAVA_FLAGS  = -classpath "$(JMH_CORE_LIB_JAR)$(PSEP)$(JMH_ANN_LIB_JAR)$(PSEP)$(CLASSES_DIR)" -Diterations=5 -Dgraal.ShowConfiguration=info -Dgraal.PrintCompilation=true -Dgraal.LogFile="$(LOG_FILE)"

##############################################################################
## main rules

SOURCES  = $(shell $(FIND) $(SOURCE_DIR)/main/java -type f -name *.java)
TARGET   = $(TARGET_DIR)/.latest-build

OPTS_FILE    = $(TARGET_DIR)/javac_opts.txt
SOURCES_FILE = $(TARGET_DIR)/javac_sources.txt

MAIN_CLASS = CountUppercase
MAIN_ARGS ?= 

all: build

build: $(TARGET)

$(TARGET): $(SOURCES)
	[ -d "$(CLASSES_DIR)" ] || $(MKDIR) -p "$(CLASSES_DIR)"
	@$(ECHO) $(JAVAC_FLAGS) -d "$(CLASSES_DIR)" > "$(OPTS_FILE)"
	@$(ECHO) $(SOURCES) > "$(SOURCES_FILE)"
	$(JAVAC) "@$(OPTS_FILE)" "@$(SOURCES_FILE)"
	@$(TOUCH) "$(TARGET)"

clean:
	rm -rf "$(TARGET_DIR)"

run: build
	$(JAVA) $(JAVA_FLAGS) $(MAIN_CLASS) $(MAIN_ARGS)
	@[ -f "$(LOG_FILE)" ] & echo Compilation log written to file "$(LOG_FILE)" 1>&2

help:
	@$(ECHO) "Usage: make all|build|clean|help|lint|run|test"
	@$(ECHO) ""
	@$(ECHO) "   Subcommands:"
	@$(ECHO) "     all    alias for build"
	@$(ECHO) "     build  compile Java source files"
	@$(ECHO) "     clean  delete generated files"
	@$(ECHO) "     help   display this help message"
	@$(ECHO) "     lint   analyze Java source files with CheckStyle"
	@$(ECHO) "     run    execute main program $(MAIN_CLASS)"
	@$(ECHO) "     test   execute unit tests with JUnit"

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
	@$(ECHO) -d "$(DOC_TARGET_DIR)" -doctitle "$(PROJECT_NAME)" -footer "$(PROJECT_URL)" -top "$(PROJECT_VERSION)" > "$(DOC_OPTS_FILE)"
	@$(ECHO) $(SOURCES) > "$(DOC_SOURCES_FILE)"
	$(JAVADOC) "@$(DOC_OPTS_FILE)" "@$(DOC_SOURCES_FILE)"
	@$(TOUCH) "$(DOC_TARGET)"

doc: $(DOC_TARGET)

##############################################################################
## lint rules

## https://github.com/checkstyle/checkstyle/releases
CHECKSTYLE_VERSION = 8.42
CHECKSTYLE_DIR     = $(HOME)/.checkstyle

CHECKSTYLE_SOURCES = $(shell $(FIND) $(SOURCE_DIR) -name *.java)
CHECKSTYLE_TARGET  = $(TARGET_DIR)/.latest-lint

## "checkstyle-all" version not available from Maven Central
JAR_NAME = checkstyle-$(CHECKSTYLE_VERSION)-all.jar
JAR_URL  = https://github.com/checkstyle/checkstyle/releases/download/checkstyle-$(CHECKSTYLE_VERSION)/$(JAR_NAME)
JAR_FILE = $(CHECKSTYLE_DIR)/$(JAR_NAME)
XML_FILE = $(CHECKSTYLE_DIR)/graal_checks.xml

lint: $(JAR_FILE) $(CHECKSTYLE_TARGET)

$(JAR_FILE):
	[ -d "$(CHECKSTYLE_DIR)" ] || $(MKDIR) -p "$(CHECKSTYLE_DIR)"
	$(CURL) --silent --location --output $(JAR_FILE) $(JAR_URL)

$(CHECKSTYLE_TARGET): $(CHECKSTYLE_SOURCES)
	$(JAVA) -jar $(JAR_FILE) -c=$(XML_FILE) $^

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
	@$(ECHO) -classpath "$(TEST_CPATH)" -d "$(TEST_CLASSES_DIR)" > "$(TEST_OPTS_FILE)"
	@$(ECHO) $(TEST_SOURCES) > "$(TEST_SOURCES_FILE)"
	$(JAVAC) "@$(TEST_OPTS_FILE)" "@$(TEST_SOURCES_FILE)"
	@$(TOUCH) "$(TEST_TARGET)"

test: build $(TEST_TARGET)
	$(JAVA) -classpath "$(TEST_CPATH)" org.junit.runner.JUnitCore $(TEST_MAIN_CLASS)

##############################################################################
## phony

.PHONY: all build clean doc help lint run test
