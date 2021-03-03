SchXslt \[ʃˈɛksl̩t\] – An XSLT-based Schematron processor
==

SchXslt is copyright (c) 2018–2021 by David Maus &lt;dmaus@dmaus.name&gt; and released under the terms of the MIT
license.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1495494.svg)](https://doi.org/10.5281/zenodo.1495494)
[![Build Status](https://travis-ci.org/schxslt/schxslt.svg?branch=master)](https://travis-ci.org/schxslt/schxslt)

SchXslt is a Schematron processor implemented entirely in XSLT. It transforms a Schemtron schema document to an XSLT
stylesheet that you apply to the document(s) to be validated.

Limitations
--

As of date SchXslt does not properly implement the scoping rules of pattern and phase variables (see
[#135](https://github.com/schxslt/schxslt/issues/135) and [#136](https://github.com/schxslt/schxslt/issues/136)).

Schema, pattern, and phase variables are all implemented as global XSLT variables. As a consequence the name of a
schema, pattern, or phase variable must be unique in the entire schema.

Due to the constrains of XSLT 1.0 and the way rules are implemented it is not possible to use a variable inside a rule
context expression of a Schematron using the XSLT 1.0 query binding (see
[#138](https://github.com/schxslt/schxslt/issues/138)).

Installation
--

Depending on your environment there are several ways to install SchXslt.

* Starting with version 1.5 every release on [this repository's release
  page](https://github.com/schxslt/schxslt/releases) provides a ZIP file with just the XSLT stylesheets. This page also
  provides a ZIP file with the XSLT stylesheets and two [XProc 1.0](https://w3.org/tr/xproc) steps. Just download and
  unzip.

* A Java package is published to [Maven Central](https://mvnrepository.com/artifact/name.dmaus.schxslt/schxslt). Use it
  with Maven or the Java dependency management tool of your choice.

* If you use [BaseX](https://basex.org) or [eXist](https://exist-db.org) you can download installable XQuery modulesq
  from [this repository's release page](https://github.com/schxslt/schxslt/releases) as well.

Using SchXslt
--

### XSLT Stylesheets

The simplest way to use SchXslt is to download the ZIP file with just the stylesheets from the
[releaes](https://github.com/schxslt/schxslt/releases) page. To validate documents with your Schematron you first
transform it with the ```pipeline-for-svrl.xsl``` stylesheet. This creates the XSL transformation that creates a
validation report when applied to a document.

### Java applications

To use SchXslt in your Java application define the following Maven dependency:

```xml
<dependency>
  <groupId>name.dmaus.schxslt</groupId>
  <artifactId>schxslt</artifactId>
  <version>{VERSION}</version>
</dependency>
```

Where {VERSION} is replaced with the current SchXslt version.

Also take a look at [SchXslt Java](https://github.com/schxslt/schxslt-java), a set of Java classes for Schematron
validation with SchXslt.

### XQuery

The XQuery module provides a function ```schxslt:validate()``` that validates a document and returns a validation report
expressed in the Schematron Validation Report Language (SVRL). You import the module using its namespace URI.

```
import module namespace schxslt = "https://doi.org/10.5281/zenodo.1495494";

let $document := <ex:example xmlns:ex="https://example.com/ns"/>
let $schema :=
  <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern>
      <sch:rule context="/">
        <sch:assert test="true()">Always true</sch:assert>
      </sch:rule>
    </sch:pattern>
  </sch:schema>

return
  schxslt:validate($document, $schema)

```

### Ant

TBD

### Command line

TBD

Building
--

SchXslt uses the [Maven](https://maven.apache.org) build tool to create installable packages. To create the packages for
yourself clone this repository, install [Maven](https://maven.apache.org) and run it with the ```package``` phase.

```
dmaus@carbon ~ % git clone --recursive https://github.com/schxslt/schxslt.git
Cloning into 'schxslt'...
remote: Enumerating objects: 450, done.
remote: Counting objects: 100% (450/450), done.
remote: Compressing objects: 100% (298/298), done.
remote: Total 3789 (delta 172), reused 374 (delta 111), pack-reused 3339
Receiving objects: 100% (3789/3789), 470.87 KiB | 1.05 MiB/s, done.
Resolving deltas: 100% (1607/1607), done.

dmaus@carbon ~ % mvn package
```

This runs the unit tests and creates the following files:

* core/target/schxslt-{VERSION}.jar (Java archive)
* core/target/schxslt-{VERSION}-xslt-only.zip (ZIP file with stylesheets)
* exist/target/schxslt-exist-{VERSION}.xar (XQuery package for eXist)
* basex/target/schxslt-basex-{VERSION}.xar (XQuery package for BaseX)

Where {VERSION} is replaced with the current SchXslt version.
