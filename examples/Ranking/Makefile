include ../Makefile.inc

SOURCE_DIR  = src
TARGET_DIR  = target
CLASSES_DIR = $(TARGET_DIR)/classes

JAVAC_FLAGS = -deprecation -classpath \"$(JMH_CORE_LIB_JAR);$(JMH_ANN_LIB_JAR)\"
# JAVA_FLAGS  = -classpath "$(JMH_CORE_LIB_JAR);$(JMH_ANN_LIB_JAR);$(CLASSES_DIR)"

##############################################################################
## main rules

SOURCES  = $(shell $(FIND_CMD) $(SOURCE_DIR)/main -name *.java)
TARGET   = $(TARGET_DIR)/benchmarks.jar
MANIFEST = $(TARGET_DIR)/manifest.txt

all: build

build: $(TARGET)

$(TARGET): $(SOURCES)
	[ -d "$(CLASSES_DIR)" ] || mkdir -p "$(CLASSES_DIR)"
	@echo "$(JAVAC_FLAGS) -d \"$(CLASSES_DIR)\"" > "$(TARGET_DIR)/javac_opts.txt"
	@echo "$(SOURCES)" > "$(TARGET_DIR)/javac_sources.txt"
	$(JAVAC) "@$(TARGET_DIR)/javac_opts.txt" "@$(TARGET_DIR)/javac_sources.txt"
	@echo "Manifest-Version: 1.0" > $(MANIFEST)
	@echo "Main-Class: org.openjdk.jmh.Main" >> $(MANIFEST)
	cd "$(CLASSES_DIR)"; $(JAR) xf "$(JMH_CORE_LIB_JAR)"
	cd "$(CLASSES_DIR)"; $(JAR) xf "$(JMH_ANN_LIB_JAR)"
	cd "$(CLASSES_DIR)"; $(JAR) xf "$(JOPT_SIMPLE_JAR)"
	cd "$(CLASSES_DIR)"; $(JAR) xf "$(COMMONS_MATH_JAR)"
	$(JAR) cfm $(TARGET) "$(MANIFEST)" -C "$(CLASSES_DIR)" .

clean:
	rm -rf "$(TARGET_DIR)"

run: build
	$(JAVA) -Xmx1G -jar "$(TARGET)" rank

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
	[ -d "$(DOC_TARGET_DIR)" ] || mkdir -p "$(DOC_TARGET_DIR)"
	@echo -siteroot \"$(DOC_TARGET_DIR)\" -project \"$(PROJECT_NAME)\" -project-url \"$(PROJECT_URL)\" -project-version \"$(PROJECT_VERSION)\" > "$(DOC_OPTS_FILE)"
	@echo "$(SOURCES)" > "$(DOC_SOURCES_FILE)"
	$(JAVADOC) "@$(DOC_OPTS_FILE)" "@$(DOC_SOURCES_FILE)"
	@echo "" > "$(DOC_TARGET)"

doc: $(DOC_TARGET)

##############################################################################
## test rules

TEST_SOURCES = $(shell $(FIND_CMD) $(SOURCE_DIR)/test -name *.java)
TEST_TARGET  = $(TARGET_DIR)/.latest-test-build

TEST_MAIN_CLASS  = $(MAIN_CLASS)JUnitTest
TEST_CLASSES_DIR = $(TARGET_DIR)/test-classes
TEST_CPATH       = $(SCALA_LIB_JAR)$(PSEP)$(DOTTY_LIB_JAR)$(PSEP)$(HAMCREST_JAR)$(PSEP)$(JUNIT_JAR)$(PSEP)$(JUNIT_INTF_JAR)$(PSEP)$(SCALATEST_JAR)$(PSEP)$(SCALACTIC_JAR)$(PSEP)$(SPECS2_CORE_JAR)$(PSEP)$(SPECS2_JUNIT_JAR)$(PSEP)$(SPECS2_MATCHER_JAR)$(PSEP)$(CLASSES_DIR)$(PSEP)$(TEST_CLASSES_DIR)

$(TEST_TARGET): $(TEST_SOURCES)
	[ -d "$(TEST_CLASSES_DIR)" ] || mkdir -p "$(TEST_CLASSES_DIR)"
	@echo "$(JAVAC_FLAGS) -classpath \"$(TEST_CPATH)\" -d \"$(TEST_CLASSES_DIR)\"" > "$(TARGET_DIR)/scalac_test_opts.txt"
	@echo "$(TEST_SOURCES)" > "$(TARGET_DIR)/scalac_test_sources.txt"
	$(SCALAC) "@$(TARGET_DIR)/scalac_test_opts.txt" "@$(TARGET_DIR)/scalac_test_sources.txt"
	@echo "" > "$(TEST_TARGET)"

test: build $(TEST_TARGET)
	$(JAVA) -classpath "$(TEST_CPATH)" org.junit.runner.JUnitCore $(TEST_MAIN_CLASS)

##############################################################################
## phony

.PHONY: all build clean doc run test
