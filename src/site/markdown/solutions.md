# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.html)

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

We do not want to have code duplicated. We all have, in our projects, references to other pieces of code, in other projects. As
there is no common mecanism to resolve those kinds of links, the usual way to solve this is to copy the code from another
project iwhere we need it. Others reference a GIT commit from another project, and checks out this commit into
project. Git as such a mecanism, but even if code code is not duplicated, files are, and may be modified in host project. We 
want to rely on existing code, that has been build accordingly to our requirements, so we need to have :

 - a way to store in a repository all release artifacts that has been build
 - a way to reference an artifact we want to use (according to usual designation method)
 - a way to access to a resource in an artifact.
 
Maven has a way to uniquely design an artifact : (groupId, artifactId, version). **groupId** represents a unique key to 
project, and is based on Java package naming conventions. **artifactId** represents something that is build by a maven module ; 
it must be unique per `groupId`. **version** represents the artifact version ; a version that ends with `-SNAPSHOT` is a snapshot, 
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

When Maven build project, Maven downloads artifacts from central repository, copy them into a local repository, and constructs a 
classpath based on dependencies listed in pom. Included dependencies may declare other dependencies, and a full classpath is construct, 
based on dependency tree.  
All resources in all jars declared as dependencies are accessible through standard Java resource loading mecanism : `getClass().getResource("upper-case.xsl")`

So, during build, Maven knows the location of jars pointed by dependencies ; they are all in local repository.

We decided to reference resources in external projects via the standard Maven dependency mecanism, and by constructing URIs
that can point a resource in a depdendency. Each dependency is associated to a URI protocol which is its artifactId. Then,
the usual way to construct a path in URIs is used to point a resource. 

 - if we want to reference the `net.sf.saxon.Transform` class in Saxon-HE 9.8.0-7 dependency, we'd construct 
 `Saxon-HE:/net/sf/saxon/Transformer.class`
 - if we want to reference the `file-utils.xsl` in `(eu.els.common, xslLibrary, 3.1.7), we'd use `xslLibrary:/file-utils.xsl`

As it is common to change a dependency version, version is not included in URI ; hence, when changing a dependency version,
code is not impacted.

We may have xsl with imports based on this URI syntax :

    <?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema" 
      exclude-result-prefixes="#all" 
      version="3.0">
      <xsl:import href="xf-sas:/xf-sas/efl/memento_bu/mem2ee.alphamem.xsl"/>

At `ìnitialize` Maven phase, so in very beginnning of build lifecycle, we do use a plugin that generates a catalog, based on
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

#### Code generation ####

We have a grammar (RelaxNG) that has to different distributions : one very strict, the other one 'lighter'. The lighter can easily be
generated from the strict one, by applying a simple transformation. Instead of ducplicating code, the strict grammar is released as
an artifact, from its source code, but the lighter is generated from the strict one. A new project has a dependency on the strict artifact,
embeds XSl to transform schema. At `generate-sources` phase, XSL are run on strict schema, and this generates the 'lighter' grammar.
Then generated sources are packaged, and deployed as a new artifact, with no source duplicated, or manually modified.

At this time, we do not have a framework to perform unit tests on RelaxNG, but this could be done with other frameworks, like XMLUnit.
Job has not be done, due to lack of resources, but this is technically possible, and could easily be embeded in a maven plugin, bind
to `test` phase. 

#### Source code documentation

Java has a standard way to produce source code documentation : javadoc. This system is now very popular, and has been adapted
to various programming languages. oXygen has defined a grammar to add documentation to XSL,
[xd-doc](https://www.oxygenxml.com/doc/versions/19.1/ug-editor/topics/XSLT-Stylesheet-documentation-support.html).
oXygen provide tools to generate a developer-oriented documentation, in an HTML format ; unfortunately, this tool is not open
source, and could not be used directly. We have created a xslDoc Maven Plugin that generates XSL documentation. This plugin
is a repor plugin, and can be added to Maven site reports. When you ask Maven to generate project's site, XSL documentation
is added to project's site.

We have also created such a plugin for XQuery documentation, based on [xquerydoc](http://github.com/xquery/xquerydoc).