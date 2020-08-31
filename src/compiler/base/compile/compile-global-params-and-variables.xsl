<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
       Drive the compilation of global params and variables.
   -->
   <xsl:template name="x:compile-global-params-and-variables">
      <xsl:context-item as="element(x:description)" use="required" />

      <xsl:variable name="this" select="." as="element(x:description)"/>

      <!-- mode="x:declare-variable" is not aware of $is-external. That's why @static is checked
         here. -->
      <xsl:if test="not($is-external)">
         <xsl:for-each select="$this/x:param[x:yes-no-synonym(@static, false())]">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">Enabling @static in {name()} is supported only when /{$initial-document/x:description => name()} has @run-as='external'.</xsl:text>
            </xsl:message>
         </xsl:for-each>
      </xsl:if>

      <xsl:apply-templates select="$this/(x:param|x:variable)" mode="x:declare-variable" />
   </xsl:template>

</xsl:stylesheet>