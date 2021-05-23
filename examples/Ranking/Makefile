include ../Makefile.inc

SOURCE_DIR  = src
TARGET_DIR  = target
CLASSES_DIR = $(TARGET_DIR)/classes

OPTS_FILE    = $(TARGET_DIR)/javac_opts.txt
SOURCES_FILE = $(TARGET_DIR)/javac_sources.txt

JAVAC_FLAGS = -deprecation -classpath "$(JMH_CORE_LIB_JAR)$(PSEP)$(JMH_ANN_LIB_JAR)"
# JAVA_FLAGS  = -classpath "$(JMH_CORE_LIB_JAR)$(PSEP)$(JMH_ANN_LIB_JAR)$(PSEP)$(CLASSES_DIR)"

##############################################################################
## main rules

SOURCES  = $(shell $(FIND) $(SOURCE_DIR)/main -name *.java)
TARGET   = $(TARGET_DIR)/benchmarks.jar
MANIFEST = $(TARGET_DIR)/manifest.txt

all: build

build: $(TARGET)

$(TARGET): $(SOURCES)
	[ -d "$(CLASSES_DIR)" ] || $(MKDIR) -p "$(CLASSES_DIR)"
	@echo $(JAVAC_FLAGS) -d "$(CLASSES_DIR)" > "$(OPTS_FILE)"
	@echo $(SOURCES) > "$(SOURCES_FILE)"
	$(JAVAC) "@$(OPTS_FILE)" "@$(SOURCES_FILE)"
	@echo Manifest-Version: 1.0 > $(MANIFEST)
	@echo Main-Class: org.openjdk.jmh.Main >> $(MANIFEST)
	cd "$(CLASSES_DIR)" && $(JAR) xf "$(JMH_CORE_LIB_JAR)"
	cd "$(CLASSES_DIR)" && $(JAR) xf "$(JMH_ANN_LIB_JAR)"
	cd "$(CLASSES_DIR)" && $(JAR) xf "$(JOPT_SIMPLE_JAR)"
	cd "$(CLASSES_DIR)" && $(JAR) xf "$(COMMONS_MATH_JAR)"
	$(JAR) cfm $(TARGET) "$(MANIFEST)" -C "$(CLASSES_DIR)" .

clean:
	rm -rf "$(TARGET_DIR)"

run: build
	$(JAVA) -Xmx1G -jar "$(TARGET)" rank

help:
	@$(ECHO) "Usage: make all|build|clean|help|run|test"
	@$(ECHO) ""
	@$(ECHO) "  Subcommands:"
	@$(ECHO) "    all      alias for build"
	@$(ECHO) "    build    compile Java source files"
	@$(ECHO) "    clean    delete generated files"
	@$(ECHO) "    help     display this help message"
	@$(ECHO) "    run      execute main program $(MAIN_CLASS)"
	@$(ECHO) "    test     execute unit tests with JUnit"

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
	@echo -siteroot "$(DOC_TARGET_DIR)" -project "$(PROJECT_NAME)" -project-version "$(PROJECT_VERSION)" > "$(DOC_OPTS_FILE)"
	@echo $(SOURCES) > "$(DOC_SOURCES_FILE)"
	$(JAVADOC) "@$(DOC_OPTS_FILE)" "@$(DOC_SOURCES_FILE)"
	@$(TOUCH) "$(DOC_TARGET)"

doc: $(DOC_TARGET)

##############################################################################
## lint rules

## https://github.com/checkstyle/checkstyle/releases
CHECKSTYLE_VERSION = 8.42
CHECKSTYLE_DIR     = $(HOME)/.checkstyle

CHECKSTYLE_SOURCES = $(shell $(FIND) $(SOURCE_DIR) -type f -name *.java)
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

TEST_SOURCES     = $(shell $(FIND) $(SOURCE_DIR)/test -type f -name *.java)
TEST_CLASSES_DIR = $(TARGET_DIR)/test-classes
TEST_TARGET      = $(TARGET_DIR)/.latest-test-build

TEST_OPTS_FILE    = $(TARGET_DIR)/javac_test_opts.txt
TEST_SOURCES_FILE = $(TARGET_DIR)/javac_test_sources.txt

TEST_MAIN_CLASS  = $(MAIN_CLASS)JUnitTest
TEST_CPATH       = $(SCALA_LIB_JAR)$(PSEP)$(DOTTY_LIB_JAR)$(PSEP)$(HAMCREST_JAR)$(PSEP)$(JUNIT_JAR)$(PSEP)$(JUNIT_INTF_JAR)$(PSEP)$(SCALATEST_JAR)$(PSEP)$(SCALACTIC_JAR)$(PSEP)$(SPECS2_CORE_JAR)$(PSEP)$(SPECS2_JUNIT_JAR)$(PSEP)$(SPECS2_MATCHER_JAR)$(PSEP)$(CLASSES_DIR)$(PSEP)$(TEST_CLASSES_DIR)

$(TEST_TARGET): $(TEST_SOURCES)
	[ -d "$(TEST_CLASSES_DIR)" ] || $(MKDIR) -p "$(TEST_CLASSES_DIR)"
	@echo $(JAVAC_FLAGS) -classpath "$(TEST_CPATH)" -d "$(TEST_CLASSES_DIR)" > "$(TEST_OPTS_FILE)"
	@echo $(TEST_SOURCES) > "$(TEST_SOURCES_FILE)"
	$(JAVAC) "@$(TEST_OPTS_FILE)" "@$(TEST_SOURCES_FILE)"
	@$(TOUCH) "$(TEST_TARGET)"

test: build $(TEST_TARGET)
	$(JAVA) -classpath "$(TEST_CPATH)" org.junit.runner.JUnitCore $(TEST_MAIN_CLASS)

##############################################################################
## phony

.PHONY: all build clean doc help run test
