<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:group-invocation"
      This mode groups the invocation instructions of compiled x:scenario into a single xsl:for-each.
   -->

   <xsl:template match="document-node()" as="element()*" mode="x:group-invocation">
      <!-- xsl:call-template elements originating from x:scenario -->
      <xsl:variable name="scenario-invokers" as="element(xsl:call-template)*"
         select="xsl:call-template[processing-instruction(origin) eq 'scenario']" />

      <!-- All the invocation instructions originating from x:scenario must be adjacent so that they
         can be grouped in a single group. This check is to make the implementation more robust or
         future-resistant as the compiler code evolves. -->
      <xsl:for-each select="
            node()
            [not(. intersect $scenario-invokers)]
            [. >> $scenario-invokers[1]]
            [$scenario-invokers[last()] >> .]">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message"
                  select="'Unexpected node between invocation instructions of compiled scenario.'" />
            </xsl:call-template>
         </xsl:message>
      </xsl:for-each>

      <!-- Group the adjacent xsl:call-template elements originating from x:scenario. The other
         nodes (actually, xsl:call-template elements (from x:expect) and xsl:variable elements (from
         x:param and x:variable)) are grouped individually. -->
      <xsl:for-each-group select="node() treat as element()*" group-adjacent="
            if (. intersect $scenario-invokers) then
               0
            else
               position()">
         <xsl:apply-templates select="." mode="#current" />
      </xsl:for-each-group>
   </xsl:template>

   <xsl:template match="xsl:call-template[processing-instruction(origin) eq 'scenario']"
      as="element()+" mode="x:group-invocation">
      <xsl:variable name="child-scenario-count" as="xs:integer" select="current-group() => count()" />

      <for-each select="1 to {$child-scenario-count}">
         <!-- TODO: multi-threading
         <xsl:if test="$user-wants-to-enable-threads">
            <xsl:attribute name="saxon:threads" namespace="{$x:saxon-namespace}"
               select="'{$' || $thread-count-variable-uqname || '}'" />
         </xsl:if>
         -->
         <choose>
            <xsl:for-each select="current-group()">
               <when test=". eq {position()}">
                  <!-- Identical copy except the 'origin' processing instruction -->
                  <xsl:copy>
                     <xsl:apply-templates select="attribute()" mode="#current" />
                     <xsl:apply-templates select="node() except processing-instruction(origin)"
                        mode="#current" />
                  </xsl:copy>
               </when>
            </xsl:for-each>
            <otherwise>
               <message terminate="yes">
                  <xsl:text>ERROR: Unhandled scenario invocation</xsl:text>
               </message>
            </otherwise>
         </choose>
      </for-each>
   </xsl:template>

</xsl:stylesheet>