# <span id="top">GraalVM on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://www.graalvm.org/" rel="external"><img style="border:0;" src="https://www.graalvm.org/resources/img/graalvm.png" width="120" alt="GraalVM project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://www.graalvm.org/" rel="external">GraalVM</a> examples coming from various websites and books.<br/>
  It also includes several <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a> for experimenting with <a href="https://www.graalvm.org/" rel="external">GraalVM</a> on the <b>Microsoft Windows</b> platform.
  </td>
  </tr>
</table>

[Ada][ada_examples], [Akka][akka_examples], [C++][cpp_examples], [Deno][deno_examples], [Golang][golang_examples], [Haskell][haskell_examples], [Kotlin][kotlin_examples], [LLVM][llvm_examples], [Node.js][nodes_examples], [Rust][rust_examples], [Scala 3][scala3_examples], [Spring][spring_examples], [TruffleSqueak][trufflesqueak_examples] and [WiX][wix_examples] are other trending topics we are continuously monitoring.

## <span id="proj_deps">Project dependencies</span>

This project relies on the following external software for the **Microsoft Windows** platform:

- [Git 2.35][git_downloads] ([*release notes*][git_relnotes])
- [GraalVM Community Edition 21.3 LTS][graalvm_releases] <sup id="anchor_01"><a href="#footnote_01">1</a></sup> ([*release notes*][graalvm_relnotes])
- [Microsoft Visual Studio 10][vs2010_downloads] ([*release notes*][vs2010_relnotes])
- [Microsoft Windows SDK 7.1][windows_sdk]
- [Python 3.10][python_downloads] ([*release notes*][python_relnotes])

Optionally one may also install the following software:

- [UPX 3.96][upx_downloads] <sup id="anchor_03"><a href="#footnote_02">2</a></sup> ([*changelog*][upx_changelog])

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive][zip_archive] rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`][linux_opt] directory on Unix).

For instance our development environment looks as follows (*March 2022*) <sup id="anchor_03">[3](#footnote_03)</sup>:

<!-- https://stackoverflow.com/questions/8515365/are-there-other-whitespace-codes-like-nbsp-for-half-spaces-em-spaces-en-space -->
<pre style="font-size:80%;">
C:\opt\Git-2.35.1\                                    <i>(279 MB)</i>
C:\opt\graalvm-ce-java11-21.3.0\                      <i>(731 MB)</i>
C:\opt\graalvm-ce-java17-21.3.0\<sup id="anchor_04">&ensp;<a href="#footnote_04">4</a></sup>                    <i>(644 MB)</i>
C:\opt\Python-3.10.2\                                 <i>( 82 MB)</i>
C:\opt\upx-3.96-win64\                                <i>( &lt;1 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>
<!-- ce-java8 : 19.3.1 = 360 MB, 20.0.0 = 670 MB, 20.1.0 = 630 MB -->
<!--            20.2.0 = 644 MB, 20.3.0 = 668 MB, 21.0.0 = 760 MB -->
<!--            21.1.0 = 709 MB, 21.2.0 = 661 MB -->
<!-- ce-java11: 19.3.1 = 439 MB, 20.0.0 = 764 MB, 20.1.0 = 721 MB -->
<!--            20.2.0 = 731 MB, 20.3.0 = 780 MB, 21.0.0 = 930 MB -->
<!--            21.1.0 = 817 MB, 21.3.0 = 708 MB -->
<!-- ce-java17: 21.3.0 = 723 MB -->

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**][git_cli] from the command line (as well as over 250 Unix commands like [**`awk`**][man1_awk], [**`diff`**][man1_diff], [**`file`**][man1_file], [**`grep`**][man1_grep], [**`more`**][man1_more], [**`mv`**][man1_mv], [**`rmdir`**][man1_rmdir], [**`sed`**][man1_sed] and [**`wc`**][man1_wc]).

## <span id="structure">Directory structure</span>

This repository is organized as follows:
<pre style="font-size:80%;">
<a href="bin/graal/build.bat">bin\graal\build.bat</a>
docs\
examples\{<a href="./examples/README.md">README.md</a>, <a href="./examples/ClassInitialization"/>ClassInitialization</a>, ..}
graal\  <i>(<a href=".gitmodules">Git submodule</a>)</i>
<a href="https://github.com/graalvm/labs-openjdk-11/releases">labsjdk-ce-11.0.13-jvmci-21.3-b05\</a>  <i>(314 MB)</i>
mx\  <i>(<a href=".gitmodules">Git submodule</a>)</i>
<a href="https://github.com/graalvm/graal-jvmci-8/releases">openjdk1.8.0_302-jvmci-21.3-b05\</a><sup id="anchor_05"><a href="#footnote_05">[5]</a></sup> <i>(310 MB)</i>
README.md
<a href="RESOURCES.md">RESOURCES.md</a>
<a href="setenv.bat">setenv.bat</a>
</pre>

where

- file [**`bin\graal\build.bat`**](bin/graal/build.bat) is the batch script for building [GraalVM] on a Windows machine.
- directory [**`docs\`**](docs/) contains [GraalVM] related papers/articles.
- directory [**`examples\`**](examples/) contains [GraalVM] code examples (see [**`examples\README.md`**](examples/README.md)).
- directory **`graal\`** contains a copy of the [oracle/graal][oracle_graal] repository as a [Github submodule](.gitmodules).
- file [**`README.md`**](README.md) is the [Markdown][github_markdown] document for this page.
- file [**`RESOURCES.md`**](RESOURCES.md) is the [Markdown][github_markdown] document presenting external resources.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`G:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"][windows_limitation] from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**][windows_subst] to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst">subst</a> G: <a href="https://en.wikipedia.org/wiki/Environment_variable#Default_values">%USERPROFILE%</a>\workspace\graalvm-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## <span id="batch_commands">Batch commands</span>

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`clang.exe`**][llvm_clang], [**`cl.exe`**][cl_cli] or [**`git.exe`**][git_cli] directly available from the command prompt (see section [**Project dependencies**](#section_01)).

   <pre style="font-size:80%;">
   <b>&gt; <a href="setenv.bat">setenv</a> help</b>
   Usage: setenv { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -debug      show commands executed by this script
       -verbose    display environment settings
   &nbsp;
     Subcommands:
       help        display this help message</pre>

2. [**`bin\graal\build.bat`**](bin/graal/build.bat) - This batch command generates the [GraalVM] software distribution.

   <pre style="font-size:80%;">
   <b>&gt; <a href="bin/graal/build.bat">build</a> help</b>
   Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
   &nbsp;
     Options:
       -debug       show commands executed by this script
       -timer       display total elapsed time
       -verbose     display progress messages
   &nbsp;
     Subcommands:
       clean        delete generated files
       dist[:&lt;n&gt;]   generate distribution with environment n=1-9 (default=2)
                    (see environment definitions in file build.ini)
       help         display this help message
       update       fetch/merge local directories graal/mx</pre>
   > **:mag_right:** Parameter <code>n</code> in subcommand <code>dist[&colon;&lt;n&gt;]</code> refers to environment <code>env&lt;n&gt;</code> defined in configuration file [**`build.ini`**](bin/graal/build.ini).

## <span id="usage_examples">Usage examples</span>

### **`setenv.bat`**

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`javac.exe`**][javac_cli], [**`cl.exe`**][cl_cli] and [**`git.exe`**][git_cli] directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a></b>
Tool versions:
   javac 1.8.0_302, python 3.10.2, pylint 1.9.2, mx 5.316.6
   cl 16.00.40219.01 for x64, msbuild 4.8.3752.0,
   link 14.28.29912.0, nmake 14.28.29912.0, git 2.35.1.windows.1

<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1">where</a> cl java link</b>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
C:\opt\graalvm-ce-java11-21.3.0\bin\java.exe
C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; <a href="setenv.bat">setenv</a> -verbose</b>
Tool versions:
   javac 1.8.0_302, python 3.10.2, pylint 1.9.2, mx 5.316.6
   cl 16.00.40219.01 for x64, msbuild 4.8.3752.0,
   link 14.28.29912.0, nmake 14.28.29912.0, git 2.35.1.windows.1
Tool paths:
   C:\opt\graalvm-ce-java11-21.3.0\bin\javac.exe
   C:\opt\Python-3.10.2\python.exe
   C:\opt\Python-3.10.2\Scripts\pylint.exe
   G:\graalvm\mx\mx.cmd
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
   C:\opt\Git-2.35.1\usr\bin\link.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\nmake.exe
   C:\opt\Git-2.35.1\bin\git.exe
   C:\opt\Git-2.35.1\mingw64\bin\git.exe
</pre>

### **`graal\build.bat`**

Directory **`graal\`** is a Github submodule with a copy of the [oracle/graal][oracle_graal] repository; it is setup as follows:
<pre style="font-size:80%;">
<b>&gt; cp bin\graal\build.* graal</b>
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a> graal</b>
</pre>

Usage examples of command **`build.bat`** are presented in document [BUILD.md](BUILD.md).

### **`examples\**\build.bat`**

See document [**`examples\README.md`**](examples/README.md).

## <span id="resources">Resources</span>

See document [**`RESOURCES.md`**](RESOURCES.md) for [GraalVM] related resources.

## <span id="footnotes">Footnotes</span>

<span id="footnote_01">[1]</span> ***Two GraalVM editions*** [↩](#anchor_01)

<dl><dd>
<a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> is available as Community Edition (CE) and Enterprise Edition (EE): GraalVM CE is based on the <a href="https://adoptopenjdk.net/">OpenJDK 8</a> and <a href="https://www.oracle.com/technetwork/graalvm/downloads/index.html">GraalVM EE</a> is developed on top of the <a href="https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html">Java SE 1.8.0_302</a>.
</dd></dl>

<span id="footnote_02">[2]</span> ***UPX*** [↩](#anchor_02)

<dl><dd>
<a href="https://upx.github.io/">UPX</a> (<b>U</b>ltimate <b>P</b>acker for e<b>X</b>ecutables) is a free, portable, extendable, high-performance executable packer for several executable formats. It is particularly useful to reduce the size of executables produced by <a href="https://www.graalvm.org/reference-manual/native-image/"><code>native-image</code></a>.
</dd></dl>

<span id="footnote_03">[3]</span> ***Downloads*** [↩](#anchor_03)

<dl><dd>
In our case we downloaded the following installation files (see <a href="#proj_deps">section 1</a>):
</dd>
<dd>
<pre style="font-size:80%;">
<a href="https://github.com/graalvm/graalvm-ce-builds/releases">graalvm-ce-java11-windows-amd64-21.3.0.zip</a>                    <i>(306 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases">graalvm-ce-java17-windows-amd64-21.3.0.zip</a>                    <i>(320 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                                            <i>(570 MB)</i>
<a href="https://github.com/graalvm/labs-openjdk-11/releases/tag/jvmci-21.3-b04">labsjdk-ce-11.0.13+7-jvmci-21.3-b04-windows-amd64.tar.gz</a>      <i>(181 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases">native-image-installable-svm-java11-windows-amd64-21.3.0.jar</a>  <i>( 14 MB)</i>
<a href="https://github.com/graalvm/graalvm-ce-builds/releases">native-image-installable-svm-java17-windows-amd64-21.3.0.jar</a>  <i>( 16 MB)</i>
<a href="https://github.com/graalvm/graal-jvmci-8/releases">openjdk-8u302+06-jvmci-21.3-b05-windows-amd64.tar.gz</a>          <i>(123 MB)</i>
<a href="https://git-scm.com/download/win">PortableGit-2.35.1-64-bit.7z.exe</a>                              <i>( 41 MB)</i>
<a href="https://www.python.org/downloads/windows/">python-3.10.2.amd64.msi</a>                                       <i>( 19 MB)</i>
<a href="https://github.com/upx/upx/releases">upx-3.96-win64.zip</a>                                            <i>( &lt;1 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>                                     <i>(121 MB)</i>
</pre>
</dd></dl>

<span id="footnote_04">[4]</span> ***Improvements in GraalVM 20*** [↩](#anchor_04)

<dl><dd>
Versions 20.x of GraalVM bring major improvements to Windows users:
</dd>
<dd>
<ul>
<li>Command <a href="https://www.graalvm.org/docs/reference-manual/gu/" rel="external"><code>gu.cmd</code></a> is finally part of the Windows distribution !
<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1" rel="external">where</a> /r c:\opt\graalvm-ce-java11-21.3.0\ gu.*</b>
c:\opt\graalvm-ce-java11-21.3.0\bin\gu.cmd
c:\opt\graalvm-ce-java11-21.3.0\lib\installer\bin\gu.exe
</pre>
</li>
<li><a href="https://github.com/graalvm/graalvm-ce-builds/releases/tag/vm-21.2.0" rel="external"><code>native-image</code></a> and <code>rebuild-images</code> are now available as an installable component.
<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/echo">echo</a> %JAVA_HOME%</b>
C:\opt\graalvm-ce-java11-21.3.0
&nbsp;
<b>&gt; %JAVA_HOME%\bin\<a href="https://www.graalvm.org/docs/reference-manual/gu/" rel="external">gu.cmd</a> install --file native-image-installable-svm-java11-windows-amd64-21.3.0.jar --verbose</b>
Processing Component archive: native-image-installable-svm-java11-windows-amd64-21.3.0.jar
Preparing to install native-image-installable-svm-java11-windows-amd64-21.3.0.jar, contains org.graalvm.native-image, version 21.3.0 (org.graalvm.native-image)
Checking requirements of component Native Image (native-image), version 21.3.0
        Requires Graal Version = 21.3.0, GraalVM provides: 21.3.0
        Requires Java Version = 11, GraalVM provides: 11
        Requires Architecture = amd64, GraalVM provides: amd64
        Requires Operating System = windows, GraalVM provides: windows
Installing new component: Native Image (org.graalvm.native-image, version 21.3.0)
Extracting: LICENSE_NATIVEIMAGE.txt
Extracting: bin/native-image.cmd
Extracting: bin/rebuild-images.cmd
[..]
<b>&gt; c:\opt\graalvm-ce-java11-21.3.0\bin\<a href="https://www.graalvm.org/reference-manual/native-image/" rel="external">native-image.cmd</a> --version</b>
GraalVM 21.3.0 Java 11 CE (Java Version 11.0.13+7-jvmci-21.3-b05)
</pre></li>
<li>Command <a href="https://www.graalvm.org/docs/reference-manual/polyglot/" rel="external"><code>polyglot.cmd</code></a> is finally part of the Windows distribution (<i>and</i> is native).
<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/where_1" rel="external">where</a> /r c:\opt\graalvm-ce-java11-21.3.0\ polyglot.cmd</b>
c:\opt\graalvm-ce-java11-21.3.0\bin\polyglot.cmd
c:\opt\graalvm-ce-java11-21.3.0\jre\bin\polyglot.cmd
c:\opt\graalvm-ce-java11-21.3.0\jre\lib\polyglot\bin\polyglot.cmd
&nbsp;
<b>&gt; c:\opt\graalvm-ce-java11-21.3.0\bin\<a href="https://www.graalvm.org/reference-manual/polyglot-programming/#polyglot-launcher" rel="external">polyglot.cmd</a> --version</b>
GraalVM CE polyglot launcher 21.3.0
</pre></li>
</ul>
</dd></dl>

<span id="footnote_05">[5]</span> ***JVMCI** (JVM compiler interface)* [↩](#anchor_05)

<dl><dd>
The <a href="https://www.graalvm.org/">GraalVM</a> project uses its own <a href="https://github.com/graalvm/graal-jvmci-8">fork</a> of JDK8u/HotSpot with  <a href="https://openjdk.java.net/jeps/243">JVMCI</a> support for building the <a href="https://www.graalvm.org/">GraalVM</a> software distribution. <a href="https://github.com/graalvm/graal-jvmci-8/releases"><code>openjdk-jvmci</code></a> binaries are available for the Darwin, Linux and Windows platforms.
</dd></dl>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/March 2022* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[ada_examples]: https://github.com/michelou/ada-examples
[akka_examples]: https://github.com/michelou/akka-examples
[cl_cli]: https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019
[cpp_examples]: https://github.com/michelou/cpp-examples
[deno_examples]: https://github.com/michelou/deno-examples
[git_downloads]: https://git-scm.com/download/win
[git_cli]: https://git-scm.com/docs/git
[git_relnotes]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.35.1.txt
[github_markdown]: https://github.github.com/gfm/
[golang_examples]: https://github.com/michelou/golang-examples
[graalvm]: https://www.graalvm.org/
[graalvm_dev_releases]: https://github.com/graalvm/graalvm-ce-dev-builds/releases
[graalvm_releases]: https://github.com/graalvm/graalvm-ce-builds/releases/latest
[graalvm_relnotes]: https://www.graalvm.org/release-notes/21_3/
[haskell_examples]: https://github.com/michelou/haskell-examples
[javac_cli]: https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html
[kotlin_examples]: https://github.com/michelou/kotlin-examples
[linux_opt]: https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html
[llvm_clang]: https://clang.llvm.org/docs/ClangCommandLineReference.html#introduction
[llvm_examples]: https://github.com/michelou/llvm-examples
[man1_awk]: https://www.linux.org/docs/man1/awk.html
[man1_diff]: https://www.linux.org/docs/man1/diff.html
[man1_file]: https://www.linux.org/docs/man1/file.html
[man1_grep]: https://www.linux.org/docs/man1/grep.html
[man1_more]: https://www.linux.org/docs/man1/more.html
[man1_mv]: https://www.linux.org/docs/man1/mv.html
[man1_rmdir]: https://www.linux.org/docs/man1/rmdir.html
[man1_sed]: https://www.linux.org/docs/man1/sed.html
[man1_wc]: https://www.linux.org/docs/man1/wc.html
[nodes_examples]: https://github.com/michelou/nodejs-examples
[oracle_graal]: https://github.com/oracle/graal
[python_downloads]: https://www.python.org/downloads/windows/
[python_relnotes]: https://www.python.org/downloads/release/python-395/
[rust_examples]: https://github.com/michelou/rust-examples
[scala3_examples]: https://github.com/michelou/dotty-examples
[spring_examples]: https://github.com/michelou/spring-examples
[trufflesqueak_examples]: https://github.com/michelou/trufflesqueak-examples
[upx_changelog]: https://upx.github.io/upx-news.txt
[upx_downloads]: https://github.com/upx/upx/releases
[vs2010_downloads]: https://visualstudio.microsoft.com/vs/older-downloads/
[vs2010_relnotes]: https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history
[windows_limitation]: https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation
[windows_sdk]: https://www.microsoft.com/en-us/download/details.aspx?id=8279
[windows_subst]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst
[wix_examples]: https://github.com/michelou/wix-examples
[zip_archive]: https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/
