# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.md)

### Needs
**[FIXME:mricaud:looks like you speek about the solution itself within the need?]**
**[FIXME:mricaud:what about making links to the solution for each item and come back to the wish list every time as a guide line?]**
**[FIXME:mricaud:Terminologie: let's say "project" here instead of artefact/programs/code?]**

We had many requirements on the development organization:

- we want to ensure that code is not duplicated anywhere in our projects.
 
     - Maintaining such code properly becomes a nightmare as the time goes
     - XML technology generally has have a strong ability to deal with overriding rule (xsd, xslt, etc.): it makes possible to create common code at any level in a logical architecture (
     - It helps thinks specific/generic code architecture
     - It improve quality

Example: calsSixtine.xsl 

     **That implies a simple way to re-use existing code.**

- we want common code changing won't break every projects calling it:

    - we want to be able to separate each chunk of code and identified each version with no ambiguity 
    
    **to produce deliveries that can be identified as a delivery and not as source code. We call this an artifact.**
    
    - we must be able to distinguish stable release of a code and a development one
    
     **an artifact we know exactly which commit of code produces it), from a snapshot**
    (an artifact that is still under development, and that may change from one day to another).
     
     - we must ensure that a release artifact can not be re-published to central repository : i.e. a release artifact can not be 
 modified

     - we must be able to deploy programs to target locations from the central repository
     -  
- We want every version "programs" to be accessible from any other project easily
 
    **publish artifacts to a central repository ; this central repository will be then used to get artifacts when
 needed**
 
- we want to ensure that unit tests are OK before building any program

- Last but not least : we want all this requirement to work with the same way for our editorial XML based languages : XSLT, XQUERY, SCHEMATRON, DTD, XSD schema, Relax NG etc.

 build system must be able to build projects with all languages we use : Java, XSL, XQuery. If we decide to use another language,
 this new language must be supported - or should be being supported - by build system.

We also have some wishes :

- we'd like that release artifacts can only be build by a dedicated build environment ; this ensure that build command and 
 options are always the same, and that build is not performed locally by a developer, with special options. Well, we'd like that
 release buid could be repeat in case of a massive crash.

- we'd like to deploy only compiled code. Most of language specifications define a compile process (well, static errors, at 
 least), but only XSLT 3.0 has defined that a XSL can be compiled, moved, and then run elsewhere. So, a compiled form exists, 
 even if it is not standardized. RelaxNG also has a kind of compiled version with the simplification steps. We also use an relax Ng 2 XSLT converter that's could be considerate as a "compilation".
 
- we'd like that developer documentation will be published on a Web server each time a build is performed. Hence, a developer
 who wants to use a particular artifact is able to find the documentation of this artifact.

- we'd like to be able to generate source code, example: schema with a light and full version ?

- we'd like to be able to validate XML file (samples, XSLT, etc.) as a condition to build each project 