<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:combine:mode:check-combined-doc:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:check-combined-doc"
      This mode checks a combined XSpec document.
   -->
   <xsl:mode name="x:check-combined-doc" on-multiple-match="fail" on-no-match="shallow-skip" />

   <xsl:template match="x:param" as="empty-sequence()" mode="x:check-combined-doc">

      <!-- Reject static x:param if not @run-as=external.
         mode="x:declare-variable" is not aware of $is-external. That's why @static is checked here. -->
      <xsl:if test="x:yes-no-synonym(@static, false()) and not($is-external)">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">Enabling @static in {name()} is supported only when /{$initial-document/x:description => name()} has @run-as='external'.</xsl:text>
         </xsl:message>
      </xsl:if>
   </xsl:template>

   <xsl:template match="x:variable" as="empty-sequence()" mode="x:check-combined-doc">
      <xsl:call-template name="local:detect-reserved-variable-name" />
   </xsl:template>

   <!--
      Local templates
   -->

   <!-- Detect and generate error for user-defined variable declaration with names in XSpec
      namespace. -->
   <xsl:template name="local:detect-reserved-variable-name" as="empty-sequence()">
      <xsl:context-item as="element(x:variable)" use="required" />

      <xsl:variable name="qname" as="xs:QName"
         select="x:resolve-EQName-ignoring-default-ns(@name, .)" />

      <xsl:choose>
         <xsl:when test="$is-external and ($qname eq xs:QName('x:saxon-config'))">
            <!-- Allow it -->
            <!--
               TODO: Consider replacing this abusive <xsl:variable> with a dedicated element defined
               in the XSpec schema, like <x:config type="saxon" href="..." />. A vendor-independent
               element name would be better than a vendor-specific element name like
               <x:saxon-config>; a vendor-specific attribute value seems more appropriate.
            -->
         </xsl:when>

         <xsl:when test="namespace-uri-from-QName($qname) eq $x:xspec-namespace">
            <!-- Reject it -->
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">ERROR: User-defined XSpec variable, {@name}, must not use the XSpec namespace.</xsl:text>
            </xsl:message>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
