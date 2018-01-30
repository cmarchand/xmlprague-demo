# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.html)

### Needs

We had many requirements on the development organization :

 - we must ensure that code is not duplicated anywhere in our projcts.
    - Maintaining such code properly becomes a nightmare as the time goes
    - XML technologies generally have a strong ability to deal with overriding rule (xsd, xslt, etc.): it makes possible 
      to create common code at any level in a logical architecture
    - It helps in creating specific/generic code architecture
    - It improves quality  
 **That implies a simple way to re-use existing code.**  
 - we want common code changes won't break every projects using it :
    - we want to be able to separate each chunk of code, and identify each version with no ambiquity
      **to produce deliveries that can be identifed as deliveries and not as source code**. Let's call this an artifact.
    - we must be able to distinguish a stable release (an artifact we know exactly which commit of code has produced it), 
      from a development one (an artifact that is still under development, and that may change from one day to another)
    - we must ensure that a release artifact can not be re-build : i.e. a release artifact can not be modified
    - when we re-use a piece of existing code, we want to reference it, through a release artifact reference ; hence, we are
      sure the referenced code will never be modified
 - we want every artifact version being accessible from any other project easily
    - we need to publish build artifacts to a central repository ; this central repository will be then used to get artifacts
      when needed
 - we must ensure that unit tests are always successfully run before building an artifact
 - we must be able to deploy programs to target locations from the central repository
    - a "program" is usually an aggregation of many artifacts
 - last but not least, we want all these requirements to work the same way for our editorial XML based languages :
   Java, XSLT, XQUERY, SCHEMATRON, DTD, XSD Schema, Relax NG, etc.. Hence, developer's training is not to expensive 
 
We also have some wishes :

 - we'd like that release artifacts can only be build by a dedicated build environment ; this ensures that build command and 
 options are always the same, and that build is not performed locally by a developer, with special options. Well, we'd like that
 release buid could be repeat in case of a massive crash.
 - we'd like to deploy only compiled code
    - most of language specifications define a compile process (well, static errors, at least)
    - only XSLT 3.0 has defined that a XSL can be compiled, moved, and then run elsewhere. So, a compiled form exists, 
      even if it is not standardized. 
    - other languages may defined some compile-like process,
    - we may have some transformations to apply to source code before it can be accepted as "compiled"
    - we could define that compilation step is any operation that transform a **source** code to a **build** code.
 - we'd like to be able to generate code
 - we'd like to be able to validate an XML file, as a condition to build artifact
 - we'd like that developer documentation will be published on a Web server each time a build is performed. Hence, a developer
   who wants to use a particular artifact is able to find the documentation of this artifact.
 