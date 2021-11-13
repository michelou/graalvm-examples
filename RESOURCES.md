# <span id="top">GraalVM Resources</span> <span style="size:30%;"><a href="README.md">↩</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;"><a href="https://www.graalvm.org/"><img src="https://www.graalvm.org/resources/img/graalvm.png" width="120" alt="GraalVM logo"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">This document presents <a href="https://www.graalvm.org/" rel="external">GraalVM</a> related resources we have collected so far.
  </td>
  </tr>
</table>

For convenience resources are organized in several topics : [General](#general), [Native image](#ni), [Polyglot](#pg) and [Sulong](#sulong).

## <span id="general">General</a>

### <span id="articles">Articles</span>

- [Mandrel: A specialized distribution of GraalVM for Quarkus][article_mandrel], April 2021.
- [GraalVM 21.0 Introduces a JVM Written in Java][article_graalvm_21_0], January 2021.
- [Leverage NPM JavaScript Module from Java application using GraalVM](https://technology.amis.nl/2019/10/25/leverage-npm-javascript-module-from-java-application-using-graalvm/) by Lucas Jellema, October 25, 2019.
- [Calling out from Java to JavaScript (with call back) – leveraging interoperability support of GraalVM][article_jellema], by Lucas Jellema, October 24, 2019.
- [An Introduction to GraalVM][article_berger] by Frits Berger, June 28, 2019.
- [Getting to Know Graal, the New Java JIT Compiler][article_evans] by [Ben Evans](https://www.infoq.com/profile/Ben-Evans/), July 16, 2018.

### <span id="blogs">Blogs</span>

- [GraalVM team blog](https://medium.com/graalvm/about) on Medium.
  - [GraalVM 21.2: Lots of native image usability improvements][blog_graalvm_21_2] by Oleg Selajev, July 2021.
  - [GraalVM 21.1 is here!][blog_graalvm_21_1] by Oleg Selajev, April 2021.
  - [GraalVM 21.0: Introducing a New Way to Run Java][blog_run_java], January 2021.
  - [Announcing GraalVM 20.2.0](https://medium.com/graalvm/announcing-graalvm-20-2-0-674e7f6dae27) by Oleg Selajev, August 2020.
- [GraalVM - Episode 2: The Holy Grail](https://faun.pub/episode-2-the-holy-grail-graalvm-building-super-optimum-microservices-architecture-series-c068b72735a1) by V. Kumar, September 2020.
- [GraalVM - Episode 1: The Evolution](https://faun.pub/episode-1-the-evolution-java-jit-hotspot-c2-compilers-building-super-optimum-containers-f0db19e6f19a) by V. Kumar, September 2020.
- [Playing with GraalVM on Windows 10 and WSL2][blog_ushio] by Tsuyoshi Ushio, May 2020.
- [Install GraalVM and run Python with debugger](http://naoko.github.io/graalvm-started/) by Naoko, April 2019.
- [Red Hat Developer](https://developers.redhat.com/): [clang/LLVM](https://developers.redhat.com/blog/category/clang-llvm/), 2018-2019.
- [Awesome GraalVM: Create a Java API on top of a JavaScript library](https://blog.yuzutech.fr/blog/java-api-on-javascript-lib-graalvm/index.html) by Guillaume Grossetie, November 22, 2018.
- [GraalVM and Groovy - how to start?](https://e.printstacktrace.blog/graalvm-and-groovy-how-to-start/), October 2018.
- [Intro to GraalVM](https://fedidat.com/510-intro-to-graal/) by [Ben Fedidat](https://fedidat.com/about/), October 2018.
- [My first impressions about Graal VM][blog_frankel] by Nicolas Fränkel, April 2018.
- [Add Graal JIT Compilation to Your JVM Language in 5 Easy Steps][blog_marr] by Stefan Marr, November 2015.

### <span id="books">Books</span>

- [Supercharge Your Applications with GraalVM][book_kumar] by Vijay Kumar, Packt, August 2021.<br/><span style="font-size:90%;">(358 pages, ISBN 9781800564909)</span>
- [GraalVM for Dummies][book_dummies] by Lawrence Miller, Wiley 2021<br/><span style="font-size:90%;">(50 pages, ISBN 978-1-119-76642-1)</span>.

### <span id="tools">Online Tools</span>

- [VM Options Explorer - GraalVM CE 19](https://chriswhocodes.com/graalvm_ce_19_options.html).

### <span id="papers">Papers</span>

- [*An Experimental Study of the Influence of DynamicCompiler Optimizations on Scala Performance*][ch_epfl_paper9] by Lukas Stadler, Gilles Duboscq, Hanspeter Mössenböck.
- [*An Empirical Study on Deoptimization in the Graal Compiler*](https://core.ac.uk/download/pdf/84869007.pdf) by Yudi Zheng, Lubomír Bulej, and Walter Binder,  ECOOP 2017.

### <span id="talks">Talks</span>

- [Understanding How Graal Works - a Java JIT Compiler Written in Java](https://chrisseaton.com/truffleruby/jokerconf17/) by Chris Seaton, JokerConf 2017, November 3, 2017.

## <span id="ni">Native image</span> <sup><sub>[**&#9650;**](#top)</sub></sup>

### <span id="ni-articles">Articles</span>

- [Create a Native Image Binary Executable for a Polyglot Java Application using GraalVM](https://technology.amis.nl/2019/10/28/create-a-native-image-binary-executable-for-a-polyglot-java-application-using-graalvm/), by Lucas Jellema, October 28, 2019.

### <span id="ni-blogs">Blogs</span>

- [GraalVM team blog](https://medium.com/graalvm/about) on Medium.
  - [Using GraalVM and Native Image on Windows 10](https://medium.com/graalvm/using-graalvm-and-native-image-on-windows-10-9954dc071311) by Olga Gupalo and Scott Seighman, September 2021.
  - [Making sense of Native Image contents](https://medium.com/graalvm/making-sense-of-native-image-contents-741a688dab4d) by Olga Gupalo, February 2021.
  - [CLI applications with GraalVM Native Image](https://medium.com/graalvm/cli-applications-with-graalvm-native-image-d629a40aa0be) by Oleg Selajev, November 2020.
- [Compressed GaalVM Native Images](https://medium.com/graalvm/compressed-graalvm-native-images-4d233766a214) by Loïc Lefèvre, December 2020.
- [Building native images and compiling with GraalVM and sbt][blog_grunert] Katrin Grunert, October 2020.
- [Running Camunda on GraalVM Native Image](https://javahippie.net/java/graal-vm/native-image/camunda/2020/05/31/camundanative.html) by Tim Zöller, May 2020.

## <span id="pg">Polyglot</span> <sup><sub>[**&#9650;**](#top)</sub></sup>

### <span id="pg-articles">Articles</span>

- [Python application running on GraalVM and Polyglotting with JavaScript, R, Ruby and Java](https://technology.amis.nl/2019/10/30/python-application-running-on-graalvm-and-polyglotting-with-javascript-r-ruby-and-java/) by Lucas Jellema, October 30, 2019.

### <span id="pg-talks">Talks</span>

- [Polyglot Applications with GraalVM](https://www.slideshare.net/jexp/polyglot-applications-with-graalvm) by Michael Hunger, OSCON 2019, July 21, 2019.
- [Polyglot on the JVM with Graal](https://www.slideshare.net/akihironishikawa/polyglot-on-the-jvm-with-graal-english) by Akihiro Nishikawa, JJUG CCC 2017, May 21, 2017.

## <span id="sulong">Sulong</span> <sup><sub>[**&#9650;**](#top)</sub></sup>

### <span id="sulong-talks">Talks</span>

- [Sulong: An experience report of using the "other end" of LLVM in GraalVM](https://llvm.org/devmtg/2019-04/talks.html#Talk_13) by Roland Schatz and Josef Eisl, 2019 European LLVM Developers Meeting, 2019.
<!--
## Footnotes

<a name="footnote_01">[1]</a> ***2 GraalVM editions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
</p>
-->
***

*[mics](https://lampwww.epfl.ch/~michelou/)/November 2021* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[article_berger]: https://www.avisi.nl/blog/an-introduction-to-graalvm-with-examples
[article_evans]: https://www.infoq.com/articles/Graal-Java-JIT-Compiler/
[article_graalvm_21_0]: https://www.infoq.com/news/2021/01/graalvm-21-jvm-java/
[article_jellema]: https://technology.amis.nl/2019/10/24/calling-out-from-java-to-javascript-with-call-back-leveraging-interoperability-support-of-graalvm/
[article_mandrel]: https://developers.redhat.com/blog/2021/04/14/mandrel-a-specialized-distribution-of-graalvm-for-quarkus#
[blog_frankel]: https://blog.frankel.ch/first-impressions-graalvm/
[blog_graalvm_21_1]: https://medium.com/graalvm/graalvm-21-1-96e18f6806bf
[blog_graalvm_21_2]: https://medium.com/graalvm/graalvm-21-2-ee2cce3b57aa
[blog_grunert]: https://www.vandebron.tech/blog/building-native-images-and-compiling-with-graalvm-and-sbt
[blog_ushio]: https://tsuyoshiushio.medium.com/playing-with-graalvm-on-windows-10-8be837007b33
[blog_marr]: https://stefan-marr.de/2015/11/add-graal-jit-compilation-to-your-jvm-language-in-5-easy-steps-step-1/
[blog_run_java]: https://medium.com/graalvm/graalvm-21-0-introducing-a-new-way-to-run-java-df894256de28
[book_dummies]: http://www.oracle.com/a/ocom/docs/beta0/js/graalvm-for-dummies-ebook.pdf
[book_kumar]: https://www.packtpub.com/product/supercharge-your-applications-with-graalvm/9781800564909
[ch_epfl_paper9]: https://lampwww.epfl.ch/~hmiller/scala2013/resources/pdfs/paper9.pdf
