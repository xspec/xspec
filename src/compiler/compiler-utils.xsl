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

   <!--
      Returns true or false based on "yes" or "no",
      accepting ("true" or "false") and ("1" or "0") as synonyms.
   -->
   <xsl:function as="xs:boolean" name="x:yes-no-synonym">
      <xsl:param as="xs:string" name="input" />

      <xsl:choose>
         <xsl:when test="$input = ('yes', 'true', '1')">
            <xsl:sequence select="true()" />
         </xsl:when>
         <xsl:when test="$input = ('no', 'false', '0')">
            <xsl:sequence select="false()" />
         </xsl:when>
      </xsl:choose>
   </xsl:function>

   <!--
      x:yes-no-synonym#1 plus default value in case of empty sequence
   -->
   <xsl:function as="xs:boolean" name="x:yes-no-synonym">
      <xsl:param as="xs:string?" name="input" />
      <xsl:param as="xs:boolean" name="default" />

      <xsl:sequence
         select="
            if (exists($input)) then
               x:yes-no-synonym($input)
            else
               $default"
       />
   </xsl:function>

   <!--
      Returns the effective value of @xslt-version of the context element.

      $context is usually x:description or x:expect.
   -->
   <xsl:function as="xs:decimal" name="x:xslt-version">
      <xsl:param as="element()" name="context" />

      <xsl:sequence
         select="
            (
               $context/ancestor-or-self::*[@xslt-version][1]/@xslt-version,
               3.0
            )[1]"
       />
   </xsl:function>

   <!--
      Returns namespace nodes in the element excluding the same prefix as the element name.
      'xml' is excluded in the first place.

         Example:
            in:  <prefix1:e xmlns="default-ns" xmlns:prefix1="ns1" xmlns:prefix2="ns2" />
            out: xmlns="default-ns" and xmlns:prefix2="ns2"
   -->
   <xsl:function as="namespace-node()*" name="x:element-additional-namespace-nodes">
      <xsl:param as="element()" name="element" />

      <xsl:variable as="xs:string" name="element-name-prefix"
         select="
            $element
            => node-name()
            => prefix-from-QName()
            => string()" />

      <!-- Sort for better serialization (hopefully) -->
      <xsl:perform-sort select="x:copy-of-namespaces($element)[name() ne $element-name-prefix]">
         <xsl:sort select="name()" />
      </xsl:perform-sort>
   </xsl:function>

   <!--
      Returns a lexical QName in the XSpec namespace. Usually 'x:local-name'.
      The prefix is taken from the context element's namespaces.
      If multiple namespace prefixes have the XSpec namespace URI,
         - The context element name's prefix is preferred.
         - If the context element's name is not in the XSpec namespace, the first prefix is used
           after sorting them in a way that the default namespace is preferred.
   -->
   <xsl:function as="xs:string" name="x:xspec-name">
      <xsl:param as="xs:string" name="local-name" />
      <xsl:param as="element()" name="context-element" />

      <xsl:variable as="xs:QName" name="context-node-name" select="node-name($context-element)" />

      <xsl:variable as="xs:string?" name="prefix">
         <xsl:choose>
            <xsl:when test="namespace-uri-from-QName($context-node-name) eq $x:xspec-namespace">
               <xsl:sequence select="prefix-from-QName($context-node-name)" />
            </xsl:when>

            <xsl:otherwise>
               <xsl:variable as="xs:string+" name="xspec-prefixes"
                  select="
                     in-scope-prefixes($context-element)
                     [namespace-uri-for-prefix(., $context-element) eq $x:xspec-namespace]" />
               <xsl:sequence select="sort($xspec-prefixes)[1]" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:sequence select="($prefix[.], $local-name) => string-join(':')" />
   </xsl:function>

</xsl:stylesheet>