<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:h="http://www.w3.org/1999/xhtml"
            xmlns:x="http://www.jenitennison.com/xslt/xspec"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:map="http://www.w3.org/2005/xpath-functions/map"
            name="run-tests-with-basex"
            type="x:run-tests-with-basex"
            version="3.1">

   <p:documentation>
      <p>This pipeline executes all .xspec files in the test/xqs directory.</p>
      <p>NOTE: This pipeline depends on the BaseX extension to XML Calabash 3 (v3.0.14 or later).</p>
      <p><b>Input ports:</b> None.</p>
      <p><b>Output ports:</b> None. This pipeline raises an error if any tests fail.</p>
      <p>'xspec-home' option: Directory of XSpec. Default: Root of this XSpec installation.</p>
      <p>'xqs-location' option: Directory of XQS. Default: lib/XQS/ under xspec-home.</p>
   </p:documentation>

   <p:import href="../../src/xproc3/schematron-xqs/run-schematron-xqs.xpl"/>
   <p:import href="../../src/xproc3/run-xquery.xpl"/>

   <p:option name="parameters" as="map(xs:QName,item()*)?"/>

   <p:variable name="parameters-augmented" as="map(xs:QName, item()*)?"
      select="map:merge(
         ($parameters, map{'xspec-home': resolve-uri('../../')}),
         map{'duplicates': 'use-first'}
      )"/>

   <p:variable name="test-dir" select="resolve-uri('.')"/>
   <p:directory-list path="{$test-dir}" max-depth="1" include-filter="\.xspec$"/>

   <p:for-each>
      <p:with-input select="//c:file"/>
      <p:variable name="test-filename" select="/*/@name"/>
      <p:load href="{$test-dir}{$test-filename}" name="test-file"/>
      <p:for-each>
         <p:with-input select="/x:description/(@schematron | @query)/name()"/>
         <p:variable name="test-type" select="."/>
         <p:choose>
            <p:when test="$test-type eq 'schematron'">
               <!-- Test for Schematron schema with XQuery language binding -->
               <p:identity message="&#10;--- Running { $test-filename } (test for Schematron) ---"/>
               <x:run-schematron-xqs>
                  <p:with-input pipe="result@test-file"/>
                  <p:with-option name="parameters" select="$parameters-augmented"/>
               </x:run-schematron-xqs>            
            </p:when>
            <p:otherwise>
               <!-- Test for XQuery -->
               <p:identity message="&#10;--- Running { $test-filename } (test for XQuery) ---"/>
               <x:run-xquery>
                  <p:with-input pipe="result@test-file"/>
                  <p:with-option name="parameters" select="$parameters-augmented"/>
               </x:run-xquery>
            </p:otherwise>
         </p:choose>

         <p:xslt name="check-html-report">
            <p:with-input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet version="3.0"
                     xmlns:xs="http://www.w3.org/2001/XMLSchema"
                     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                     xmlns:h="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">
                     <xsl:param name="test-type" as="xs:string" required="yes"/>
                     <xsl:mode on-no-match="shallow-skip"/>
                     <xsl:template match="/">
                        <!-- $failure-text should be 'failed:&#160;' followed by the number of failures -->
                        <xsl:variable name="failure-text" as="xs:string"
                           select="exactly-one(descendant::h:th[contains-token(@class, 'emphasis')])/string()"/>
                        <xsl:variable name="xspec-file" as="xs:string"
                           select="exactly-one(//h:body/h:p/text()[.='XSpec: ']/following-sibling::h:a)/string()"/>
                        <xsl:if test="replace($failure-text, '^failed:&#160;','') ne '0'">
                           <message>
                              <xsl:value-of select="concat($xspec-file, ' ', $failure-text)"/>
                           </message>
                        </xsl:if>
                        <!-- Checking header for each report is redundant. Should the next xsl:if be removed? -->
                        <xsl:if test="($test-type eq 'schematron') and
                           empty(//h:body/h:p/text()[.='Schematron: '])">
                           <message>
                              <xsl:value-of select="concat($xspec-file, ' report header does not indicate schema')"/>
                           </message>                              
                        </xsl:if>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:with-input>
            <p:with-option name="parameters" select="map{'test-type': $test-type}"/>
         </p:xslt>            
      </p:for-each>
   </p:for-each>
   <p:wrap-sequence>
      <p:with-option name="wrapper" select="QName('','messages')"/>
   </p:wrap-sequence>
   <p:if test="string-length(.) gt 0">
      <p:error code="x:TEST-EVENT-001"/>
   </p:if>
   <p:identity message="&#10;--- Testing completed with no failures! ---&#10;"/>
   <p:sink/>
</p:declare-step>
