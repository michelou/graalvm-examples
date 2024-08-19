#!/usr/bin/env bash
#
# Copyright (c) 2018-2024 Stéphane Micheloud
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
    local DEBUG_LABEL="[46m[DEBUG][0m"
    $DEBUG && echo "$DEBUG_LABEL $1" 1>&2
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

    if $TIMER; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total elapsed time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=true && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
        -cached)  CACHED=true ;;
        -debug)   DEBUG=true ;;
        -help)    HELP=true ;;
        -timer)   TIMER=true ;;
        -verbose) VERBOSE=true ;;
        -*)
            error "Unknown option $arg"
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)   CLEAN=true ;;
        compile) COMPILE=true ;;
        help)    HELP=true ;;
        run)     COMPILE=true && RUN=true ;;
        *)
            error "Unknown subcommand $arg"
            EXITCODE=1 && return 0
            ;;
        esac
    done
    MAIN_CLASS=primes.PrimesCommand

    debug "Options    : CACHED=$CACHED TIMER=$TIMER VERBOSE=$VERBOSE"
    debug "Subcommands: CLEAN=$CLEAN COMPILE=$COMPILE HELP=$HELP RUN=$RUN"
    debug "Variables  : GRAALVM_HOME=$GRAALVM_HOME"
    debug "Variables  : MAIN_CLASS=$MAIN_CLASS MAIN_ARGS=$MAIN_ARGS"
    # See http://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
    $TIMER && TIMER_START=$(date +"%s")
}

help() {
    cat << EOS
Usage: $BASENAME { <option> | <subcommand> }

  Options:
    -cached      select main class with cached startup time
    -debug       print commands executed by this script
    -timer       print total execution time
    -verbose     print progress messages

  Subcommands:
    clean        delete generated files
    compile      compile C/Java source files
    help         print this help message
    run          execute main class "$MAIN_CLASS"
EOS
}

clean() {
    if [[ -d "$TARGET_DIR" ]]; then
        if $DEBUG; then
            debug "Delete directory $TARGET_DIR"
        elif $VERBOSE; then
            echo "Delete directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
        fi
        rm -rf "$TARGET_DIR"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
}

compile() {
    compile_java
    [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
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

compile_java() {
    [[ -d "$CLASSES_DIR" ]] || mkdir -p "$CLASSES_DIR"

    local timestamp_file="$TARGET_DIR/.latest-build"

    local required=0
    required=$(action_required "$timestamp_file" "$JAVA_SOURCE_DIR/" "*.java")
    [[ $required -eq 1 ]] || return 1

    local opts_file="$TARGET_DIR/javac_opts.txt"
    local cpath="$CLASSES_DIR"
    echo -classpath "$cpath" -d "$CLASSES_DIR" > "$opts_file"

    local sources_file="$TARGET_DIR/javac_sources.txt"
    [[ -f "$sources_file" ]] && rm "$sources_file"
    local n=0
    for f in $(find "$JAVA_SOURCE_DIR/" -type f -name "*.java" 2>/dev/null); do
        echo $f >> "$sources_file"
        n=$((n + 1))
    done
    if [[ $n -eq 0 ]]; then
        warning "No Java source file found"
        return 1
    fi
    local s=; [[ $n -gt 1 ]] && s="s"
    local n_files="$n Java source file$s"
    if $DEBUG; then
        debug "$JAVAC_CMD @$opts_file @$sources_file"
    elif $VERBOSE; then
        echo "Compile $n_files to directory \"${CLASSES_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "$JAVAC_CMD" "@$opts_file" "@$sources_file"
    if [[ $? -ne 0 ]]; then
        error "Failed to compile $n_files to directory \"${CLASSES_DIR/$ROOT_DIR\//}\""
        cleanup 1
    fi
    touch "$timestamp_file"
}

run() {
    $DEBUG && debug "$JAVA_CMD -cp $CLASSES_DIR $MAIN_CLASS $MAIN_ARGS"
    eval "$JAVA_CMD" -cp $CLASSES_DIR $MAIN_CLASS $MAIN_ARGS
}

##############################################################################
## Environment setup

BASENAME=$(basename "${BASH_SOURCE[0]}")

EXITCODE=0

ROOT_DIR="$(getHome)"

SOURCE_DIR="$ROOT_DIR/src"
C_SOURCE_DIR="$SOURCE_DIR/main/c"
JAVA_SOURCE_DIR="$SOURCE_DIR/main/java"
JS_SOURCE_DIR="$SOURCE_DIR/main/js"
TARGET_DIR="$ROOT_DIR/target"
BIN_DIR="$TARGET_DIR/bin"
CLASSES_DIR="$TARGET_DIR/classes"

CACHED=false
CLEAN=false
COMPILE=false
DEBUG=false
HELP=false
MAIN_CLASS="Polyglot"
MAIN_ARGS=
RUN=false
TIMER=false
VERBOSE=false

COLOR_START="[32m"
COLOR_END="[0m"

## false: CYGWIN, MINGW, MSYS  
linux=false
case "$(uname -s)" in
  Linux*)  linux=true ;;
  Darwin*) linux=true
esac
$linux || error "Only Linux/MacOS platforms are supported"

if [[ ! -x "$GRAALVM_HOME/bin/javac" ]]; then
    error "GraalVM installation not found"
    cleanup 1
fi
JAVA_CMD="$GRAALVM_HOME/bin/java"
JAVAC_CMD="$GRAALVM_HOME/bin/javac"

if [[ ! -x "$GRAALVM_HOME/bin/lli" ]]; then
    error "lli command not found"
    cleanup 1
fi
LLI_CMD="$GRAALVM_HOME/bin/lli"
LLVM_TOOLCHAIN="$($LLI_CMD --print-toolchain-path)"

CLANG_CMD="$LLVM_TOOLCHAIN/clang"

JS_CMD="$GRAALVM_HOME/bin/js"

PROJECT_NAME="$(basename $ROOT_DIR)"
PROJECT_URL="github.com/$USER/graalvm-examples"
PROJECT_VERSION="1.0-SNAPSHOT"

args "$@"
[[ $EXITCODE -eq 0 ]] || cleanup 1

##############################################################################
## Main

$HELP && help && cleanup

if $CLEAN; then
    clean || cleanup 1
fi
if $COMPILE; then
    compile || cleanup 1
fi
if $RUN; then
    run || cleanup 1
fi
cleanup
