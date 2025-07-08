<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       harness-lib.xpl                                          -->
<!--  Author:     Florent Georges                                          -->
<!--  Date:       2011-11-08                                               -->
<!--  Contributors:                                                        -->
<!--        George Bina - updated to use XProc 3                           -->
<!--  Date:       2025-06-09                                               -->
<!--  URI:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2011 Florent Georges (see end of file.)              -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<p:library xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:x="http://www.jenitennison.com/xslt/xspec"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:xs="http://www.w3.org/2001/XMLSchema"
           xmlns:map="http://www.w3.org/2005/xpath-functions/map"
           pkg:import-uri="#none"
           exclude-inline-prefixes="map xs xsl x pkg p c"
           version="3.1">

   
   <!--
       Pass through and possibly log the input.
       
       If there is an option whose name is the $if-set value
       (e.g., 'log-xml-report'), the option value must be a
       URI that indicates where to log the input to this step.

       If there is no such option, no log is produced.
   -->
   <p:declare-step type="x:log" name="log">
      <!-- the port declarations -->
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      
      <p:option name="parameters" as="map(xs:QName,item()*)?"/>
      <p:option name="if-set" required="true"/>
      
      <p:group>
         <p:variable name="uri" select="map:get($parameters, xs:QName($if-set))"/>
         <p:choose>
            <p:when test="$uri != ''">
               <p:store message="[x:log] Saving {$if-set} to {$uri}.">
                  <p:with-option name="href" select="$uri"/>
               </p:store>
               <p:identity>
                  <p:with-input port="source" pipe="source@log"/>
               </p:identity>
            </p:when>
            <p:otherwise>
               <p:identity/>
            </p:otherwise>
         </p:choose>
      </p:group>
   </p:declare-step>

   <!--
       Compile the suite on source into a stylesheet on result.
   -->
   <p:declare-step type="x:compile-xslt" name="compile-xsl">
      <!-- the port declarations -->
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>

      <p:option name="parameters" as="map(xs:QName,item()*)?"/>
      
      
      <p:group>
         <p:variable name="xspec-home" select="map:get($parameters, xs:QName('xspec-home'))"/>
         <p:variable name="compiler-uri" select="map:get($parameters, xs:QName('compiler-uri'))"/>

         <!-- if compiler-uri is not passed, then use xspec-home to resolve the compiler -->
         <!-- if xspec-home is not passed, then use the packaging public URI -->
         <p:variable name="compiler"
            select="if ( $compiler-uri != '') then
                  $compiler-uri
               else if ( $xspec-home != '') then
                  resolve-uri('src/compiler/compile-xslt-tests.xsl', $xspec-home)
               else
                  'http://www.jenitennison.com/xslt/xspec/compile-xslt-tests.xsl'"/>

         <!-- load the compiler -->
         <p:load name="compiler" pkg:kind="xslt">
            <p:with-option name="href" select="$compiler"/>
         </p:load>

         <!-- actually compile the suite in a stylesheet -->
         <p:xslt>
            <p:with-input port="source" pipe="source@compile-xsl"/>
            <p:with-input port="stylesheet" pipe="@compiler"/>
            <p:with-option name="parameters" select="$parameters"/>
         </p:xslt>
      </p:group>

      <!-- log the result? -->
      <x:log if-set="log-compilation">
         <p:with-option name="parameters" select="$parameters"/>         
      </x:log>
   </p:declare-step>

   <!--
       Compile the suite on source into a query on result.
       
       Parameters to the XSpec XQuery compiler, AKA compile-xquery-tests.xsl, 
       can be passed on the parameters option (e.g. utils-library-at to suppress 
       the at location hint to use to import the XSpec utils library modules in the 
       generated query).
   -->
   <p:declare-step type="x:compile-xquery" name="compile-xq">
      <!-- the port declarations -->
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>

      <p:option name="parameters" as="map(xs:QName,item()*)?"/>
      
      <p:group>
        <!-- param: xspec-home: the dir with the sources of XSpec if EXPath packaging
             is not supported -->
         <p:variable name="xspec-home" select="map:get($parameters, xs:QName('xspec-home'))"/>
         <p:variable name="compiler-uri" select="map:get($parameters, xs:QName('compiler-uri'))"/>

         <!-- if compiler-uri is not passed, then use xspec-home to resolve the compiler -->
         <!-- if xspec-home is not passed, then use the packaging public URI -->
         <p:variable name="compiler"
            select="if ( $compiler-uri ) then
                  $compiler-uri
               else if ( $xspec-home ) then
                  resolve-uri('src/compiler/compile-xquery-tests.xsl', $xspec-home)
               else
                  'http://www.jenitennison.com/xslt/xspec/compile-xquery-tests.xsl'"/>

         <!-- wrap the generated query in a c:query element -->
         <p:string-replace match="/xsl:*/xsl:import/@href" name="compiler">
            <p:with-option name="replace" select="'''' || $compiler || ''''"/>
            <p:with-input port="source" expand-text="false">
               <p:inline exclude-inline-prefixes="#all"><xsl:stylesheet
                  exclude-result-prefixes="#all"
                  version="3.0">
   <xsl:import href="[to be replaced]" />
   <xsl:template match="document-node()" as="element(Q{http://www.w3.org/ns/xproc-step}query)">
      <query xmlns="http://www.w3.org/ns/xproc-step"><xsl:next-match /></query>
   </xsl:template>
</xsl:stylesheet></p:inline>
            </p:with-input>
         </p:string-replace>

         <!-- log the temp compiler? -->
         <x:log if-set="log-compiler">
            <p:with-option name="parameters" select="$parameters"/>         
         </x:log>

         <!-- actually compile the suite in a query -->
         <p:xslt name="do-it">
            <p:with-input port="source" pipe="source@compile-xq"/>
            <p:with-input port="stylesheet" pipe="@compiler"/>
            <p:with-option name="parameters" select="$parameters"/>
         </p:xslt>
      </p:group>
      
      <!-- log the result? -->
      <x:log if-set="log-compilation">
         <p:with-option name="parameters" select="$parameters"/>         
      </x:log>
   </p:declare-step>

   <!--
       Get the XML report on source, and give the HTML report on result.
       
       If xspec-home is set, it is used to resolve the XSLT that formats the
       report.  If not, its public URI is used, to be resolved through the
       EXPath packaging system.  If the document element is not an XSpec
       x:report, the error x:ERR001 is thrown.
   -->
   <p:declare-step type="x:format-report" name="format">
      <!-- the port declarations -->
      <p:input port="source" primary="true"/>
      <p:output port="result" primary="true"/>

      <p:option name="parameters" as="map(xs:QName,item()*)?"/>

      <p:group>
        <!-- option: xspec-home: the dir with the sources of XSpec if EXPath packaging
             is not supported -->
         <p:variable name="xspec-home" select="map:get($parameters, xs:QName('xspec-home'))"/>
         
         <p:variable name="formatter"
            select="if ( $xspec-home ) then
                  resolve-uri('src/reporter/format-xspec-report.xsl', $xspec-home)
               else
                  'http://www.jenitennison.com/xslt/xspec/format-xspec-report.xsl'"/>

         <!-- log the report? -->
         <x:log if-set="log-xml-report">
            <p:with-option name="parameters" select="$parameters"/>         
         </x:log>

         <!-- if there is a report, format it, or it is an error -->
         <p:choose>
            <p:when test="exists(/x:report)">
               <x:indent name="indent">
                  <p:with-option name="parameters" select="$parameters"/>
               </x:indent>
               <p:load name="formatter" pkg:kind="xslt">
                  <p:with-option name="href" select="$formatter"/>
               </p:load>

               <p:xslt name="format-report">
                  <p:with-input port="source" pipe="@indent"/>
                  <p:with-input port="stylesheet" pipe="@formatter"/>
                  <p:with-option name="parameters" select="$parameters"/>
               </p:xslt>
            </p:when>

            <p:otherwise>
               <p:error code="x:ERR001">
                  <p:with-input port="source">
                     <p:inline>
                        <message>Not an x:report document</message>
                     </p:inline>
                  </p:with-input>
               </p:error>
            </p:otherwise>
         </p:choose>
      </p:group>

      <!-- log the report? -->
      <x:log if-set="log-report">
         <p:with-option name="parameters" select="$parameters"/>         
      </x:log>
   </p:declare-step>

   <!-- Escapes markup. Also mimics @use-character-maps="x:disable-escaping" in
      ../compiler/xquery/main.xsl. -->
   <p:declare-step type="x:escape-markup" name="escape-markup">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>

      <p:cast-content-type content-type="text/plain"/>
      <p:text-replace pattern="&#xE801;" replacement="&lt;"/>
      <p:text-replace pattern="&#xE803;" replacement="&gt;"/>
   </p:declare-step>

   <!-- Serializes the source document with indentation and reloads it -->
   <p:declare-step type="x:indent" name="indent">
      <p:input port="source" primary="true" />
      <p:output port="result" primary="true" />

      <p:option name="parameters" as="map(xs:QName,item()*)?"/>

      <!-- Serialize with indentation. -->
      <p:cast-content-type content-type="text/plain" parameters="map{'indent':1}"/>
      
      <!-- Deserialize the string value. -->
      <p:cast-content-type content-type="text/xml"/>

      <!-- Log? -->
      <x:log if-set="log-indent">
         <p:with-option name="parameters" select="$parameters"/>         
      </x:log>
   </p:declare-step>

</p:library>


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
