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

Example [**`ClassInitialization\`**](ClassInitialization/) ...

Command [**`build`**](ClassInitialization/build.bat) with no argument displays the available options and subcommands:

<pre style="font-size:80%;">
<b>&gt; build</b>
Usage: build { options | subcommands }
  Options:
    -debug      show commands executed by this script
    -verbose    display progress messages
  Subcommands:
    clean       delete generated files
    compile     generate executable
    help        display this help message
    run         run the generated executable
</pre>

Command [**`build clean run`**](ClassInitialization/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>

</pre>

Command [**`build -verbose clean run`**](ClassInitialization/build.bat) also displays progress messages:

<pre style="font-size:80%;">
<b>&gt; build -verbose clean run</b>

</pre>

## <span id="CountUppercase">`CountUppercase`</span>

Example [**`CountUppercase\`**](CountUppercase/) ...

Command [**`build`**](CountUppercase/build.bat) with no argument displays the available options and subcommands:

<pre style="font-size:80%;">
<b>&gt; build</b>
Usage: build { options | subcommands }
Options:
  -debug      show commands executed by this script
  -verbose    display progress messages
Subcommands:
  clean       delete generated files
  compile     generate executable
  help        display this help message
  run         run executable
</pre>

Command [**`build clean run`**](CountUppercase/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; build clean run</b>
</pre>

<!--
## <span id="footnotes">Footnotes</a>

<a name="footnote_01">[1]</a> ***C++ Standards*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
</p>
-->

***

*[mics](http://lampwww.epfl.ch/~michelou/)/November 2019* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>
