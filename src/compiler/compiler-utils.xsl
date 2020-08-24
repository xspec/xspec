<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Apply the current mode templates to the following sibling element.
   -->
   <xsl:template name="x:continue-walking-siblings">
      <xsl:context-item as="element()" use="required" />

      <xsl:apply-templates select="following-sibling::*[1]" mode="#current" />
   </xsl:template>

   <xsl:function name="x:label" as="element(x:label)">
      <xsl:param name="labelled" as="element()" />

      <!-- Create an x:label element without a prefix in its name. This prefix-less name aligns with
         the other elements in the test result report XML. -->
      <xsl:element name="label" namespace="{namespace-uri($labelled)}">
         <xsl:value-of select="($labelled/x:label, $labelled/@label)[1]" />
      </xsl:element>
   </xsl:function>

   <xsl:function name="x:pending-attribute-from-pending-node" as="attribute(pending)">
      <xsl:param name="pending-node" as="node()" />

      <xsl:attribute name="pending" select="$pending-node" />
   </xsl:function>

   <!-- Removes duplicate strings from a sequence of strings. (Removes a string if it appears
     in a prior position of the sequence.)
     Unlike fn:distinct-values(), the order of the returned sequence is stable.
     Based on http://www.w3.org/TR/xpath-functions-31/#func-distinct-nodes-stable -->
   <xsl:function name="x:distinct-strings-stable" as="xs:string*">
      <xsl:param name="strings" as="xs:string*" />

      <xsl:sequence select="$strings[not(subsequence($strings, 1, position() - 1) = .)]"/>
   </xsl:function>

   <!-- Returns a text node of the function call expression. The names of the function and the
      parameter variables are URIQualifiedName. -->
   <xsl:function name="x:function-call-text" as="text()">
      <xsl:param name="call" as="element(x:call)" />

      <!-- xsl:for-each is not for iteration but for simplifying XPath -->
      <xsl:for-each select="$call">
         <xsl:variable name="function-uqname" as="xs:string">
            <xsl:choose>
               <xsl:when test="contains(@function, ':')">
                  <xsl:sequence select="x:UQName-from-EQName-ignoring-default-ns(@function, .)" />
               </xsl:when>
               <xsl:otherwise>
                  <!-- Function name without prefix is not Q{}local but fn:local -->
                  <xsl:sequence select="@function/string()" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

         <xsl:value-of>
            <xsl:text expand-text="yes">{$function-uqname}(</xsl:text>
            <xsl:for-each select="x:param">
               <xsl:sort select="xs:integer(@position)" />

               <xsl:text expand-text="yes">${x:variable-UQName(.)}</xsl:text>
               <xsl:if test="position() ne last()">
                  <xsl:text>, </xsl:text>
               </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
         </xsl:value-of>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>