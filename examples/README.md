# <span id="top">GraalVM code examples</span> <span style="size:30%;"><a href="../README.md">⬆</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://www.graalvm.org/"><img style="border:0;width:120px;" src="https://www.graalvm.org/resources/img/graalvm.png" alt="GraalVM"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <a href="."><strong><code>examples\</code></strong></a> contains <a href="https://llvm.org/img/LLVM-Logo-Derivative-1.png" alt="GraalVM">GraalVM</a> code examples coming from various websites - mostly from the <a href="https://www.graalvm.org/">GraalVM</a> project and tested on a Windows machine.
  </td>
  </tr>
</table>

In this document we present the following examples in more detail:

- [**`ClassInitialization`**](#ClassInitialization)
- [**`CountUppercase`**](#CountUppercase)


## <span id="ClassInitialization">`ClassInitialization`</span>

Example [**`ClassInitialization\`**](ClassInitialization/) is described in [Christian Wimmer](https://medium.com/@christian.wimmer)'s article [*Updates on Class Initialization in GraalVM Native Image Generation*](https://medium.com/graalvm/updates-on-class-initialization-in-graalvm-native-image-generation-c61faca461f7), September 12, 2019: 

Command [**`build`**](ClassInitialization/build.bat) with no argument displays the available options and subcommands:

<pre style="font-size:80%;">
<b>&gt; build</b>
Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
&nbsp;
  Options:
    -cached     select main class with cached startup time
    -debug      display commands executed by this script
    -jvmci      add JVMCI options
    -native     generate both JVM files and native image
    -verbose    display progress messages
&nbsp;
  Subcommands:
    clean       delete generated files
    check       analyze Java source files with CheckStyle
    compile     generate executable
    help        display this help message
    run         run the generated executable
</pre>

Command [**`build clean run`**](ClassInitialization/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
Startup: Fri Nov 15 22:43:31 CET 2019
Now:     Fri Nov 15 22:43:31 CET 2019
</pre>

Command [**`build -verbose clean run`**](ClassInitialization/build.bat) also displays progress messages:

<pre style="font-size:80%;">
<b>&gt; build -verbose clean run</b>
Delete directory target
Compile Java source files to directory target\classes
Execute Java main class org.graalvm.example.HelloStartupTime
Startup: Fri Nov 15 22:43:48 CET 2019
Now:     Fri Nov 15 22:43:48 CET 2019
</pre>

Command [**`build -native clean compile`**](ClassInitialization/build.bat) geerates the native image **`target\HelloStartupTime.exe`**:

<pre style="font-size:80%;">
<b>&gt; build -native clean compile</b>
<b>&gt; tree /a /f target | findstr /v "^[A-Z]"</b>
|   HelloStartupTime.exe
|   HelloStartupTime.exp
|   HelloStartupTime.lib
|   HelloStartupTime.obj
|   HelloStartupTime.pdb
|   HelloStartupTime.tmp
|   source_list.txt
|
\---classes
    \---org
        \---graalvm
            \---example
                    HelloStartupTime.class
                    Startup.class
&nbsp;
<b>&gt; target\HelloStartupTime.exe</b>
Startup: Fri Nov 15 22:50:01 CET 2019
Now:     Fri Nov 15 22:50:01 CET 2019
</pre>

Command [**`build -native -cached clean compile`**](ClassInitialization/build.bat) geerates the native image **`target\HelloCachedTime.exe`**:

<pre style="font-size:80%;">
<b>&gt; build -native -cached clean compile</b>
<b>&gt; tree /a /f target | findstr /v "^[A-Z]"</b>
|   HelloCachedTime.exe
|   HelloCachedTime.exp
|   HelloCachedTime.lib
|   HelloCachedTime.obj
|   HelloCachedTime.pdb
|   HelloCachedTime.tmp
|   source_list.txt
|
\---classes
    \---org
        \---graalvm
            \---example
                    HelloCachedTime.class
                    Startup.class
&nbsp;
<b>&gt; target\HelloCachedTime.exe</b>
Startup: Fri Nov 15 22:53:31 CET 2019
Now:     Fri Nov 15 22:53:31 CET 2019
</pre>

## <span id="CountUppercase">`CountUppercase`</span>

Example [**`CountUppercase\`**](CountUppercase/) ...

Command [**`build`**](CountUppercase/build.bat) with no argument displays the available options and subcommands:

<pre style="font-size:80%;">
<b>&gt; build</b>
Usage: build { &lt;option&gt; | &lt;subcommand&gt; }
&nbsp;
  Options:
    -debug      show commands executed by this script
    -verbose    display progress messages
&nbsp;
  Subcommands:
    clean       delete generated files
    check       analyze Java source files with CheckStyle
    compile     generate executable
    help        display this help message
    run         run executable
</pre>

Command [**`build clean run`**](CountUppercase/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
1 (1485 ms)
2 (316 ms)
3 (386 ms)
4 (185 ms)
5 (162 ms)
6 (138 ms)
7 (163 ms)
8 (154 ms)
9 (147 ms)
total: 69999993 (3274 ms)
</pre>

Command [**`build -verbose check`**](CountUppercase/build.bat) analyzes the source files with our custom CheckStyle configuration <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>:

<pre style="font-size:80%;">
<b>&gt; build -verbose check</b>
Analyze Java source files with CheckStyle configuration .graal\graal_checks.xml
Starting audit...
Audit done.
</pre>

> **:mag_right:** Directory **`%USERPROFILE%\.graal`** contains both the CheckStyle configuration file **`graal_checks.xml`** and the CheckStyle library **`checkstyle-*8.26-all.jar`** :
> <pre style="font-size:80%;">
> <b>&gt; dir /b %USERPROFILE%\.graal</b>
> checkstyle-8.26-all.jar
> graal_checks.xml
> &nbsp;
> <b>&gt; more %USERPROFILE%\.graal\graal_checks.xml</b>
> &lt;?xml version="1.0"?&gt;
> &lt;!DOCTYPE module PUBLIC
>          "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
>          "https://checkstyle.org/dtds/configuration_1_3.dtd"&gt;
> &nbsp;
> <b>&lt;module</b> name="Checker"&gt;
>     <b>&lt;property</b> name="localeCountry" value="US"/&gt;
>     <b>&lt;property</b> name="localeLanguage" value="en"/&gt;
>     <b>&lt;property</b> name="severity" value="error"/&gt;
> ...
> </pre>

## <span id="footnotes">Footnotes</a>

<a name="footnote_01">[1]</a> ***CheckStyle configuration*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
The <a href="https://checkstyle.sourceforge.io/">CheckStyle tool</a> is available as a Java archive file <a href="https://github.com/checkstyle/checkstyle/releases/"><b><code>checkstyle-*-all.jar</code></b></a> which contains two example configuration files:
</p>
<ul style="margin:0 0 1em 20px;">
<li><code>sun_checks.xml</code> (<a href="https://checkstyle.org/styleguides/sun-code-conventions-19990420/CodeConvTOC.doc.html">Sun Code Conventions</a>) and</li>
<li><code>google_checks.xml</code> (<a href="https://checkstyle.sourceforge.io/styleguides/google-java-style-20180523/javaguide.html">Google Java Style</a>).</li> 
</ul>

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
