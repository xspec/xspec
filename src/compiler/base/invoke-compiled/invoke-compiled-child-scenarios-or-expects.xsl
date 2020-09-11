<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:invoke-compiled:invoke-compiled-child-scenarios-or-expects:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Generate invocation instructions of the compiled (child::x:scenario | child::x:expect), taking
      x:pending into account. Recall that x:scenario and x:expect are compiled to an XSLT named
      template or an XQuery function which must have the corresponding invocation instruction at
      some point.
   -->
   <xsl:template name="x:invoke-compiled-child-scenarios-or-expects" as="node()*">
      <!-- Context item is x:description or x:scenario -->
      <xsl:context-item as="element()" use="required" />

      <!-- Default value of $pending does not affect compiler output but is here if needed in the
         future -->
      <xsl:param name="pending" select="(.//@focus)[1]" tunnel="yes" as="node()?"/>

      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:message terminate="yes"
            select="'$this must be a description or a scenario, but is: ' || name()" />
      </xsl:if>

      <xsl:apply-templates select="$this/element()"
         mode="local:invoke-compiled-scenarios-or-expects">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      mode="local:invoke-compiled-scenarios-or-expects"
   -->
   <xsl:mode name="local:invoke-compiled-scenarios-or-expects" on-multiple-match="fail"
      on-no-match="deep-skip" />

   <!--
      At x:pending elements, we switch the $pending tunnel param value for children.
   -->
   <xsl:template match="x:pending" as="node()+" mode="local:invoke-compiled-scenarios-or-expects">
      <xsl:apply-templates select="element()" mode="#current">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      Generate an invocation of the compiled x:scenario
   -->
   <xsl:template match="x:scenario" as="node()+" mode="local:invoke-compiled-scenarios-or-expects">
      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template -->
      <xsl:call-template name="x:invoke-compiled-current-scenario-or-expect">
         <xsl:with-param name="with-param-uqnames"
            select="accumulator-before('stacked-variables-distinct-uqnames')" />
      </xsl:call-template>
   </xsl:template>

   <!--
      Generate an invocation of the compiled x:expect
   -->
   <xsl:template match="x:expect" as="node()+" mode="local:invoke-compiled-scenarios-or-expects">
      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" tunnel="yes" />

      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template -->
      <xsl:call-template name="x:invoke-compiled-current-scenario-or-expect">
         <xsl:with-param name="with-param-uqnames" as="xs:string*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <xsl:sequence select="$context ! x:known-UQName('x:context')" />
               <xsl:sequence select="x:known-UQName('x:result')" />
            </xsl:if>
            <xsl:sequence select="accumulator-before('stacked-variables-distinct-uqnames')" />
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
      - Reject reserved variable names, whether they're global or not.
      - Declare non-global variables if they are not preceding-siblings of x:call or x:context.
   -->
   <xsl:template match="x:variable" as="node()*" mode="local:invoke-compiled-scenarios-or-expects">
      <xsl:call-template name="local:detect-reserved-variable-name" />

      <xsl:choose>
         <xsl:when test="parent::x:description">
            <!-- This global variable is declared in x:compile-global-params-and-variables template -->
         </xsl:when>

         <xsl:when test="following-sibling::x:call or following-sibling::x:context">
            <!-- This variable is declared in x:compile-scenario template -->
         </xsl:when>

         <xsl:otherwise>
            <!-- Declare now -->
            <xsl:apply-templates select="." mode="x:declare-variable" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--
      Local templates
   -->

   <!-- Generate error message for user-defined usage of names in XSpec namespace. -->
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
               element name would be better than a vendor-specific element name like <x:saxon-config>;
               a vendor-specific attribute value seems more appropriate.
            -->
         </xsl:when>
         <xsl:when test="namespace-uri-from-QName($qname) eq $x:xspec-namespace">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">ERROR: User-defined XSpec variable, {@name}, must not use the XSpec namespace.</xsl:text>
            </xsl:message>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>