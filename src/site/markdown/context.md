# XML Prague 2018

## Using Maven with XML development projects
[TOC](toc.md)

### Context

I'm a Java developper, since many years. I've seen and used many build systems, from a simple document that explains how to
build, to a configured build descriptor. Most of build systems I've used are script-like systems. Maven is a build descriptor,
where all the build phases are configured, not scritped. Maven has been used since 2009, and widely used since 2012.
I've worked on many projects where provided data was XML, **[FIXME:mricaud:usefull?]** and should not be turn into a relational model, or anything else.
But those projects where mostly Java projects, embedding few XML technologies, as XPath and XSL. In 2015, I started a new
contract in ELS, a publishing company, where the most important part of code were XML languages, as XSL, XQuery, XProc, RelaxNG,
and so on ; they are all familiars to you.  
I've been very surprised that some projects **[FIXME:mricaud:really?]** didn't used Source Control Management, that some projects where deployed on servers
from a SVN checkout, that some projects did not have unit tests, that there were no standard way to build a project, and to 
deploy it on a target box. 

I've started to work to define a standard way to define a project, to organize sources, to build, to
run unit tests, and a way to avoid code duplication.