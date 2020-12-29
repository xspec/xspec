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
      <xsl:call-template name="local:detect-reserved-vardecl-name" />

      <!-- Reject static x:param if not @run-as=external.
         mode="x:declare-variable" is not aware of $is-external. That's why @static is checked here. -->
      <xsl:if test="x:yes-no-synonym(@static, false()) and not($is-external)">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">ERROR: Enabling @static in {name()} (named {@name}) is supported only when /{$initial-document/x:description => name()} has @run-as='external'.</xsl:text>
         </xsl:message>
      </xsl:if>
   </xsl:template>

   <xsl:template match="x:variable" as="empty-sequence()" mode="x:check-combined-doc">
      <xsl:call-template name="local:detect-reserved-vardecl-name" />
   </xsl:template>

   <!--
      Local templates
   -->

   <!-- Detect and generate error for user-defined variable declaration with names in XSpec
      namespace. -->
   <xsl:template name="local:detect-reserved-vardecl-name" as="empty-sequence()">
      <!-- Context item is x:param or x:variable -->
      <xsl:context-item as="element()" use="required" />

      <xsl:if test="@name">
         <xsl:variable name="qname" as="xs:QName"
            select="x:resolve-EQName-ignoring-default-ns(@name, .)" />

         <xsl:if test="namespace-uri-from-QName($qname) eq $x:xspec-namespace">
            <xsl:choose>
               <xsl:when test="
                     self::x:param
                     [parent::x:description]
                     [local-name-from-QName($qname) eq 'enable-schematron-text-location']">
                  <!-- Allow it -->
                  <!-- This global x:param is a private parameter to enable text node @location -->
               </xsl:when>

               <xsl:when test="
                     self::x:variable
                     [$is-external]
                     [local-name-from-QName($qname) eq 'saxon-config']">
                  <!-- Allow it -->
                  <!--
                     TODO: Consider replacing this abusive <xsl:variable> with a dedicated element
                     defined in the XSpec schema, like <x:config type="saxon" href="..." />. A
                     vendor-independent element name would be better than a vendor-specific element
                     name like <x:saxon-config>; a vendor-specific attribute value seems more
                     appropriate.
                  -->
               </xsl:when>

               <xsl:otherwise>
                  <!-- Reject it -->
                  <xsl:message terminate="yes">
                     <xsl:text expand-text="yes">ERROR: {name()} (named {@name}) must not use the XSpec namespace.</xsl:text>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:if>
   </xsl:template>

</xsl:stylesheet>
