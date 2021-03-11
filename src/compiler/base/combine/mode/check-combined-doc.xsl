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

      <!-- mode="x:declare-variable" is not aware of $is-external. That's why checking x:param
         against $is-external is performed here rather than in mode="x:declare-variable". -->
      <xsl:choose>
         <xsl:when test="parent::x:description">
            <xsl:call-template name="local:detect-static-description-param-run-as-import" />
         </xsl:when>
         <xsl:when test="parent::x:scenario">
            <xsl:call-template name="local:detect-scenario-param-run-as-import" />
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="x:variable" as="empty-sequence()" mode="x:check-combined-doc">
      <xsl:call-template name="local:detect-reserved-vardecl-name" />
      <xsl:call-template name="local:detect-variable-overriding-param" />
   </xsl:template>

   <!--
      Local templates
   -->

   <!-- Reject user-defined variable declaration with names in XSpec namespace. -->
   <xsl:template name="local:detect-reserved-vardecl-name" as="empty-sequence()">
      <!-- Context item must be x:param or x:variable -->
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
                     <xsl:call-template name="x:prefix-diag-message">
                        <xsl:with-param name="message">
                           <xsl:text expand-text="yes">Name {@name} must not use the XSpec namespace.</xsl:text>
                        </xsl:with-param>
                     </xsl:call-template>
                  </xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:if>
   </xsl:template>

   <!-- Reject static /x:description/x:param if not @run-as=external. -->
   <xsl:template name="local:detect-static-description-param-run-as-import" as="empty-sequence()">
      <!-- Context item must be x:param[parent::x:description] -->
      <xsl:context-item as="element(x:param)" use="required" />

      <xsl:if test="not($is-external) and x:yes-no-synonym(@static, false())">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message">
                  <xsl:text expand-text="yes">Enabling @static is supported only when /{$initial-document/x:description => name()} has @run-as='external'.</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
   </xsl:template>

   <!-- Reject //x:scenario/x:param if not @run-as=external. -->
   <xsl:template name="local:detect-scenario-param-run-as-import" as="empty-sequence()">
      <!-- Context item must be x:param[parent::x:scenario] -->
      <xsl:context-item as="element(x:param)" use="required" />

      <xsl:if test="not($is-external)">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message">
                  <!-- /src/schematron/schut-to-xspec.xsl removes the name prefix from x:description.
                     That's why URIQualifiedName is used. -->
                  <xsl:text expand-text="yes">{name(parent::x:scenario)} has {name()}, which is supported only when /{/x:description => x:node-UQName()} has @run-as='external'.</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
   </xsl:template>

   <!-- Reject x:variable if it overrides any (x:description|x:scenario)/x:param. -->
   <xsl:template name="local:detect-variable-overriding-param" as="empty-sequence()">
      <xsl:context-item as="element(x:variable)" use="required" />

      <!-- URIQualifiedName of the current x:variable -->
      <xsl:variable name="uqname" as="xs:string" select="x:variable-UQName(.)" />

      <!-- Cumulative x:param -->
      <xsl:variable name="cumulative-params" as="element(x:param)*" select="
            (: Global x:param :)
            /x:description/x:param
            
            (: Scenario-level x:param stacked outside the current x:scenario :)
            | accumulator-before('stacked-vardecls')/self::x:param
            
            (: Local x:param preceding this x:variable :)
            | preceding-sibling::x:param" />

      <!-- One of the x:param elements that are overridden by this x:variable -->
      <xsl:variable name="overridden-param" as="element(x:param)?"
         select="$cumulative-params[x:variable-UQName(.) eq $uqname][1]" />

      <!-- Terminate if any -->
      <xsl:if test="$overridden-param">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message">
                  <xsl:text expand-text="yes">Must not override {name($overridden-param)} (named {$overridden-param/@name})</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
   </xsl:template>

</xsl:stylesheet>
