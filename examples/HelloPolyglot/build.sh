#!/usr/bin/env bash
#
# Copyright (c) 2018-2025 Stéphane Micheloud
#
# Licensed under the MIT License.
#

##############################################################################
## Subroutines

getHome() {
    local source="${BASH_SOURCE[0]}"
    while [[ -h "$source" ]]; do
        local linked="$(readlink "$source")"
        local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
        source="$dir/$(basename "$linked")"
    done
    ( cd -P "$(dirname "$source")" && pwd )
}

debug() {
    local DEBUG_LABEL="[44m[DEBUG][0m"
    [[ $DEBUG -eq 1 ]] && echo "$DEBUG_LABEL $1" 1>&2
}

warning() {
    local WARNING_LABEL="[46m[WARNING][0m"
    echo "$WARNING_LABEL $1" 1>&2
}

error() {
    local ERROR_LABEL="[91mError:[0m"
    echo "$ERROR_LABEL $1" 1>&2
}

# use variables EXITCODE, TIMER_START
cleanup() {
    [[ $1 =~ ^[0-1]$ ]] && EXITCODE=$1

    if [[ $TIMER -eq 1 ]]; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total elapsed time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=1 && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
        -debug)       DEBUG=1 ;;
        -help)        HELP=1 ;;
        -timer)       TIMER=1 ;;
        -verbose)     VERBOSE=1 ;;
        -*)
            error "Unknown option $arg"
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)   CLEAN=1 ;;
        compile) COMPILE=1 ;;
		doc)     DOC=1 ;;
        help)    HELP=1 ;;
        run)     COMPILE=1 && RUN=1 ;;
        *)
            error "Unknown subcommand $arg"
            EXITCODE=1 && return 0
            ;;
        esac
    done
    debug "Options    : TIMER=$TIMER VERBOSE=$VERBOSE"
    debug "Subcommands: CLEAN=$CLEAN COMPILE=$COMPILE HELP=$HELP RUN=$RUN"
    debug "Variables  : GRAALVM_HOME=$GRAALVM_HOME"
    # See http://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
    [[ $TIMER -eq 1 ]] && TIMER_START=$(date +"%s")
}

help() {
    cat << EOS
Usage: $BASENAME { <option> | <subcommand> }

  Options:
    -debug       show commands executed by this script
    -timer       display total elapsed time
    -verbose     display progress messages

  Subcommands:
    clean        delete generated files
    compile      compile Java source files
    help         display this help message
    run          execute main class "$MAIN_CLASS"
EOS
}

clean() {
    if [[ -d "$TARGET_DIR" ]]; then
        if [[ $DEBUG -eq 1 ]]; then
            debug "Delete directory $TARGET_DIR"
        elif [[ $VERBOSE -eq 1 ]]; then
            echo "Delete directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
        fi
        rm -rf "$TARGET_DIR"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
}

action_required() {
    local timestamp_file=$1
    local search_path=$2
    local search_pattern=$3
    local latest=
    for f in $(find $search_path -name $search_pattern 2>/dev/null); do
        [[ $f -nt $latest ]] && latest=$f
    done
    if [[ -z "$latest" ]]; then
        ## Do not compile if no source file
        echo 0
    elif [[ ! -f "$timestamp_file" ]]; then
        ## Do compile if timestamp file doesn't exist
        echo 1
    else
        ## Do compile if timestamp file is older than most recent source file
        local timestamp=$(stat -c %Y $timestamp_file)
        [[ $timestamp_file -nt $latest ]] && echo 1 || echo 0
    fi
}

compile() {
    [[ -d "$CLASSES_DIR" ]] || mkdir -p "$CLASSES_DIR"

    local timestamp_file="$TARGET_DIR/.latest-build"

    local required=0
    required=$(action_required "$timestamp_file" "$MAIN_SOURCE_DIR/" "*.java")
    [[ $required -eq 1 ]] || return 1

    local opts_file="$TARGET_DIR/javac_opts.txt"
    local cpath="$(mixed_path $CLASSES_DIR)"
    echo -classpath "$cpath" -d "$(mixed_path $CLASSES_DIR)" > "$opts_file"

    local sources_file="$TARGET_DIR/javac_sources.txt"
    [[ -f "$sources_file" ]] && rm "$sources_file"
    local n=0
    for f in $(find "$MAIN_SOURCE_DIR/" -type f -name "*.java" 2>/dev/null); do
        echo $(mixed_path $f) >> "$sources_file"
        n=$((n + 1))
    done
    if [[ $DEBUG -eq 1 ]]; then
        debug "$JAVAC_CMD @$(mixed_path $opts_file) @$(mixed_path $sources_file)"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Compile $n Java source files to directory \"${CLASSES_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "$JAVAC_CMD" "@$(mixed_path $opts_file)" "@$(mixed_path $sources_file)"
    if [[ $? -ne 0 ]]; then
        error "Compilation of $n Java source files failed"
        cleanup 1
    fi
    touch "$timestamp_file"
}

mixed_path() {
    if [[ -x "$CYGPATH_CMD" ]]; then
        $CYGPATH_CMD -am $1
    elif [[ $(($mingw + $msys)) -gt 0 ]]; then
        echo $1 | sed 's|/|\\\\|g'
    else
        echo $1
    fi
}

doc() {
    [[ -d "$TARGET_DOCS_DIR" ]] || mkdir -p "$TARGET_DOCS_DIR"

    local doc_timestamp_file="$TARGET_DOCS_DIR/.latest-build"

    local is_required="$(action_required "$doc_timestamp_file" "$MAIN_SOURCE_DIR/" "*.java")"
    [[ $is_required -eq 0 ]] && return 1

    local sources_file="$TARGET_DIR/javadoc_sources.txt"
    [[ -f "$sources_file" ]] && rm -rf "$sources_file"
    for f in $(find "$SOURCE_DIR/main/java/" -type f -name "*.java" 2>/dev/null); do
        echo $(mixed_path $f) >> "$sources_file"
    done
    local opts_file="$TARGET_DIR/javadoc_opts.txt"
    echo -d "$(mixed_path $TARGET_DOCS_DIR)" -doctitle "$PROJECT_NAME" -footer "$PROJECT_URL" -top "$PROJECT_VERSION" > "$opts_file"
    if [[ $DEBUG -eq 1 ]]; then
        debug "$JAVADOC_CMD @$(mixed_path $opts_file) @$(mixed_path $sources_file)"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Generate HTML documentation into directory \"${TARGET_DOCS_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "$JAVADOC_CMD" "@$(mixed_path $opts_file)" "@$(mixed_path $sources_file)"
    if [[ $? -ne 0 ]]; then
        error "Generation of HTML documentation failed"
        cleanup 1
    fi
    if [[ $DEBUG -eq 1 ]]; then
        debug "HTML documentation saved into directory \"$TARGET_DOCS_DIR\""
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "HTML documentation saved into directory \"${TARGET_DOCS_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    touch "$doc_timestamp_file"
}

run() {
    ##$DEBUG && debug "cp \"$TARGET_DIR/$MAIN_CLASS.wasm\" \"$CLASSES_DIR\""
    ##cp "$TARGET_DIR/$MAIN_CLASS.wasm" "$CLASSES_DIR"

    [[ $DEBUG -eq 1 ]] && debug "$JAVA_CMD -cp $CLASSES_DIR $MAIN_CLASS"
    eval "$JAVA_CMD" -cp "$CLASSES_DIR" $MAIN_CLASS
    [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
}

##############################################################################
## Environment setup

BASENAME=$(basename "${BASH_SOURCE[0]}")

EXITCODE=0

ROOT_DIR="$(getHome)"

SOURCE_DIR="$ROOT_DIR/src"
MAIN_SOURCE_DIR="$SOURCE_DIR/main/java"
TARGET_DIR="$ROOT_DIR/target"
TARGET_DOCS_DIR="$TARGET_DIR/docs"
CLASSES_DIR="$TARGET_DIR/classes"

## We refrain from using `true` and `false` which are Bash commands
## (see https://man7.org/linux/man-pages/man1/false.1.html)
CLEAN=0
COMPILE=0
DEBUG=0
DOC=0
HELP=0
MAIN_CLASS="HelloPolyglot"
MAIN_ARGS=
RUN=0
TARGET=js
TIMER=0
VERBOSE=0

COLOR_START="[32m"
COLOR_END="[0m"

cygwin=0
mingw=0
msys=0
darwin=0
linux=0
case "$(uname -s)" in
    CYGWIN*) cygwin=1 ;;
    MINGW*)  mingw=1 ;;
    MSYS*)   msys=1 ;;
    Darwin*) darwin=1 ;;
    Linux*)  linux=1 
esac
unset CYGPATH_CMD
PSEP=":"
if [[ $(($cygwin + $mingw + $msys)) -gt 0 ]]; then
    CYGPATH_CMD="$(which cygpath 2>/dev/null)"
    [[ -n "$GRAALVM_HOME" ]] && GRAALVM_HOME="$(mixed_path $GRAALVM_HOME)"
    PSEP=";"
fi
if [[ ! -x "$GRAALVM_HOME/bin/javac" ]]; then
    error "GraalVM installation not found"
    cleanup 1
fi
JAVA_CMD="$GRAALVM_HOME/bin/java"
JAVAC_CMD="$GRAALVM_HOME/bin/javac"
JAVADOC_CMD="$GRAALVM_HOME/bin/javadoc"

PROJECT_NAME="$(basename $ROOT_DIR)"
PROJECT_URL="github.com/$USER/graal-examples"
PROJECT_VERSION="1.0-SNAPSHOT"

args "$@"
[[ $EXITCODE -eq 0 ]] || cleanup 1

##############################################################################
## Main

[[ $HELP -eq 1 ]] && help && cleanup

if [[ $CLEAN -eq 1 ]]; then
    clean || cleanup 1
fi
if [[ $COMPILE -eq 1 ]]; then
    compile || cleanup 1
fi
if [[ $DOC -eq 1 ]]; then
    doc || cleanup 1
fi
if [[ $RUN -eq 1 ]]; then
    run || cleanup 1
fi
cleanup
