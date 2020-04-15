# <span id="top">Building GraalVM on Microsoft Windows</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://www.graalvm.org/"><img src="https://www.graalvm.org/resources/img/graalvm.png" width="120" alt="GraalVM logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://www.graalvm.org/">GraalVM</a> examples coming from various websites and books.<br/>
  It also includes several <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting">batch files</a> for experimenting with <a href="https://www.graalvm.org/">GraalVM</a> on a Windows machine.
  </td>
  </tr>
</table>


## `build.bat` command

Command [**`build.bat`**](bin/graal/build.bat) supports the same [build matrix][build_matrix] as defined by the Travis configuration file [**`.travis.yml`**][travis_yml] in repository [oracle/graal][oracle_graal].
Build environments are defined in configuration file [**`build.ini`**](bin/graal/build.ini), e.g. environment **`env1`** is defined in section with same name: 

<pre style="font-size:80%;">
<b>&gt; cd</b>
G:\graal
&nbsp;
<b>&gt; more build.ini</b>
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

#### `graal\build.bat`

Command **`build .. clean dist:2`** generates the [GraalVM] build specified by build environment **`env2`** in configuration file [**`build.ini`**](bin/graal/build.ini).

<pre style="font-size:80%;">
<b>&gt; build -timer -verbose clean dist:2</b>
[...]
 Create GraalVM build with tags build,test
gate: 25 Feb 2020 10:03:01(+00:00) BEGIN: Gate
gate: 25 Feb 2020 10:03:01(+00:00) BEGIN: Versions
Running: mx --primary-suite-path 'G:\graal\\compiler' '--java-home=G:\\openjdk1.8.0_242-jvmci-20.0-b02' version --oneline
f7f5f79ddd23  mx 5.252.4
[...]
gate: 25 Feb 2020 10:03:02(+00:00) END:   Versions [0:00:00.953000]
gate: 25 Feb 2020 10:03:02(+00:00) BEGIN: JDKReleaseInfo
==== G:\\openjdk1.8.0_242-jvmci-20.0-b02 ====
[...]
gate: 25 Feb 2020 10:03:02(+00:00) END:   JDKReleaseInfo [0:00:00]
gate: 25 Feb 2020 10:03:02(+00:00) BEGIN: VerifyMultiReleaseProjects
[...]
gate: 25 Feb 2020 10:03:02(+00:01) END:   VerifyMultiReleaseProjects [0:00:00.359000]
gate: 25 Feb 2020 10:03:02(+00:01) BEGIN: Clean
Running: mx [...] clean --all
Cleaning org.graalvm.compiler.api.directives...
[...]
Cleaning TRUFFLE_TEST...
gate: 25 Feb 2020 10:04:19(+01:18) END:   Clean [0:01:17.258000]
gate: 25 Feb 2020 10:04:19(+01:18) BEGIN: BuildWithJavac
Running: mx [...] build -p --warning-as-error --force-javac
[...]
Compiling org.graalvm.compiler.java with javac-daemon(JDK 1.8)... [dependency GRAAL_OPTIONS_PROCESSOR updated]
[...]
Compiling com.oracle.truffle.dsl.processor.interop with javac-daemon(JDK 1.8)... [dependency com.oracle.truffle.dsl.processor updated]
Archiving TRUFFLE_DSL_PROCESSOR... [dependency com.oracle.truffle.dsl.processor updated]
[...]
Archiving TRUFFLE_TEST... [dependency com.oracle.truffle.api.test updated]
gate: 25 Feb 2020 10:18:59(+15:58) END:   BuildWithJavac [0:14:39.579000]
gate: 25 Feb 2020 10:18:59(+15:58) BEGIN: UnitTests: hosted-product compiler 
Running: mx -[...] unittest --suite compiler -XX:-UseJVMCICompiler
[...]
MxJUnitCore
JUnit version 4.12
[...]
Time: 465.799

OK (13227 tests)

gate: 25 Feb 2020 10:27:29(+24:28) END:   UnitTests: hosted-product compiler [0:08:30.241000]
gate: 25 Feb 2020 10:27:29(+24:28) BEGIN: XcompUnitTests: hosted-product compiler
Running: mx [...] unittest --suite compiler --fail-fast -Xcomp -XX:-UseJVMCICompiler [...]
MxJUnitCore
JUnit version 4.12
[...]
Time: 33.77

OK (111 tests)

gate: 25 Feb 2020 10:28:09(+25:08) END:   XcompUnitTests: hosted-product compiler [0:00:40.205000]
gate: 25 Feb 2020 10:28:09(+25:08) BEGIN: MakeGraalJDK
[...]
openjdk version "1.8.0_242"
OpenJDK Runtime Environment (build 1.8.0_242-b06)
OpenJDK 64-Bit Server VM Graal:compiler_ee232b09e21e1b949dadaf95fa5949a61cfff0df (build 25.242-b06-jvmci-20.0-b02, compiled mode)
gate: 25 Feb 2020 10:29:06(+26:05) END:   XCompMode:product [0:00:04.675000]
gate: 25 Feb 2020 10:29:06(+26:05) END:   Gate [0:26:05.745000]
Gate task times:
  0:00:00.953000        Versions
  0:00:00       JDKReleaseInfo
  0:00:00.359000        VerifyMultiReleaseProjects
  0:01:17.258000        Clean
  0:14:39.579000        BuildWithJavac
  0:08:30.241000        UnitTests: hosted-product compiler
  0:00:40.205000        XcompUnitTests: hosted-product compiler
  0:00:28.378000        MakeGraalJDK
  0:00:17.846000        DaCapo_pmd:BatchMode
  0:00:06.251000        DaCapo_pmd:BenchmarkCounters
  0:00:04.675000        XCompMode:product
  =======
  0:26:05.745000
Elapsed time: 00:22:03
</pre>

Directory **`vm\mxbuild\windows-amd64\dists\`** contains the generated Zip archives:

<pre style="font-size:80%;">
<b>&gt; dir sdk\mxbuild\windows-amd64\dists | findstr /e zip</b>
11.04.2020  10:07       277 714 588 graalvm-3398ab5293-java8.zip
15.03.2020  16:35       276 745 135 graalvm-unknown-java8-stage1.zip
15.03.2020  16:35       276 749 506 graalvm-unknown-java8.zip
</pre>

Archive file **`graalvm-ce-java8-loc.zip`** is the [GraalVM] software distribution; it contains the following command files:

<pre style="font-size:80%;">
<b>&gt; unzip -l sdk\mxbuild\windows-amd64\dists\graalvm-unknown-java8.zip | findstr cmd</b>
       67  2020-03-15 15:34   graalvm-unknown-java8-20.1.0-dev/bin/polyglot.cmd
     9728  2020-01-09 15:25   graalvm-unknown-java8-20.1.0-dev/bin/jcmd.exe
</pre>

Command [**`build -verbose update`**](bin/graal/build.bat) merely updates the two Github local directories `graal\` and `mx\` (*convenience command*):

<pre style="font-size:80%;">
<b>&gt; build -verbose update</b>
 Current directory is graal\
 Update local directory G:\graal\
remote: Enumerating objects: 9784, done.
[...]
From https://github.com/oracle/graal
 * branch                    master     -> FETCH_HEAD
   27c67640e10..b6022e8699b  master     -> upstream/master
[...]
 Current directory is \mx
 Update MX suite repository into directory G:\\mx
 remote: Enumerating objects: 8, done.
remote: Counting objects: 100% (8/8), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 8 (delta 4), reused 5 (delta 4), pack-reused 0
Unpacking objects: 100% (8/8), done.
From https://github.com/graalvm/mx
   1a8e2a9..6369620  master     -> origin/master
 * [new tag]         5.247.5    -> 5.247.5
 Update MX suite repository into directory G:\\mx
Updating 1a8e2a9..6369620
Fast-forward
 mx.py           | 12 +++++++++++-
 mx_benchmark.py |  7 +++++--
 2 files changed, 16 insertions(+), 3 deletions(-)
</pre>


## Troubleshooting

Graal projects rely on the [**`mx`**][mx_cli] command-line tool to build, test, run, update, etc. [GraalVM] software.

<pre style="font-size:80%;">
<b>&gt; build -timer -verbose clean dist:1</b>
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

We observe that the [**`mx`**][mx_cli] configuration accepts a restricted set of **`pylint`** versions. In our case we had to change back to version 1.9.2 (from version 2.3.1).

<pre style="font-size:80%;">
<b>&gt; cd</b>
c:\opt\Python-2.7.17
&nbsp;
<b>&gt; Scripts\pip uninstall package pylint</b>
[...]
  Successfully uninstalled pylint-2.3.1
&nbsp;
<b>&gt; Scripts\pip install pylint==1.9.2</b>
Collecting pylint==1.9.2
[...]
<b>&gt; Scripts\pylint.exe --version</b>
No config file found, using default configuration
pylint 1.9.2,
astroid 1.6.6
Python 2.7.17 (v2.7.17:c2f86d86e6, Oct 19 2019, 21:01:17) [MSC v.1500 64 bit (AMD64)]
</pre>

<!--
## Footnotes

<a name="footnote_01">[1]</a> ***2 GraalVM editions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
</p>
-->

***

*[mics](https://lampwww.epfl.ch/~michelou/)/April 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[build_matrix]: https://docs.travis-ci.com/user/build-matrix/
[graalvm]: https://www.graalvm.org/
[mx_cli]: https://github.com/graalvm/mx
[oracle_graal]: https://github.com/oracle/graal
[travis_yml]: https://github.com/oracle/graal/blob/master/.travis.yml
