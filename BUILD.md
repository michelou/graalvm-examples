# <span id="top">Building GraalVM on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://www.graalvm.org/"><img src="https://www.graalvm.org/resources/img/graalvm.png" width="120" alt="GraalVM logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This document presents the build of <a href="https://www.graalvm.org/" rel="external">GraalVM</a> software distribution on a Windows machine.
  </td>
  </tr>
</table>

## `build.bat` command

Command [**`build.bat`**](bin/graal/build.bat) supports the same [build matrix][build_matrix] as defined by the Travis configuration file [**`.travis.yml`**][travis_yml] in repository [oracle/graal][oracle_graal].
Build environments are defined in configuration file [**`build.ini`**](bin/graal/build.ini), e.g. environment **`env1`** is defined in section with same name: 

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a></b>
G:\graal
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/more">more</a> <a href="bin/graal/build.ini">build.ini</a></b>
[env1]
JDK=jdk8
GATE=style,fullbuild
PRIMARY=substratevm
DYNAMIC_IMPORTS=
LLVM_VERSION=
DISABLE_POLYGLOT=
DISABLE_LIBPOLYGLOT=
NO_FEMBED_BITCODE=
[env2]
...
</pre>

## <span id="usage_examples">Usage examples</span>

### **`graal\build.bat`**

Command **`build clean dist:2`** generates the [GraalVM] build specified by build environment **`env2`** in configuration file [**`build.ini`**](bin/graal/build.ini).

<pre style="font-size:80%;">
<b>&gt; <a href="bin/graal/build.bat">build</a> -timer -verbose clean dist:2</b>
G:\\openjdk1.8.0_302-jvmci-21.3-b05
openjdk version "1.8.0_302"
OpenJDK Runtime Environment (build 1.8.0_302-b05)
OpenJDK 64-Bit Server VM (build 25.302-b05-jvmci-21.3-b05, mixed mode)
 Create GraalVM build with tags build,test
[...]
gate: 15 Mar 2021 00:38:26(+00:00) BEGIN: Gate
gate: 15 Mar 2021 00:38:26(+00:00) BEGIN: Versions
[...]
Python version: sys.version_info(major=2, minor=7, micro=17, releaselevel='final', serial=0)
gate: 15 Mar 2021 00:38:27(+00:00) END:   Versions [0:00:00.979000]
gate: 15 Mar 2021 00:38:27(+00:00) BEGIN: JDKReleaseInfo
==== G:\\openjdk1.8.0_302-jvmci-21.2-b07 ====
JAVA_VERSION="1.8.0_302"
OS_NAME="Windows"
OS_VERSION="5.2"
OS_ARCH="amd64"
SOURCE=" jvmci:afddee857a6c"
gate: 15 Mar 2021 00:38:27(+00:00) END:   JDKReleaseInfo [0:00:00]
gate: 15 Mar 2021 00:38:27(+00:00) BEGIN: VerifyMultiReleaseProjects
Running: mx [...] verifymultireleaseprojects
gate: 15 Mar 2021 00:38:27(+00:01) END:   VerifyMultiReleaseProjects [0:00:00.216000]
gate: 15 Mar 2021 00:38:27(+00:01) BEGIN: Clean
Running: mx [...] clean --all
Cleaning org.graalvm.compiler.api.directives...
[...]
Cleaning TRUFFLE_TEST...
gate: 15 Mar 2021 00:38:41(+00:14) END:   Clean [0:00:13.536000]
gate: 15 Mar 2021 00:38:41(+00:14) BEGIN: BuildWithJavac
Running: mx [...] build -p --warning-as-error --force-javac
WARNING: parallel builds are not supported on windows: can not use -p
JAVA_HOME: G:\\openjdk1.8.0_292-jvmci-21.1-b04
[...]
[Stopped javac-daemon on port 50330 for Java 1.8.0_292 (1.8) from G:\openjdk1.8.0_292-jvmci-21.1-b04]
Shutting down
gate: 15 Mar 2021 00:51:08(+12:42) END:   BuildWithJavac [0:12:27.865000]
gate: 15 Mar 2021 00:51:08(+12:42) BEGIN: UnitTests: hosted-product compiler
Running: mx [...] unittest --suite compiler --verbose --enable-timing --fail-fast -XX:-UseJVMCICompiler
[...]
JUnit version 4.12
[...]
org.graalvm.util.test.CollectionUtilTest finished 11.8 ms
Time: 470.271

OK (14248 tests)
[...]
gate: 15 Mar 2021 01:00:00(+21:34) END:   UnitTests: hosted-product compiler [0:08:51.916000]
gate: 15 Mar 2021 01:00:00(+21:34) BEGIN: XcompUnitTests: hosted-product compiler
[...]
gate: 15 Mar 2021 01:00:44(+22:18) END:   XcompUnitTests: hosted-product compiler [0:00:43.763000]
gate: 15 Mar 2021 01:00:44(+22:18) BEGIN: MakeGraalJDK
[...]
gate: 15 Mar 2021 01:01:19(+22:52) END:   MakeGraalJDK [0:00:34.575000]
gate: 15 Mar 2021 01:01:19(+22:52) BEGIN: DaCapo_pmd:BatchMode
[...]
gate: 15 Mar 2021 01:01:30(+23:04) END:   DaCapo_pmd:BatchMode [0:00:11.438000]
gate: 15 Mar 2021 01:01:30(+23:04) BEGIN: DaCapo_pmd:BenchmarkCounters
[...]
gate: 15 Mar 2021 01:01:37(+23:10) END:   DaCapo_pmd:BenchmarkCounters [0:00:06.563000]
gate: 15 Mar 2021 01:01:37(+23:10) BEGIN: XCompMode:product
[...]
gate: 15 Mar 2021 01:01:42(+23:15) END:   XCompMode:product [0:00:04.899000]
gate: 15 Mar 2021 01:01:42(+23:15) BEGIN: DaCapo_pmd:PreserveFramePointer
[...]
gate: 15 Mar 2021 09:23:01(+23:59) END:   DaCapo_pmd:PreserveFramePointer [0:00:13.985000]
gate: 15 Mar 2021 09:23:01(+23:59) END:   Gate [0:23:59.406000]
Gate task times:
  0:00:01.509000        Versions [always]
  0:00:00.015000        JDKReleaseInfo [always]
  0:00:00.417000        VerifyMultiReleaseProjects [always]
  0:00:29.816000        Clean [build,fullbuild,ecjbuild]
  0:31:58.855000        BuildWithJavac [build,fullbuild]
  0:26:42.410000        UnitTests: hosted-product compiler [test,fulltest,coverage]
  0:01:05.481000        XcompUnitTests: hosted-product compiler [test,fulltest]
  0:06:02.268000        MakeGraalJDK [test,fulltest]
  0:00:11.421000        DaCapo_pmd:BatchMode [test,fulltest]
  0:00:07.078000        DaCapo_pmd:BenchmarkCounters [test,fulltest]
  0:00:05.374000        XCompMode:product [test,fulltest]
  0:00:13.541000        DaCapo_pmd:PreserveFramePointer [test,fulltest]
  =======
  1:06:58.201000
Total elapsed time: 01:07:40
</pre>

Directory **`vm\mxbuild\windows-amd64\dists\`** contains the generated Zip archives:

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> sdk\mxbuild\windows-amd64\dists | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /e zip</b>
14.11.2021  09:24 PM       368,496,421 graaljdk-ce-71c25d3e58-java8.zip
14.11.2021  09:23 PM     1,127,421,083 graalvm-8b1d3688a5-java8.zip
</pre>

Archive file **`graalvm-8b1d3688a5-java8.zip`** is the [GraalVM] software distribution; it contains the following command files:

<pre style="font-size:80%;">
<b>&gt; <a href="https://linux.die.net/man/1/unzip">unzip</a> -l sdk\mxbuild\windows-amd64\dists\graalvm-8b1d3688a5-java8.zip | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> \.cmd</b>
      389  2021-11-14 21:23   graalvm-8b1d3688a5-java8-22.0.0-dev/bin/polyglot.cmd
      398  2021-11-14 21:23   graalvm-8b1d3688a5-java8-22.0.0-dev/jre/bin/polyglot.cmd
     8330  2021-11-14 21:16   graalvm-8b1d3688a5-java8-22.0.0-dev/jre/lib/polyglot/bin/polyglot.cmd
</pre>

Command [**`build -verbose update`**](bin/graal/build.bat) merely updates the two Github local directories `graal\` and `mx\` (*convenience command*):

<pre style="font-size:80%;">
<b>&gt; <a href="bin/graal/build.bat">build</a> -verbose update</b>
 Current directory is graal\
 Update local directory G:\graal\
remote: Enumerating objects: 4573, done.
[...]
From https://github.com/oracle/graal
 * branch                    master     -> FETCH_HEAD
   bfd6bc519cd..eabd668cc88  master     -> upstream/master
[...]
 Current directory is \mx
 Update MX suite repository into directory G:\\mx
remote: Enumerating objects: 77, done.
remote: Counting objects: 100% (77/77), done.
remote: Compressing objects: 100% (65/65), done.
remote: Total 77 (delta 32), reused 57 (delta 12), pack-reused 0
Unpacking objects: 100% (77/77), 237.67 KiB | 36.00 KiB/s, done.
From https://github.com/graalvm/mx
   1852b8b..294db34  master     -> origin/master
[...]
 * [new tag]         5.292.4    -> 5.292.4
Updating 1852b8b..294db34
Fast-forward
 ci.jsonnet                                         |   4 +-
 common.json                                        |  20 +-
 .../com.oracle.mxtool.junit/.checkstyle_checks.xml |   8 +-
 jdk_distribution_parser.py                         |  15 +-
 mx.mx/suite.py                                     |  15 +-
 mx.py                                              |  90 +++++++--
 mx_gc.py                                           | 218 +++++++++++++++++++++
 mx_ide_eclipse.py                                  |   2 -
 mx_javamodules.py                                  |   2 +-
 mx_native.py                                       |  15 +-
 mx_urlrewrites.py                                  |   2 +-
 tag_version.py                                     |  39 ++--
 12 files changed, 359 insertions(+), 71 deletions(-)
 create mode 100644 mx_gc.py
</pre>

## Troubleshooting

Graal projects rely on the [**`mx`**][mx_cli] command-line tool to build, test, run and update the [GraalVM] software.

<pre style="font-size:80%;">
<b>&gt; <a href="bin/graal/build.bat">build</a> -timer -verbose clean dist:1</b>
[...]
gate: 29 Oct 2019 17:38:46(+00:01) BEGIN: Pylint
Running: mx [...] pylint --primary
Detected pylint version: 2.3.1
pylint version must be one of [(1, 1), (1, 9), (2, 2)] (got 2.3.1)
Pylint not configured correctly. Cannot execute Pylint task.
gate: 29 Oct 2019 17:38:54(+00:09) END:   Pylint [0:00:07.809667]
Traceback (most recent call last):
  File "G:\mx\mx_gate.py", line 422, in gate
    _run_gate(cleanArgs, args, tasks)
  File "G:\mx\mx_gate.py", line 496, in _run_gate
    _warn_or_abort('Pylint not configured correctly. Cannot execute Pylint task.', args.strict_mode)
  File "G:\mx\mx_gate.py", line 261, in _warn_or_abort
    reporter(msg)
  File "G:\mx\mx.py", line 3778, in abort
    raise SystemExit(error_code)
SystemExit: 1
</pre>

We observe that the [**`mx`**][mx_cli] configuration accepts a restricted set of **`pylint`** versions. In our case we had to change back to version 1.9.5 (from version 2.3.1).

<pre style="font-size:80%;">
<b>&gt; cd</b>
c:\opt\Python-2.7.18
&nbsp;
<b>&gt; <a href="https://docs.python.org/3/using/cmdline.html">python</a> -m pip uninstall pylint</b>
[...]
  Successfully uninstalled pylint-2.3.1
&nbsp;
<b>&gt; <a href="https://docs.python.org/3/using/cmdline.html">python</a> -m pip install pylint==1.9.5</b>
Collecting pylint==1.9.5
[...]
<b>&gt; Scripts\<a href="http://pylint.pycqa.org/en/latest/user_guide/run.html">pylint.exe</a> --version</b>
No config file found, using default configuration
pylint 1.9.5,
astroid 1.6.6
Python 2.7.18 (v2.7.18:8d21aa21f2, Apr 20 2020, 13:25:05) [MSC v.1500 64 bit (AMD64)]
</pre>


## <span id="footnotes">Footnotes</span>

<span id="footnote_01">[1]</span> ***MX suite directories*** [↩](#anchor_01)

<dl><dd>
</dd>
<dd>
<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> /r . suite.py</b>
G:\graal\compiler\mx.compiler\suite.py
G:\graal\examples\mx.examples\suite.py
G:\graal\java-benchmarks\mx.java-benchmarks\suite.py
G:\graal\regex\mx.regex\suite.py
G:\graal\sdk\mx.sdk\suite.py
G:\graal\substratevm\mx.substratevm\suite.py
G:\graal\sulong\mx.sulong\suite.py
G:\graal\tools\mx.tools\suite.py
G:\graal\truffle\mx.truffle\suite.py
G:\graal\vm\mx.vm\suite.py
G:\graal\vscode\mx.vscode\suite.py
G:\graal\wasm\mx.wasm\suite.py
</pre>
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/January 2022* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[build_matrix]: https://docs.travis-ci.com/user/build-matrix/
[graalvm]: https://www.graalvm.org/
[mx_cli]: https://github.com/graalvm/mx
[oracle_graal]: https://github.com/oracle/graal
[travis_yml]: https://github.com/oracle/graal/blob/master/.travis.yml
