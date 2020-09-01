<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-common-tests.xsl                                -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="3.0"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-common-tests.xsl</pkg:import-uri>

   <xsl:include href="../common/common-utils.xsl" />
   <xsl:include href="../common/namespace-utils.xsl" />
   <xsl:include href="../common/trim.xsl" />
   <xsl:include href="../common/uqname-utils.xsl" />
   <xsl:include href="../common/uri-utils.xsl" />
   <xsl:include href="../common/user-content-utils.xsl" />
   <xsl:include href="../common/version-utils.xsl" />
   <xsl:include href="base/catch/enter-sut.xsl" />
   <xsl:include href="base/combine/combine.xsl" />
   <xsl:include href="base/compile/compile-child-scenarios-or-expects.xsl" />
   <xsl:include href="base/compile/compile-global-params-and-variables.xsl" />
   <xsl:include href="base/compile/compile-scenario.xsl" />
   <xsl:include href="base/declare-variable/variable-uqname.xsl" />
   <xsl:include href="base/initial-check/perform-initial-check.xsl" />
   <xsl:include href="base/invoke-compiled/invoke-compiled-child-scenarios-or-expects.xsl" />
   <xsl:include href="base/report/report-test-attribute.xsl" />
   <xsl:include href="base/resolve-import/resolve-import.xsl" />
   <xsl:include href="base/util/compiler-eqname-utils.xsl" />
   <xsl:include href="base/util/compiler-misc-utils.xsl" />
   <xsl:include href="base/util/compiler-yes-no-utils.xsl" />

   <!--
      Global params
   -->

   <xsl:param name="force-focus" as="xs:string?" />
   <xsl:param name="is-external" as="xs:boolean"
      select="$initial-document/x:description/@run-as = 'external'" />

   <!--
      Global variables
   -->

   <!-- The initial XSpec document (the source document of the whole transformation).
      Note that this initial document is different from the document node generated within the
      default mode template. The latter document is a restructured copy of the initial document.
      Usually the compiler templates should handle the restructured one, but in rare cases some of
      the compiler templates may need to access the initial document. -->
   <xsl:variable name="initial-document" as="document-node(element(x:description))" select="/" />

   <xsl:variable name="initial-document-actual-uri" as="xs:anyURI"
      select="x:document-actual-uri($initial-document)" />

   <!--
      mode="#default"
   -->
   <xsl:mode on-multiple-match="fail" on-no-match="fail" />

   <!-- Actually, xsl:template/@match is "document-node(element(x:description))".
      "element(x:description)" is omitted in order to accept any source document and then reject it
      with a proper error message if it's broken. -->
   <xsl:template match="document-node()" as="node()+">
      <xsl:call-template name="x:perform-initial-check" />

      <!-- Resolve x:import and gather all the children of x:description -->
      <xsl:variable name="specs" as="node()+" select="x:resolve-import(x:description)" />

      <!-- Combine all the children of x:description into a single document so that the following
         language-specific transformation can handle them as a document. -->
      <xsl:variable name="combined-doc" as="document-node(element(x:description))"
         select="x:combine($specs)" />

      <!-- Switch the context to the x:description and dispatch it to the language-specific
         transformation (XSLT or XQuery) -->
      <xsl:for-each select="$combined-doc/x:description">
         <xsl:call-template name="x:main" />
      </xsl:for-each>
   </xsl:template>

</xsl:stylesheet>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2008, 2010 Jeni Tennison                                -->
<!--                                                                       -->
<!-- The contents of this file are subject to the MIT License (see the URI -->
<!-- http://www.opensource.org/licenses/mit-license.php for details).      -->
<!--                                                                       -->
<!-- Permission is hereby granted, free of charge, to any person obtaining -->
<!-- a copy of this software and associated documentation files (the       -->
<!-- "Software"), to deal in the Software without restriction, including   -->
<!-- without limitation the rights to use, copy, modify, merge, publish,   -->
<!-- distribute, sublicense, and/or sell copies of the Software, and to    -->
<!-- permit persons to whom the Software is furnished to do so, subject to -->
<!-- the following conditions:                                             -->
<!--                                                                       -->
<!-- The above copyright notice and this permission notice shall be        -->
<!-- included in all copies or substantial portions of the Software.       -->
<!--                                                                       -->
<!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       -->
<!-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    -->
<!-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.-->
<!-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  -->
<!-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  -->
<!-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     -->
<!-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
