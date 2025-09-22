<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
   xmlns:xt="x-urn:test:xproc:check-options" version="3.1">

   <p:documentation>
      <p>This pipeline verifies effects of options in the XProc pipelines for XSpec.</p>
      <p><b>Input ports:</b> None.</p>
      <p><b>Output ports:</b> None.</p>
   </p:documentation>

   <p:import href="check-xproc-harness-options-lib.xpl"/>

   <!-- Run test cases and collect results -->
   <p:xslt name="run-collect">
      <p:with-input port="source"><dummy/></p:with-input>
      <p:with-input port="stylesheet">
         <p:inline>
            <xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xt="x-urn:test:xproc:check-options" exclude-result-prefixes="#all">
               <xsl:template match="/">
                  <messages>
                     <!-- Each test case is an XProc step. Call each one as an XPath function.
                        https://docs.xmlcalabash.com/userguide/current/pipelineception.html -->
                     <xsl:sequence select="xt:test-html-report-theme()?result"/>
                     <xsl:sequence select="xt:test-force-focus()?result"/>
                     <xsl:sequence select="xt:test-force-focus(map{{
                              'force-focus-value': 'scenario1-scenario2',
                              'expected-pending-value': '3'}}
                              )?result"/>
                  </messages>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:with-input>
   </p:xslt>
   <p:if test="exists(/messages/*)">
      <p:error code="xt:TEST-EVENT-001" message="&#10;"/>
   </p:if>
   <p:sink message="&#10;--- Testing completed with no failures! ---&#10;"/>
</p:declare-step>
