# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.html)

### Needs

We had many requirements on the development organization :

 - we must ensure that code is not copied. That implies a simple way to re-use existing code.
 - we must be able to produce deliveries that can be identifed as a delivery and not as source code. We call this an artifact.
 - we must be able to distinguish a release (an artifact we know exactly which commit of code produces it), from a snapshot
 (an artifact that is still under development, and that may change from one day to another).
 - we must be able to publish artifacts to a central repository ; this central repository will be then used to get artifacts when
 needed
 - we must ensure that unit tests are run before building an artifact.
 - we must ensure that a release artifact can not be re-published to central repository : i.e. a release artifact can not be 
 modified
 - we must be able to deploy programs to target locations from the central repository
 - build system must be able to build projects with all languages we use : Java, XSL, XQuery. If we decide to use another language,
 this new language must be supported - or should be being supported - by build system.
 
We also have some wishes :

 - we'd like that release artifacts can only be build by a dedicated build environment ; this ensure that build command and 
 options are always the same, and that build is not performed locally by a developer, with special options. Well, we'd like that
 release buid could be repeat in case of a massive crash.
 - we'd like to deploy only compiled code. Most of language specifications define a compile process (well, static errors, at 
 least), but only XSLT 3.0 has defined that a XSL can be compiled, moved, and then run elsewhere. So, a compiled form exists, 
 even if it is not standardized.
 - we'd like that developer documentation will be published on a Web server each time a build is performed. Hence, a developer
 who wants to use a particular artifact is able to find the documentation of this artifact.
 