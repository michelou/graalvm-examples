#!/usr/bin/env bash

## Usage: $ . ./setenv.sh

##############################################################################
## Subroutines

getHome() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ] ; do
        local linked="$(readlink "$source")"
        local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
        source="$dir/$(basename "$linked")"
    done
    ( cd -P "$(dirname "$source")" && pwd )
}

getOS() {
    local os
    case "$(uname -s)" in
        Linux*)  os=linux;;
        Darwin*) os=mac;;
        CYGWIN*) os=cygwin;;
        MINGW*)  os=mingw;;
        *)       os=unknown
    esac
    echo $os
}

getPath() {
    local path=""
    for i in $(ls -d "$1"*/ 2>/dev/null); do path=$i; done
    # ignore trailing slash introduced in for loop
    [[ -z "$path" ]] && echo "" || echo "${path::-1}"
}

##############################################################################
## Environment setup

PROG_HOME="$(getHome)"

OS="$(getOS)"
[[ $OS == "unknown" ]] && { echo "Unsuppored OS"; exit 1; }

if [[ $OS == "cygwin" || $OS == "mingw" ]]; then
    [[ $OS == "cygwin" ]] && prefix="/cygdrive" || prefix=""
    export HOME=$prefix/c/Users/$USER
    export GIT_HOME="$(getPath "$prefix/c/opt/Git-2")"
    export GRAALVM_HOME="$(getPath "$prefix/c/opt/graalvm-ce-java8-21")"
    export GRAALVM11_HOME="$(getPath "$prefix/c/opt/graalvm-ce-java11-21")"
    export LLVM_HOME="$(getPath "$prefix/c/opt/LLVM-12")"
    export MAVEN_HOME="$(getPath "$prefix/c/opt/apache-maven-3")"
	export WABT_HOME="$(getPath "$prefix/c/opt/wabt-1")"
else
    export ANT_HOME="$(getPath "/opt/apache-ant-1")"
    export GIT_HOME="$(getPath "/opt/git-2")"
    export GRAALVM_HOME="$(getPath "/opt/graalvm-ce-java8-21")"
    export GRAALVM11_HOME="$(getPath "/opt/graalvm-ce-java11-21")"
    export LLVM_HOME="$(getPath "/opt/llvm-12")"
    export KOTLIN_NATIVE_HOME="$(getPath "/opt/kotlin-native-linux-1.5")"
    export MAVEN_HOME="$(getPath "/opt/apache-maven-3")"
	export WABT_HOME="$(getPath "/opt/wabt-1")"
fi
PATH1="$PATH"
[[ -x "$GIT_HOME/bin/git" ]] && PATH1="$PATH1:$GIT_HOME/bin"
[[ -x "$MAVEN_HOME/bin/mvn" ]] && PATH1="$PATH1:$MAVEN_HOME/bin"
export PATH="$PATH1"
## echo "KOTLIN_HOME=$KOTLIN_HOME"
