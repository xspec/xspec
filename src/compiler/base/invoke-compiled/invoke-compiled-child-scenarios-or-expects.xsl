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
   <xsl:template name="x:invoke-compiled-child-scenarios-or-expects">
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

      <xsl:apply-templates select="$this/*[1]" mode="local:invoke-compiled-scenarios-or-expects">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      mode="local:invoke-compiled-scenarios-or-expects"
   -->
   <xsl:mode name="local:invoke-compiled-scenarios-or-expects" on-multiple-match="fail"
      on-no-match="fail" />

   <!--
      This mode ignores these elements.

      x:label elements can be ignored. They are used by x:label() (which selects either the x:label
      element or the label attribute).

      TODO: Imports are "resolved" in x:gather-descriptions(). But this is not done the usual way,
      instead it returns all x:description elements. Change this by using the usual recursive
      template resolving x:import elements in place. But for now, those elements are still here, so
      we have to ignore them...
   -->
   <xsl:template match="x:apply|x:call|x:context|x:label"
      mode="local:invoke-compiled-scenarios-or-expects">
      <!-- Nothing, but must continue the sibling-walking... -->
      <xsl:call-template name="local:continue-walking-siblings" />
   </xsl:template>

   <!--
      At x:pending elements, we switch the $pending tunnel param value for children.
   -->
   <xsl:template match="x:pending" mode="local:invoke-compiled-scenarios-or-expects">
      <xsl:apply-templates select="*[1]" mode="#current">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>

      <xsl:call-template name="local:continue-walking-siblings" />
   </xsl:template>

   <!--
      Generate an invocation of the compiled x:scenario
   -->
   <xsl:template match="x:scenario" mode="local:invoke-compiled-scenarios-or-expects">
      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template -->
      <xsl:call-template name="x:invoke-compiled-current-scenario-or-expect">
         <xsl:with-param name="with-param-uqnames"
            select="accumulator-before('stacked-variables-distinct-uqnames')" />
      </xsl:call-template>

      <xsl:call-template name="local:continue-walking-siblings" />
   </xsl:template>

   <!--
      Generate an invocation of the compiled x:expect
   -->
   <xsl:template match="x:expect" mode="local:invoke-compiled-scenarios-or-expects">
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

      <xsl:call-template name="local:continue-walking-siblings" />
   </xsl:template>

   <!--
      x:variable element generates a variable declaration.
   -->
   <xsl:template match="x:variable" mode="local:invoke-compiled-scenarios-or-expects">
      <xsl:call-template name="local:detect-reserved-variable-name" />

      <xsl:choose>
         <xsl:when test="following-sibling::x:call or following-sibling::x:context">
            <!-- This variable is declared in x:compile-scenario template -->
         </xsl:when>

         <xsl:otherwise>
            <!-- Declare now -->
            <xsl:apply-templates select="." mode="x:declare-variable" />
         </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="local:continue-walking-siblings" />
   </xsl:template>

   <!--
      Global x:variable and x:param elements are not handled like local variables and params (which
      are passed through invocations). They are declared globally.

      x:helper is global.
   -->
   <xsl:template match="x:description/x:helper
                       |x:description/x:param
                       |x:description/x:variable"
                 mode="local:invoke-compiled-scenarios-or-expects">
      <xsl:if test="self::x:variable">
        <xsl:call-template name="local:detect-reserved-variable-name"/>
      </xsl:if>

      <xsl:call-template name="local:continue-walking-siblings" />
   </xsl:template>

   <!--
      Local templates
   -->

   <!-- Apply the current mode templates to the following sibling element. -->
   <xsl:template name="local:continue-walking-siblings">
      <xsl:context-item as="element()" use="required" />

      <xsl:apply-templates select="following-sibling::*[1]" mode="#current" />
   </xsl:template>

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