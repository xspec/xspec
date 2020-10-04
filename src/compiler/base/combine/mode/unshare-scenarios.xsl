<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:combine:mode:unshare-scenarios:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:unshare-scenarios"
      This mode resolves all the <like> elements to bring in the scenarios that they specify
   -->
   <xsl:mode name="x:unshare-scenarios" on-multiple-match="fail" on-no-match="shallow-copy" />

   <!-- Leave user-content intact. This must be done in the highest priority. -->
   <xsl:template match="node()[x:is-user-content(.)]" as="node()" mode="x:unshare-scenarios"
      priority="1">
      <xsl:sequence select="." />
   </xsl:template>

   <!-- Discard @shared and shared x:scenario -->
   <xsl:template match="x:scenario/@shared | x:scenario[x:yes-no-synonym(@shared, false())]"
      as="empty-sequence()" mode="x:unshare-scenarios" />

   <!-- Replace x:like with specified scenario's child elements -->
   <xsl:template match="x:like" as="element()+" mode="x:unshare-scenarios">
      <xsl:variable name="label" as="element(x:label)" select="x:label(.)" />
      <xsl:variable name="scenario" as="element(x:scenario)*"
         select="key('local:scenarios', $label)" />
      <xsl:choose>
         <xsl:when test="empty($scenario)">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">ERROR in {name()}: Scenario not found: '{$label}'</xsl:text>
            </xsl:message>
         </xsl:when>
         <xsl:when test="$scenario[2]">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">ERROR in {name()}: {count($scenario)} scenarios found with same label: '{$label}'</xsl:text>
            </xsl:message>
         </xsl:when>
         <xsl:when test="$scenario intersect ancestor::x:scenario">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">ERROR in {name()}: Reference to ancestor scenario creates infinite loop: '{$label}'</xsl:text>
            </xsl:message>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="$scenario/element()" mode="#current" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--
      Local components
   -->

   <xsl:key name="local:scenarios" match="x:scenario" use="x:label(.)" />

</xsl:stylesheet>