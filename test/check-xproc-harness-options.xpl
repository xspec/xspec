<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:xt="x-urn:test:xproc:check-options"
            version="3.1">

   <p:documentation>
      <p>This pipeline verifies effects of options in the XProc pipelines for XSpec.</p>
      <p><b>Input ports:</b> None.</p>
      <p><b>Output ports:</b> None.</p>
   </p:documentation>

   <p:import href="check-xproc-harness-options-lib.xpl"/>

   <!-- Run test cases -->
   <xt:test-html-report-theme name="test-html-report-theme"/>
   <xt:test-force-focus name="test-force-focus-none"/>
   <xt:test-force-focus name="test-force-focus-scenario">
      <p:with-option name="force-focus-value" select="'scenario1-scenario2'"/>
      <p:with-option name="expected-pending-value" select="'3'"/>
   </xt:test-force-focus>

   <!-- Collect results -->
   <p:wrap-sequence name="collect-messages">
      <p:with-input>
         <p:pipe step="test-html-report-theme" port="result"/>
         <p:pipe step="test-force-focus-none" port="result"/>
         <p:pipe step="test-force-focus-scenario" port="result"/>
      </p:with-input>
      <p:with-option name="wrapper" select="QName('','messages')"/>
   </p:wrap-sequence>

   <p:if test="string-length(.) gt 0">
      <p:identity message="&#10;"/>
      <p:error code="xt:TEST-EVENT-001"/>
   </p:if>
   <p:sink message="&#10;--- Testing completed with no failures! ---&#10;"/>
</p:declare-step>
