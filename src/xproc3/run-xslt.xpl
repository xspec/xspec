<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       xslt-harness.xproc                                 -->
<!--  Author:     Florent Georges                                          -->
<!--  Date:       2011-08-30                                               -->
<!--  Contributors:                                                        -->
<!--        George Bina - updated to use XProc 3                           -->
<!--  Date:       2025-06-09                                               -->
<!--  URI:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2011 Florent Georges (see end of file.)              -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:map="http://www.w3.org/2005/xpath-functions/map"
            xmlns:t="http://www.jenitennison.com/xslt/xspec"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="http://www.jenitennison.com/xslt/xspec/saxon/harness/xslt.xproc"
            name="run-xslt"
            type="t:run-xslt"
            exclude-inline-prefixes="pkg t map xs xsl c p"
            version="3.1">

   <p:documentation>
      <p>This pipeline executes an XSpec test suite for XSLT.</p>
      <p><b>Primary input:</b> An XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p><b>Secondary output:</b> An optional formatted JUnit XSpec report.</p>
      <p>'xspec-home' option: The directory where you unzipped the XSpec archive on your filesystem.</p>
      <p>'force-focus' option: The value `#none` (case sensitive) removes focus from all the scenarios.</p>
      <p>'html-report-theme' option: Color palette for HTML report, such as `blackwhite` (black on white),
         `whiteblack` (white on black), or `classic` (earlier green/pink design). Defaults to `blackwhite`.</p>
      <p>'inline-css' option: If 'true', the HTML report embeds CSS. Use 'true' when serializing to a file
         that you want to be portable. If 'false', the HTML report links to external CSS files. Use 'false'
         when you are processing the unserialized document or do not need file portability. Defaults to 'true'.</p>
      <p>'junit-enabled' option: Whether to output a JUnit report. Values are 'true' and 'false'. Defaults to 'false'.</p>
   </p:documentation>

   <p:import href="harness-lib.xpl"/>

   <p:input port="source" primary="true" sequence="false"/>
   <p:output port="result"
      serialization="map{
         'indent':true(),
         'method':'xhtml',
         'encoding':'UTF-8',
         'include-content-type':true(),
         'omit-xml-declaration':false()
      }"
      primary="true"
      pipe="result@format-report"/>
   <p:output port="junit"
      content-types="xml"
      serialization="map{
        'method':'xml'
      }"
      primary="false"
      sequence="true"
      pipe="result@junit-report"/>

   <p:option name="xspec-home" as="xs:string?"/>
   <p:option name="force-focus" as="xs:string?"/>
   <p:option name="html-report-theme" as="xs:string" select="'default'"/>
   <p:option name="inline-css" as="xs:string" values="('true','false')" select="'true'"/>
   <p:option name="junit-enabled" as="xs:string" values="('true','false')" select="'false'"/>

   <p:option name="parameters" as="map(xs:QName,item()*)" select="map{}"/>

   <t:check-xspec-home>
      <p:with-option name="xspec-home" select="$xspec-home"/>
   </t:check-xspec-home>

   <!-- compile the suite into a stylesheet -->
   <t:compile-xslt name="compile" p:message="Creating Test Runner...">
      <p:with-option name="xspec-home" select="$xspec-home"/>
      <p:with-option name="force-focus" select="$force-focus"/>
      <p:with-option name="parameters" select="$parameters"/>
   </t:compile-xslt>

   <!-- run it -->
   <p:xslt name="run" template-name="t:main" message="&#10;Running Tests...">
      <p:with-input port="source">
         <p:empty/>
      </p:with-input>
      <p:with-input port="stylesheet" pipe="@compile"/>
   </p:xslt>

   <!-- format the report -->
   <t:format-report p:message="&#10;Formatting Report..." name="format-report">
      <p:with-option name="xspec-home" select="$xspec-home"/>
      <p:with-option name="force-focus" select="$force-focus"/>
      <p:with-option name="html-report-theme" select="$html-report-theme"/>
      <p:with-option name="inline-css" select="$inline-css"/>
      <p:with-option name="parameters" select="$parameters"/>
   </t:format-report>

   <!-- produce the JUnit report if requested -->
   <t:maybe-format-junit-report name="junit-report" p:depends="format-report">
      <p:with-input port="source" pipe="result@run"/>
      <p:with-option name="xspec-home" select="$xspec-home" />
      <p:with-option name="junit-enabled" select="$junit-enabled" />
   </t:maybe-format-junit-report>
</p:declare-step>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2011 Florent Georges                                    -->
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
