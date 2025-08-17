<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       saxon-xslt-harness.xproc                                 -->
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
            name="saxon-xslt-harness"
            type="t:saxon-xslt-harness"
            exclude-inline-prefixes="pkg t map xs xsl c p"
            version="3.1">

   <p:documentation>
      <p>This pipeline executes an XSpec test suite for XSLT using the Saxon bundled with XML Calabash 3.</p>
      <p><b>Primary input:</b> An XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p>'xspec-home' option: The directory where you unzipped the XSpec archive on your filesystem.</p>
   </p:documentation>

   <p:import href="../harness-lib.xpl"/>
   
   <p:input port="source" primary="true" sequence="false"/>
   <p:output port="result" 
      serialization="map{
         'indent':true(), 
         'method':'xhtml', 
         'encoding':'UTF-8', 
         'include-content-type':true(), 
         'omit-xml-declaration':false()
      }" 
      primary="true"/>
   
   <p:option name="parameters" as="map(xs:QName,item()*)?"/>

   <!-- compile the suite into a stylesheet -->
   <t:compile-xslt name="compile">
      <p:with-option name="parameters" select="$parameters"/>
   </t:compile-xslt>

   <!-- run it on saxon -->
   <p:xslt name="run" template-name="t:main">
      <p:with-input port="source">
         <p:empty/>
      </p:with-input>
      <p:with-input port="stylesheet" pipe="@compile"/>
   </p:xslt>

   <!-- format the report -->
   <t:format-report>
      <p:with-option name="parameters" select="$parameters"/>
   </t:format-report>
   
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
