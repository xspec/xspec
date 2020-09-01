<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       compile-xslt-tests.xsl                                   -->
<!--  Author:     Jeni Tennison                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <xsl:include href="../common/xml-report-serialization-parameters.xsl" />
   <xsl:include href="xslt/catch/try-catch.xsl" />
   <xsl:include href="xslt/compile/compile-expect.xsl" />
   <xsl:include href="xslt/compile/compile-helpers.xsl" />
   <xsl:include href="xslt/compile/compile-scenario.xsl" />
   <xsl:include href="xslt/declare-variable/declare-variable.xsl" />
   <xsl:include href="xslt/external/transform-options.xsl" />
   <xsl:include href="xslt/invoke-compiled/invoke-compiled-current-scenario-or-expect.xsl" />
   <xsl:include href="xslt/node-constructor/node-constructor.xsl" />
   <xsl:include href="xslt/report/wrap-node-constructors-and-undeclare-default-ns.xsl" />
   <xsl:include href="generate-common-tests.xsl" />

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/compile-xslt-tests.xsl</pkg:import-uri>

   <!--
      Namespace alias for literal result elements
   -->
   <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl" />

   <!--
      Serialization parameters applied to the compiled stylesheet
   -->
   <xsl:output indent="yes" />

   <!--
      Main template of the XSLT-specific compiler
   -->
   <xsl:template name="x:main" as="element(xsl:stylesheet)">
      <xsl:context-item as="element(x:description)" use="required" />

      <!-- True if this XSpec is testing Schematron -->
      <xsl:variable name="is-schematron" as="xs:boolean" select="exists(@original-xspec)" />

      <!-- The compiled stylesheet element. -->
      <xsl:element name="xsl:stylesheet" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="exclude-result-prefixes" select="'#all'" />
         <xsl:attribute name="version" select="x:xslt-version(.) => x:decimal-string()" />

         <xsl:if test="not($is-external)">
            <xsl:text>&#10;   </xsl:text><xsl:comment> the tested stylesheet </xsl:comment>
            <xsl:element name="xsl:import" namespace="{$x:xsl-namespace}">
               <xsl:attribute name="href" select="@stylesheet" />
            </xsl:element>
         </xsl:if>

         <xsl:if test="x:helper">
            <xsl:comment> user-provided library module(s) </xsl:comment>
            <xsl:call-template name="x:compile-helpers" />
         </xsl:if>

         <xsl:comment> XSpec library modules providing tools </xsl:comment>
         <xsl:for-each
            select="
               '../common/runtime-utils.xsl',
               '../schematron/select-node.xsl'[$is-schematron]">
            <xsl:element name="xsl:include" namespace="{$x:xsl-namespace}">
               <xsl:attribute name="href" select="resolve-uri(.)" />
            </xsl:element>
         </xsl:for-each>

         <!-- Absolute URI of the master .xspec file (Original one if specified i.e. Schematron) -->
         <xsl:variable name="xspec-master-uri" as="xs:anyURI"
            select="(@original-xspec, $actual-document-uri)[1] cast as xs:anyURI" />
         <variable name="{x:known-UQName('x:xspec-uri')}" as="{x:known-UQName('xs:anyURI')}">
            <xsl:value-of select="$xspec-master-uri" />
         </variable>

         <!-- Compile global params and global variables. -->
         <xsl:call-template name="x:compile-global-params-and-variables" />

         <xsl:if test="$is-external">
            <!-- If no $x:saxon-config is provided by global x:variable, declare a dummy one so that
               $x:saxon-config is always available -->
            <xsl:if
               test="
                  empty(
                     x:variable[x:resolve-EQName-ignoring-default-ns(@name, .) eq xs:QName('x:saxon-config')]
                  )">
               <variable name="{x:known-UQName('x:saxon-config')}" as="empty-sequence()" />
            </xsl:if>
         </xsl:if>

         <!-- The main compiled template. -->
         <xsl:comment> the main template to run the suite </xsl:comment>
         <xsl:element name="xsl:template" namespace="{$x:xsl-namespace}">
            <xsl:attribute name="name" select="x:known-UQName('x:main')" />
            <xsl:attribute name="as" select="'empty-sequence()'" />

            <xsl:element name="xsl:context-item" namespace="{$x:xsl-namespace}">
               <xsl:attribute name="use" select="'absent'" />
            </xsl:element>

            <xsl:text>&#10;      </xsl:text><xsl:comment> info message </xsl:comment>
            <!-- Message content must be constructed at run time -->
            <message>
               <text>Testing with </text>
               <value-of select="system-property('{x:known-UQName('xsl:product-name')}')" />
               <text>
                  <xsl:text> </xsl:text>
               </text>
               <value-of select="system-property('{x:known-UQName('xsl:product-version')}')" />
            </message>

            <xsl:comment> set up the result document (the report) </xsl:comment>
            <!-- Use xsl:result-document/@format to avoid clashes with <xsl:output> in the stylesheet
               being tested which would otherwise govern the output of the report XML. -->
            <xsl:element name="xsl:result-document" namespace="{$x:xsl-namespace}">
               <xsl:choose>
                  <xsl:when test="$x:saxon-version lt x:pack-version((9, 9, 1, 1))">
                     <!-- Workaround for a Saxon bug: https://saxonica.plan.io/issues/4093 -->

                     <!-- Create a temp XSpec namespace node, because non-zero-length XSpec prefix
                        is not always available here. Any non-zero-length non-xsl prefix will do,
                        because the temp namespace node is only for the xsl:result-document element -->
                     <xsl:variable name="temp-prefix" as="xs:string"
                        select="'workaround-for-saxon-bug-4093'" />
                     <xsl:namespace name="{$temp-prefix}" select="$x:xspec-namespace" />

                     <xsl:attribute name="format"
                        select="$temp-prefix || ':xml-report-serialization-parameters'" />
                  </xsl:when>

                  <xsl:otherwise>
                     <!-- Escape curly braces because @format is AVT -->
                     <xsl:attribute name="format"
                        select="'Q{{' || $x:xspec-namespace || '}}xml-report-serialization-parameters'" />
                  </xsl:otherwise>
               </xsl:choose>

               <xsl:element name="xsl:element" namespace="{$x:xsl-namespace}">
                  <xsl:attribute name="name" select="'report'" />
                  <xsl:attribute name="namespace" select="$x:xspec-namespace" />

                  <xsl:variable name="attributes" as="attribute()+">
                     <xsl:attribute name="xspec" select="$xspec-master-uri" />

                     <!-- This @stylesheet is used by ../reporter/coverage-report.xsl -->
                     <xsl:sequence select="@stylesheet" />

                     <!-- Do not always copy @schematron.
                        @schematron may exist even when this running instance of XSpec is not
                        testing Schematron. -->
                     <xsl:if test="$is-schematron">
                        <xsl:sequence select="@schematron" />
                     </xsl:if>
                  </xsl:variable>
                  <xsl:apply-templates select="$attributes" mode="x:node-constructor" />

                  <!-- @date must be evaluated at run time -->
                  <xsl:element name="xsl:attribute" namespace="{$x:xsl-namespace}">
                     <xsl:attribute name="name" select="'date'" />
                     <xsl:attribute name="namespace" />
                     <xsl:attribute name="select" select="'current-dateTime()'" />
                  </xsl:element>

                  <!-- Generate invocations of the compiled top-level scenarios. -->
                  <xsl:text>&#10;            </xsl:text><xsl:comment> invoke each compiled top-level x:scenario </xsl:comment>
                  <xsl:call-template name="x:invoke-compiled-child-scenarios-or-expects" />
               </xsl:element>
            </xsl:element>
         </xsl:element>

         <!-- Compile the top-level scenarios. -->
         <xsl:call-template name="x:compile-child-scenarios-or-expects" />
      </xsl:element>
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
