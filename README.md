# <span id="top">GraalVM on Microsoft Windows</span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://www.graalvm.org/"><img src="https://www.graalvm.org/resources/img/graalvm.png" width="120"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This repository gathers <a href="https://www.graalvm.org/">GraalVM</a> examples coming from various websites and books.<br/>
  It also includes several batch scripts for experimenting with <a href="https://www.graalvm.org/">GraalVM</a> on the <b>Microsoft Windows</b> platform.
  </td>
  </tr>
</table>

## Project dependencies

This project relies on the following external software for the **Microsoft Windows** plaform:

- [Git 2.23](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.23.0.txt))
- [GraalVM Community Edition 19.2](https://github.com/oracle/graal/releases) <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup> ([*release notes*](https://www.graalvm.org/docs/release-notes/19_2/))
- [Microsoft Visual Studio 10](https://visualstudio.microsoft.com/vs/older-downloads/) ([*release notes*](https://docs.microsoft.com/en-us/visualstudio/releasenotes/vs2010-version-history))
- [Microsoft Windows SDK 7.1](https://www.microsoft.com/en-us/download/details.aspx?id=8279)
- [Python 2.7](https://www.python.org/download/releases/2.7/) ([*release notes*](https://www.python.org/downloads/release/python-2717/))

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).

For instance our development environment looks as follows (*November 2019*) </i><sup id="anchor_02"><a href="#footnote_02">[2]</a></sup>:

<pre style="font-size:80%;">
C:\opt\Git-2.23.0\                                    <i>(271 MB)</i>
C:\opt\graalvm-ce-19.2.1\                             <i>(362 MB)</i>
C:\opt\Python-2.7.17\                                 <i>(162 MB)</i>
C:\Program Files\Microsoft SDKs\Windows\v7.1\         <i>(333 MB)</i>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\  <i>(555 MB)</i>
</pre>

> **&#9755;** ***Installation policy***<br/>
> When possible we install software from a [Zip archive](https://www.howtogeek.com/178146/htg-explains-everything-you-need-to-know-about-zipped-files/) rather than via a Windows installer. In our case we defined **`C:\opt\`** as the installation directory for optional software tools (*in reference to* the [`/opt/`](http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html) directory on Unix).
<!--
We further recommand using an advanced console emulator such as [ComEmu](https://conemu.github.io/) (or [Cmdr](http://cmder.net/)) which features [Unicode support](https://conemu.github.io/en/UnicodeSupport.html).
-->

## Directory structure

This repository is organized as follows:
<pre style="font-size:80%;">
bin\graal\build.bat
docs\
examples\
graal\                              <i>(Git submodule)</i>
mx\                                 <i>(created by</i> <a href="setenv.bat"><b><code>setenv.bat</code></b></a><i>)</i>
<a href="https://github.com/graalvm/openjdk8-jvmci-builder/releases">openjdk1.8.0_232-jvmci-19.3-b04\</a><sup id="anchor_03"><a href="#footnote_03">[3]</a></sup>  <i>(created by </i><a href="bin/graal/build.bat"><b><code>build.bat</code></b></a><i>)</i>
README.md
RESOURCES.md
setenv.bat
</pre>

where

- file [**`bin\graal\build.bat`**](bin/graal/build.bat) is the batch script for building [GraalVM](https://www.graalvm.org/) on a Windows machine.
- directory [**`docs\`**](docs/) contains several [GraalVM](https://www.graalvm.org/) related papers/articles.
- directory [**`examples\`**](examples/) contains [GraalVM](https://www.graalvm.org/) code examples (see [**`examples\README.md`**](examples/README.md)).
- directory **`graal\`** contains a copy of the [oracle/graal](https://github.com/oracle/graal) repository as a [Github submodule](.gitmodules).
- file [**`README.md`**](README.md) is the Markdown document for this page.
- file [**`RESOURCES.md`**](RESOURCES.md) is the Markdown document presenting external resources.
- file [**`setenv.bat`**](setenv.bat) is the batch script for setting up our environment.

We also define a virtual drive **`G:`** in our working environment in order to reduce/hide the real path of our project directory (see article ["Windows command prompt limitation"](https://support.microsoft.com/en-gb/help/830473/command-prompt-cmd-exe-command-line-string-limitation) from Microsoft Support).

> **:mag_right:** We use the Windows external command [**`subst`**](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/subst) to create virtual drives; for instance:
>
> <pre style="font-size:80%;">
> <b>&gt; subst G: %USERPROFILE%\workspace\graalvm-examples</b>
> </pre>

In the next section we give a brief description of the batch files present in this project.

## Batch commands

We distinguish different sets of batch commands:

1. [**`setenv.bat`**](setenv.bat) - This batch command makes external tools such as [**`clang.exe`**](https://clang.llvm.org/docs/ClangCommandLineReference.html#introduction), [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019), [**`git.exe`**](https://git-scm.com/docs/git), etc. directly available from the command prompt (see section [**Project dependencies**](#section_01)).

    <pre style="font-size:80%;">
    <b>&gt; setenv help</b>
    Usage: setenv { option | subcommand }
      Options:
        -debug      show commands executed by this script
        -verbose    display environment settings
      Subcommands:
        help        display this help message</pre>

2. [**`bin\graal\build.bat`**](bin/graal/build.bat) - This batch command generates the [GraalVM](https://www.graalvm.org/) software archive.

   <pre style="font-size:80%;">
   <b>&gt; build help</b>
   Usage: build { option | subcommand }
     Options:
       -debug       show commands executed by this script
       -timer       display total elapsed time
       -verbose     display progress messages
     Subcommands:
       clean        delete generated files
       dist[:&lt;n&gt;]   generate distribution with environment n=1-6 (default=2)
       help         display this help message
       update       fetch/merge local directories graal/mx</pre>

## Usage examples

#### `setenv.bat`

Command [**`setenv`**](setenv.bat) is executed once to setup our development environment; it makes external tools such as [**`javac.exe`**](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html), [**`cl.exe`**](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-command-line-syntax?view=vs-2019) and [**`git.exe`**](https://git-scm.com/docs/git) directly available from the command prompt:

<pre style="font-size:80%;">
<b>&gt; setenv</b>
Tool versions:
   javac 1.8.0_232, python 2.7.17, pylint 1.9.2, mx 5.244.0
   cl 16.00.40219.01 for x64, msbuild 4.8.3752.0,
   link 10.00.40219.01, nmake 10.00.40219.01, git 2.23.0.windows.1

<b>&gt; where cl java link</b>
C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
C:\opt\graalvm-ce-19.2.1\bin\java.exe
C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
</pre>

Command **`setenv -verbose`** also displays the tool paths:

<pre style="font-size:80%;">
<b>&gt; setenv -verbose</b>
Tool versions:
   javac 1.8.0_232, python 2.7.17, pylint 1.9.2, mx 5.244.0
   cl 16.00.40219.01 for x64, msbuild 4.8.3752.0,
   nmake 10.00.40219.01, git 2.23.0.windows.1
Tool paths:
   C:\opt\graalvm-ce-19.2.1\bin\javac.exe
   C:\opt\Python-2.7.17\python.exe
   C:\opt\Python-2.7.17\Scripts\pylint.exe
   G:\graalvm\mx\mx.cmd
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe
   C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.exe
   C:\opt\Git-2.23.0\usr\bin\link.exe
   C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\nmake.exe
   C:\opt\Git-2.23.0\bin\git.exe
   C:\opt\Git-2.23.0\mingw64\bin\git.exe
</pre>

#### `graal\build.bat`

Directory **`graal\`** is a Github submodule with a copy of the [oracle/graal](https://github.com/oracle/graal) repository; it is setup as follows:
<pre style="font-size:80%;">
<b>&gt; cp bin\graal\build.bat graal</b>
<b>&gt; cd graal</b>
</pre>

Command [**`build help`**](bin/graal/build.bat) displays the help message.

<pre style="font-size:80%;">
<b>&gt; build help</b>
Usage: build { options | subcommands }
  Options:
    -debug       show commands executed by this script
    -timer       display total elapsed time
    -verbose     display progress messages
  Subcommands:
    clean        delete generated files
    dist[:&lt;n&gt;]   generate distribution with environment n=1-6 (default=2)
                 (see envrionment definitions in file <b>build.ini</b>)
    help         display this help message
    update       fetch/merge local directories graal/mx</pre>

Usage examples of command **`build.bat`** are presented in document [BUILD.md](BUILD.md).

#### `examples\**\build.bat`

See document [**`examples\README.md`**](examples/README.md).

## Resources

See document [**`RESOURCES.md`**](RESOURCES.md) for [GraalVM](https://www.graalvm.org/) related resources.

## Footnotes

<a name="footnote_01">[1]</a> ***2 GraalVM editions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
<a href="https://www.graalvm.org/docs/getting-started/">GraalVM</a> is available as Community Edition (CE) and Enterprise Edition (EE): GraalVM CE is based on the <a href="https://adoptopenjdk.net/">OpenJDK 8</a> and <a href="https://www.oracle.com/technetwork/graalvm/downloads/index.html">GraalVM EE</a> is developed on top of the <a href="https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html">Java SE 1.8.0_232</a>.
</p>

<a name="footnote_02">[2]</a> ***Downloads*** [↩](#anchor_02)

<p style="margin:0 0 1em 20px;">
In our case we downloaded the following installation files (see <a href="#section_01">section 1</a>):
</p>
<pre style="margin:0 0 1em 20px; font-size:80%;">
<a href="https://git-scm.com/download/win">PortableGit-2.23.0-64-bit.7z.exe</a>     <i>( 41 MB)</i>
<a href="https://github.com/oracle/graal/releases">graalvm-ce-windows-amd64-19.2.1.zip</a>  <i>(171 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?id=8442">GRMSDKX_EN_DVD.iso</a>                   <i>(570 MB)</i>
<a href="https://www.python.org/downloads/release/python-2717/">python-2.7.17.amd64.msi</a>              <i>( 19 MB)</i>
<a href="https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=4422">VC-Compiler-KB2519277.exe</a>            <i>(121 MB)</i>
</pre>

<a name="footnote_03">[3]</a> ***JVMCI** (JVM compiler interface)* [↩](#anchor_03)

<p style="margin:0 0 1em 20px;">
The <a href="https://www.graalvm.org/">GraalVM</a> project uses its own <a href="https://github.com/graalvm/graal-jvmci-8">fork</a> of JDK8u/HotSpot with  <a href="https://openjdk.java.net/jeps/243">JVMCI</a> support for building the <a href="https://www.graalvm.org/">GraalVM</a> software distribution. <a href="https://github.com/graalvm/openjdk8-jvmci-builder/releases/"><code>openjdk-jvmci</code></a> binaries are available for the Darwin, Linux and Windows platforms.
</p>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
