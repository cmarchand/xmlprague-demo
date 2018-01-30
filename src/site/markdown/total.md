# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.html)

### Context

I'm a Java developper, since many years. I've seen and used many build systems, from a simple document that explains how to
build, to a configured build descriptor. Most of build systems I've used are script-like systems. Maven is a build descriptor,
where all the build phases are configured, not scripted. Maven has been used since 2009, and widely used since 2012.
I've worked on many projects where provided data was XML. Those projects where mostly Java projects, embedding few XML 
technologies, as XPath and XSL. In 2015, I started a new
contract in ELS, a publishing company, where the most important part of code were XML languages, as XSL, XQuery, XProc, RelaxNG,
and so on ; they are all familiars to you.  
I've been very surprised that some projects didn't used correctly Source Control Management, that some projects where deployed on servers
from a SVN checkout, that some projects did not have unit tests, that there were no standard way to build a project, and to 
deploy it on a target box. 

I've started to work to define a standard way to define a project, to organize sources, to build, to
run unit tests, and a way to avoid code duplication.

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
 
### Solutions

ELS has tested various tools and frameworks to manage their project management requirements (mainly XProject, ant). The only 
one that satifies all requirements is Maven. But Maven does not provides plugins for a lot of tasks we need.
Maven has a standard way to build : phases lifecycle.  Build has a lifecycle, and phases are sequentially organized through
this lifecycle ; one phase can not be executed if all previous phases have not been successfully executed.

According to [Maven documentation](http://maven.apache.org/ref/3.5.0/maven-core/lifecycles.html), lifecycle phases are :

 - validate
 - initialize
 - generate-sources
 - process-sources
 - generate-resources
 - process-resources
 - **compile**
 - process-classes
 - generate-test-sources
 - process-test-sources
 - generate-test-resources
 - process-test-resources
 - **test-compile**
 - process-test-classes
 - **test**
 - prepare-package
 - **package**
 - pre-integration-test
 - integration-test
 - post-integration-test
 - verify
 - **install**
 - **deploy**
 
Some phases are not in lifecycle, and do not have prerequisites :
 
 - clean
 - site

At each phase, plugins are bound. When a phase is executed, all plugins bound to this phase are executed. If one execution 
fails, all the build fails. If we need to extend maven build, we just have to declare a new plugin, and bind it to a phase.

#### Dependency management

We do not want to have code duplicated. We all have, in our projects, references to other pieces of code, in other projects.
We all have a copy of `functx.xsl` from Priscilla Wemsley, copied from project to project ! As
there is no common mecanism to resolve those kinds of links in XML world, the usual way to solve this is to copy the code from source
project, into other project where we need it. Others reference a GIT commit from another project, and checks out this commit into
project. Git as such a mecanism, but even if code is not duplicated, files are, and may be modified in host project. We 
want to rely on existing code, that has been build accordingly to our requirements, so we need to have :

 - a way to store in a repository all release artifacts that have been build
 - a way to reference an artifact we want to use (according to usual designation method)
 - a way to access to a resource in an artifact.
 
Maven has a way to uniquely identify an artifact : (groupId, artifactId, version). **groupId** represents a unique key to 
project, and is based on Java package naming conventions ; **artifactId** represents something that is build by a maven module ; 
it must be unique per `groupId` ; **version** represents the artifact version ; a version that ends with `-SNAPSHOT` is a snapshot, 
and is not strictly link to a commit in SCM. All other strings represent a release, which is supposed to be uniquely link to a
commit in SCM.

In a Java Maven project, when using an external libray is required, it's enough to declare a `dependency` in project
descriptor, `pom.xml`. If we want to use Saxon-HE 9.8.0-7 in our artifact, we just have to declare :
 
       <dependencies>
        <dependency>
          <groupId>net.sf.saxon</groupId>
          <artifactId>Saxon-HE</artifactId>
          <version>9.8.0-7</version>
        </dependency>
      </dependencies>

When Maven builds project, Maven downloads artifacts from central repository, copy them into a local repository, and constructs a 
classpath based on dependencies listed in pom. Included dependencies may declare other dependencies, and a full classpath is construct, 
based on the full dependency tree.  
All resources in all jars declared as dependencies are accessible through standard Java resource loading mecanism : `getClass().getResource("upper-case.xsl")`

So, during build, Maven knows the location of jars pointed by dependencies ; they all are in local repository.

We decided to reference resources in external projects via the standard Maven dependency mecanism, and by constructing URIs
that can point a resource in a dependency. Each dependency is associated to a **URI protocol** which is its **artifactId**. Then,
the usual way to construct a path in URIs is used to point a resource. 

 - if we want to reference the `net.sf.saxon.Transform` class in Saxon-HE 9.8.0-7 dependency,  
   we'd construct `Saxon-HE:/net/sf/saxon/Transformer.class`
 - if we want to reference the `file-utils.xsl` in `(eu.els.common, xslLibrary, 3.1.7)`,  
   we'd use `xslLibrary:/file-utils.xsl`

As it is common to change a dependency version, version is not included in URI ; hence, when changing a dependency version,
code is not impacted.

If we declare `xf-sas` dependency :

    <dependency>
      <groupId>eu.lefebvre-sarrut.sie.xmlFirst</groupId>
      <artifactId>xf-sas</artifactId>
      <version>3.1.7</version>
    </dependency>

...we may have xsl with imports based on this URI syntax :

    <?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema" 
      exclude-result-prefixes="#all" 
      version="3.0">
      <xsl:import href="xf-sas:/xf-sas/efl/memento_bu/mem2ee.alphamem.xsl"/>

At `ìnitialize` Maven phase, so in very beginnning of build lifecycle, we do use a [catalogBuilder-maven-plugin](https://github.com/cmarchand/maven-catalogBuilder-plugin) that generates a catalog, based on
dependencies declared in pom.xml. This catalog is generated at each build, so always denotes dependencies declaration available
in project descriptor. It declares `rewriteURI` and `rewriteSystem` entries, that maps protocols to jar locations. 

The catalog includes all dependencies that do contains XML resources, but also other dependencies, including the ones that do
not concern XML processing ; this could be filtered to make catalogs lighter.

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE catalog PUBLIC 
      "-//OASIS//DTD Entity Resolution XML Catalog V1.0//EN" 
      "http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd">
    <catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
      <rewriteURI 
        uriStartString="xsl-sas:/" 
        rewritePrefix="jar:file:/Users/cmarchand/.m2/repository/eu/els/sie/xmlFirst/xf-sas/1.2.1/xf-sas-1.2.1.jar!/"/>
      <rewriteSystem 
        uriStartString="xsl-sas:/" 
        rewritePrefix="jar:file:/Users/cmarchand/.m2/repository/eu/els/sie/xmlFirst/xf-sas/1.2.1/xf-sas-1.2.1.jar!/"/>
    </catalog>

This catalog is then used by all XML tools, including Maven plugins that do manipulate XML files. We have choosen to have, in all projects,
such a catalog, named `catalog.xml`, at project's root. We can then define in oXygen, that we have to use a catalog named `${pdu}/catalog.xml`;
this allows oXygen to access all resources we reference in our code, including resources located into jar files, thanks to Java
supporting URI like `jar:file:/path/to/library.jar!/resource/to/file.xsl`

This kind of resource references via URI mecanisms is quite common in XML world, and referencing resources from external dependencies
can be - and is - generalized to all types :

 - DOCTYPE definitions, references to DTD via SYSTEM declarations (we do not use PUBLIC definitions)
 - imported or included XSL
 - XML schema imports, includes, redefinitions
 - **TODO: autres exemples ?**

#### Unit tests

Once dependency management solved, we tried to run unit tests each time a build is performed. We do use XSpec as a unit test framework. 
When we started this work, two XSpec Maven plugins were available : one written by Adam Retter, one by Daisy Consortium, maintained by Romain 
Deltour, both open source and available on Github.

Maven has a standard way to organize directories in a project :

    .
    └── src
        ├── main
        │   └── java
        └── test
            └── java

We decided that our XSL code will be put under `src/main/xsl`, and XSpec files under `src/test/xspec`. So, our project structure
is always :

    .
    └── src
        ├── main
        │   └── xsl
        └── test
            └── xspec

XSpec Maven Plugin looks recursively in `src/test/xspec` for *.xspec files. Each file is executed, accordingly to XSpec 
implementation, and a report is generated. In Maven, all generated files are generated in `target/` directory. XSpec report file
are generated in `target/xspec-report`. If one XSpec unit test fails, all the plugin execution fails, *test* phase fails, and
build fails. Plugin has been largely enhanced to support catalogs, to allow to choose which Saxon product to use to perform
tests, and reporting has been changed to be mode useful. XSpec for XQuery support was not in Adam's Retter release, and has just been 
added ; but XSpec for Schematron is not yet supported. 

As far as all unit tests do not succeed, we are not able to publish a release.

[XSpec Maven Plugin](https://github.com/xspec/xspec-maven-plugin-1/) code has moved to XSpec organization, and is now maintained by
the same team that maintains XSpec. XSpec implementation is now available as a Maven artifact, and this allows to deploy quickly
XSpec corrections into XSpec Maven plugin. There is still some job to do : XSpec Maven Plugin is not able to run XSpec on Schematron,
and JUnit report is not generated. 

#### Code generation

We have a grammar (RelaxNG) that has different distributions : one very strict, the other one 'lighter'. The lighter can easily be
generated from the strict one, by applying a simple transformation. Instead of ducplicating code, the strict grammar is released as
an artifact, from its source code, but the lighter is generated from the strict one. A new project has a dependency on the strict artifact,
embeds XSL to transform schema. At `generate-sources` phase, XSL are run on strict schema, and this generates the 'lighter' grammar.
Then generated sources are packaged, and deployed as a new artifact, with no source duplicated, or manually modified.

We do use [Maven XML Plugin](http://www.mojohaus.org/xml-maven-plugin/) to apply XSL on RelaxNG source
code, and to produce the 'lighter' grammar. It allows to embed Saxon as a XSLT 2.0 processor, and supports catalogs, so no enhancement
were required to use this plugin. 

At this time, we do not have a framework to perform unit tests on RelaxNG, but this could be done with other frameworks, like XMLUnit.
Job has not be done, due to lack of resources, but this is technically possible, and could easily be embeded in a maven plugin, bind
to `test` phase.

Maven XML Plugin may be used to apply transformation on any XML source document, and is very suitable for generating sources.    

#### Source code documentation

Java has a standard way to produce source code documentation : javadoc. This system is now very popular, and has been adapted
to various programming languages. oXygen has defined a grammar to add documentation to XSL,
[xd-doc](https://www.oxygenxml.com/doc/versions/19.1/ug-editor/topics/XSLT-Stylesheet-documentation-support.html).
oXygen provides tools to generate a developer-oriented documentation, in an HTML format ; unfortunately, this tool is not open
source, and could not be used directly. We have created a [xslDoc Maven Plugin](https://github.com/cmarchand/xslDoc-maven-plugin) that generates XSL documentation. This plugin
is a report plugin, and can be added to Maven site reports. When you ask Maven to generate project's site, XSL documentation
is added to project's site.  
**TODO: add an example**

We have also created such a plugin for [XQuery documentation](https://github.com/cmarchand/xqueryDoc-maven-plugin), based on [xquerydoc](http://github.com/xquery/xquerydoc).
XQuery documentation is also generated as a site report when plugin is declared in pom.  
**TODO: add an example**