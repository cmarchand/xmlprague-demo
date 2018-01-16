# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.md)

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

**[FIXME:mricaud:same order than wish list => dependency first?]**

#### Unit tests

The first step we'd configured in Maven build is executing unit tests. We do use XSpec as a unit test framework. When we started
this work, two XSpec Maven plugins were available : one written by Adam Retter, one by Daisy Consortium, maintained by Romain 
Deltour, both open source and available on Github.

Maven has a standard way to organize directories in a project :

    .
    └── src
        ├── main
        │   └── java
        └── test
            └── java

We decided that our XSL code will be put under `src/main/xsl`, and XSpec files under `src/test/xspec`. So, our project structure
is :

    .
    └── src
        ├── main
        │   └── xsl
        └── test
            └── xspec

XSpec Maven Plugin looks recursively in `src/test/xspec` for *.xspec files. Each file is executed, accordingly to XSpec 
implementation, and a report is generated. In Maven, all generated files are generated in `target/` directory. XSpec report file
is generated in `target/xspec-report`. If one XSpec unit test fails, all the plugin execution fails, *test* phase fails, and
build fails. XSpec for XQuery support was not in Adam's Retter release, and has just been added ; but XSpec for Schematron is
not yet supported.

As far as all unit tests do not succeed, we are not able to publish a release.

#### Dependency management

We do not want to have code duplicated. We all have, in our projects, references to other pieces of code, in other projects. As
there is no common mecanism to resolve those kinds of links, the common way to do is to copy the code we need from another
project into the project we want to build. Others reference a GIT commit from another project, and checks out this commit into
project. Git as such a mecanism, but even if code code is not duplicated, files are, and may be modified in host project. We 
want to rely on existing code, that has been build accordingly to our requirements, so we need to have :

 - a way to store in a repository all release artifacts that has been build
 - a way to reference an artifact we want to use (according to usual designation method)
 - a way to access to a resource in an artifact.
 
Maven has a way to uniquely design an artifact : (groupId, artifactId, version). **groupId** represents a unique key to 
project, and is based on Java package naming conventions. ArtifactId represents something that is build by a maven module ; 
it must be unique per groupId. Version represents the artifact version ; a version that ends with '-SNAPSHOT' is a snapshot, 
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

When Maven build project, Maven constructs a classpath based on dependencies listed in pom. Included dependencies may declare
other dependencies, and a full transitive  (**FIXME** : is transitive the right word ?) classpath is construct, based on dependency tree.
All resources in all jars declared as dependencies are accessible through standard Java resource loading mecanism.

So, during build, Maven knows the location of jars pointed by dependencies.

We decided to reference resources in external projects via the standard Maven dependency mecanism, and by constructing URIs
that can point a resource in a depdendency. Each dependency is associated to a URI protocol which is its artifactId. Then,
the usual way to construct a path in URIs is used to point a resource. 

 - if we want to reference the `net.sf.saxon.Transform` class in Saxon-HE 9.8.0-7 dependency, we'd construct 
 `Saxon-HE:/net/sf/saxon/Transformer.class`
 
 **[FIXME:mricaud:really?]**
 
 - if we want to reference the `file-utils.xsl`in (eu.els.common, xslLibrary, 3.1.7), we'd use `xslLibrary:/file-utils.xsl`

As it is common to change a dependency version, version is not included in URI ; hence, when changing a dependency version,
code is not impacted.

We may have xsl with imports based on this URI syntax :

    <?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema" 
      xmlns:xf-sas="http://www.lefebvre-sarrut.eu/ns/xmlfirst/sas"
      exclude-result-prefixes="#all" 
      version="3.0">
      <xsl:import href="xf-sas:/xf-sas/efl/memento_bu/mem2ee.alphamem.xsl"/>

At `ìnitialize` Maven phase, so in very beginnning of build lifecycle, we do use a plugin that generates a catalog, based on
dependencies declared in pom.xml. This catalog is generated at each build, so always denotes dependencies declaration available
in project descriptor. It declares `rewriteURI` and `rewriteSystem` entries, that maps protocol to jar file. 

**[FIXME:mricaud:explain where the jar file is stored localy?]**

The catalog includes dependencies that do contains XML resources, but also all other dependencies, including the ones that do not contains XML resources that could be accessed through resolve process that rely on a catalog.

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

This catalog is then used by all XML tools, including Maven plugins that do manipulate XML files, XSpec maven plugin for example.

**[FIXME:mricaud:working localy with Oxygen?]**