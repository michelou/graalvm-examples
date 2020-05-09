# <span id="top">GraalVM code examples</span> <span style="size:30%;"><a href="../README.md">⬆</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://www.graalvm.org/"><img style="border:0;width:120px;" src="https://www.graalvm.org/resources/img/graalvm.png" alt="GraalVM logo"/></a>
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

Example [**`ClassInitialization\`**](ClassInitialization/) is from [Christian Wimmer](https://medium.com/@christian.wimmer)'s article [*Updates on Class Initialization in GraalVM Native Image Generation*](https://medium.com/graalvm/updates-on-class-initialization-in-graalvm-native-image-generation-c61faca461f7), September 12, 2019. It consists of the two classes [**`HelloStartupTime.java`**](ClassInitialization/src/main/java/org/graalvm/example/HelloStartupTime.java) and [**`HelloCachedTime.java`**](ClassInitialization/src/main/java/org/graalvm/example/HelloCachedTime.java).

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

Command [**`build -native clean compile`**](ClassInitialization/build.bat) generates the native image **`target\HelloStartupTime.exe`** for source file [**`HelloStartupTime.java`**](ClassInitialization/src/main/java/org/graalvm/example/HelloStartupTime.java):

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

Command [**`build -native -cached clean compile`**](ClassInitialization/build.bat) generates the native image **`target\HelloCachedTime.exe`** for source file [**`HelloCachedTime.java`**](ClassInitialization/src/main/java/org/graalvm/example/HelloCachedTime.java):

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

Command [**`build -native -debug compile`**](ClassInitialization/build.bat) shows the the settings of commands **`javac.exe`** and **`native-image.cmd`** during the generation of executable **`target\HelloStartupTime.exe`**:

<pre style="font-size:80%;">
<b>&gt; build -native -debug compile</b>
[build] _CLEAN=0 _COMPILE=1 _RUN=0 _CACHED=0 _TARGET=native _VERBOSE=0
[build] javac.exe -d G:\examples\CLASSI~1\target\classes @G:\examples\CLASSI~1\target\source_list.txt
[build] <b>===== B U I L D   V A R I A B L E S =====</b>
[build] <b>INCLUDE=C:\PROGRA~2\MICROS~1.0\VC\include;C:\PROGRA~1\MICROS~4\Windows\v7.1\include</b>
[build] <b>LIB=C:\PROGRA~2\MICROS~1.0\VC\Lib\amd64;C:\PROGRA~1\MICROS~4\Windows\v7.1\lib\x64</b>
[build] <b>=========================================</b>
[build] native-image.cmd -H:+TraceClassInitialization --initialize-at-build-time=org.graalvm.example --initialize-at-run-time=org.graalvm.example.Startup -cp G:\examples\CLASSI~1\target\classes org.graalvm.example.HelloStartupTime G:\examples\CLASSI~1\target\HelloStartupTime
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]    classlist:   3,315.44 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]        (cap):   8,256.38 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]        setup:   9,749.13 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]   (typeflow):   7,767.53 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]    (objects):   6,367.10 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]   (features):     528.67 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]     analysis:  14,991.11 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]     (clinit):     277.61 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]     universe:     645.47 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]      (parse):     962.09 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]     (inline):   2,159.67 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]    (compile):   9,242.30 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]      compile:  13,148.71 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]        image:   1,521.88 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]        write:     734.72 ms
[G:\examples\CLASSI~1\target\HelloStartupTime:12528]      [total]:  44,387.22 ms
[build] _EXITCODE=0
</pre>

## <span id="CountUppercase">`CountUppercase`</span>

Example [**`CountUppercase\`**](CountUppercase/) is a micro-benchmark:
- system property `iterations` defines how many times the counting test is performed.
- program arguments are concatenated into a sentence which is used as test input. 

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

Command [**`build clean run`**](CountUppercase/build.bat) produces the following output (system property **`iterations=5`** by default):

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
-- iteration 1 --
1 (375 ms)
2 (187 ms)
3 (141 ms)
4 (172 ms)
5 (140 ms)
6 (141 ms)
7 (187 ms)
8 (141 ms)
9 (141 ms)
total: 69999993 (1750 ms)
[...]
-- iteration 5 --
1 (125 ms)
2 (188 ms)
3 (125 ms)
4 (140 ms)
5 (141 ms)
6 (125 ms)
7 (140 ms)
8 (125 ms)
9 (141 ms)
total: 69999993 (1375 ms)
</pre>

> **:mag_right:** Executing the above command with option <b><code>-debug</code></b> also displays operations performed internally. The interesting parts are prefixed with label <b><code>[build]</code></b> (e.g. <b><code>-Diterations=5</code></b>):
> <pre style="font-size:80%;">
> <b>&gt; build run -debug | findstr /b "[debug]"</b>
> [build] _CLEAN=0 _COMPILE=1 _RUN=1 _VERBOSE=0
> [build] C:\opt\graalvm-ce-java8-19.3.1\bin\javac.exe -d G:\examples\COUNTU~1\target\classes @G:\examples\COUNTU~1\target\source_list.txt
> [build] C:\opt\graalvm-ce-java8-19.3.1\bin\java.exe -cp G:\examples\COUNTU~1\target\classes <b>-Diterations=5</b> -Dgraal.ShowConfiguration=info -Dgraal.PrintCompilation=true -Dgraal.LogFile=G:\examples\COUNTU~1\target\graal_log.txt CountUppercase In 2019 I would like to run ALL languages in one VM.
> [build] Compilation log written to G:\examples\COUNTU~1\target\graal_log.txt
> [build] _EXITCODE=0
> </pre>

Command [**`build -verbose check`**](CountUppercase/build.bat) analyzes the source files with our custom [CheckStyle][checkstyle_home] configuration <sup id="anchor_01"><a href="#footnote_01">[1]</a></sup>:

<pre style="font-size:80%;">
<b>&gt; build -verbose check</b>
Analyze Java source files with CheckStyle configuration .graal\graal_checks.xml
Starting audit...
Audit done.
</pre>

> **:mag_right:** Directory **`%USERPROFILE%\.graal`** contains both the [CheckStyle][checkstyle_home] configuration file **`graal_checks.xml`** and the CheckStyle library **`checkstyle-*-all.jar`** :
> <pre style="font-size:80%;">
> <b>&gt; dir /b %USERPROFILE%\.graal</b>
> checkstyle-8.30-all.jar
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
>     ...
>     <b>&lt;module</b> name="TreeWalker"&gt;
>     ...
>     <b>&lt;/module&gt;</b>
> <b>&lt;/module&gt;</b>
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

*[mics](https://lampwww.epfl.ch/~michelou/)/May 2020* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[checkstyle_downloads]: https://github.com/checkstyle/checkstyle/releases/
[checkstyle_home]: https://checkstyle.sourceforge.io/
[checkstyle_relnotes]: https://checkstyle.org/releasenotes.html
