<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:function name="x:combine" as="document-node(element(x:description))">
      <xsl:param name="specs" as="node()+" />

      <!-- Combine all the children of x:description into a single document so that the following
         transformation modes can handle them as a document. -->
      <xsl:variable name="specs-doc" as="document-node()">
         <xsl:document>
            <xsl:sequence select="$specs" />
         </xsl:document>
      </xsl:variable>

      <!-- Resolve x:like and @shared -->
      <xsl:variable name="unshared-doc" as="document-node()">
         <xsl:apply-templates select="$specs-doc" mode="x:unshare-scenarios" />
      </xsl:variable>

      <!-- Assign @id -->
      <xsl:variable name="doc-with-id" as="document-node()">
         <xsl:apply-templates select="$unshared-doc" mode="x:assign-id" />
      </xsl:variable>

      <!-- Force focus -->
      <xsl:variable name="doc-maybe-focus-enforced" as="document-node()">
         <xsl:apply-templates select="$doc-with-id" mode="x:force-focus" />
      </xsl:variable>

      <!-- Combine all the children of x:description into a single x:description -->
      <xsl:document>
         <xsl:for-each select="$initial-document/x:description">
            <!-- @name must not have a prefix. @inherit-namespaces must be no. Otherwise
               the namespaces created for /x:description will pollute its descendants derived
               from the other trees. -->
            <xsl:element name="{local-name()}" namespace="{namespace-uri()}"
               inherit-namespaces="no">
               <!-- Do not set all the attributes. Each imported x:description has its own set of
                  attributes. Set only the attributes that are truly global over all the XSpec
                  documents. -->

               <!-- Global Schematron attributes.
                  These attributes are already absolute. (resolved by
                  ../schematron/schut-to-xspec.xsl) -->
               <xsl:sequence select="@original-xspec | @schematron" />

               <!-- Global XQuery attributes.
                  @query-at is handled by compile-xquery-tests.xsl -->
               <xsl:sequence select="@query | @xquery-version" />

               <!-- Global XSLT attributes.
                  @xslt-version can be set, because it has already been propagated from each
                  imported x:description to its descendants in mode="x:gather-specs". -->
               <xsl:sequence select="@xslt-version" />
               <xsl:for-each select="@stylesheet">
                  <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
                     select="resolve-uri(., base-uri())" />
               </xsl:for-each>

               <xsl:sequence select="$doc-maybe-focus-enforced" />
            </xsl:element>
         </xsl:for-each>
      </xsl:document>
   </xsl:function>

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
   <xsl:template match="x:scenario/@shared | x:scenario[@shared eq 'yes']" as="empty-sequence()"
      mode="x:unshare-scenarios" />

   <!-- Replace x:like with specified scenario's child elements -->
   <xsl:key name="scenarios" match="x:scenario[x:is-user-content(.) => not()]" use="x:label(.)" />
   <xsl:template match="x:like" as="element()+" mode="x:unshare-scenarios">
      <xsl:variable name="label" as="element(x:label)" select="x:label(.)" />
      <xsl:variable name="scenario" as="element(x:scenario)*" select="key('scenarios', $label)" />
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
      mode="x:assign-id"
      This mode assigns ID to x:scenario and x:expect
   -->
   <xsl:mode name="x:assign-id" on-multiple-match="fail" on-no-match="shallow-copy" />

   <xsl:template match="(x:scenario | x:expect)[x:is-user-content(.) => not()]" as="element()"
      mode="x:assign-id">
      <xsl:copy>
         <xsl:attribute name="id">
            <xsl:apply-templates select="." mode="x:generate-id" />
         </xsl:attribute>
         <xsl:apply-templates select="attribute() | node()" mode="#current" />
      </xsl:copy>
   </xsl:template>

   <!--
      mode="x:force-focus"
      This mode enforces focus on specific instances of x:scenario
   -->
   <xsl:mode name="x:force-focus" on-multiple-match="fail" on-no-match="shallow-copy" />

   <!-- Leave user-content intact. This must be done in the highest priority. -->
   <xsl:template match="node()[x:is-user-content(.)]" as="node()" mode="x:force-focus"
      priority="1">
      <xsl:sequence select="." />
   </xsl:template>

   <!-- Force or remove focus -->
   <xsl:template match="x:scenario[exists($force-focus-ids)]" as="element(x:scenario)"
      mode="x:force-focus">
      <xsl:copy>
         <xsl:if test="@id = $force-focus-ids">
            <xsl:attribute name="focus" select="'force focus'" />
         </xsl:if>
         <xsl:apply-templates select="attribute() except @focus" mode="#current" />

         <xsl:apply-templates select="node()" mode="#current" />
      </xsl:copy>
   </xsl:template>

   <!--
      mode="x:generate-id"
      Generates the ID of current x:scenario or x:expect.
      These default templates assume that all the scenarios have already been gathered and unshared.
      So the default ID may not always be usable for backtracking. For such backtracking purposes,
      override these default templates and implement your own ID generation. The generated ID must
      be castable as xs:NCName, because ID is used as a part of local name.
      Note that when this mode is applied, all the scenarios have been gathered and unshared in a
      single document, but the document still does not have /x:description.
   -->
   <xsl:mode name="x:generate-id" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="x:scenario" as="xs:string" mode="x:generate-id">
      <!-- Some ID generators may depend on @xspec, although this default generator doesn't. -->
      <xsl:if test="empty(@xspec)">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">@xspec not exist when generating ID for {name()}.</xsl:text>
         </xsl:message>
      </xsl:if>

      <xsl:variable name="ancestor-or-self-tokens" as="xs:string+">
         <xsl:for-each select="ancestor-or-self::x:scenario">
            <!-- Find preceding sibling x:scenario, taking x:pending into account -->

            <!-- Parent document node or x:scenario.
               Note:
               - x:pending may exist in between.
               - In the current mode, the document still does not have /x:description. -->
            <xsl:variable name="parent-document-node-or-scenario" as="node()"
               select="ancestor::node()[self::document-node() or self::x:scenario][1]" />

            <xsl:variable name="preceding-sibling-scenarios" as="element(x:scenario)*"
               select="$parent-document-node-or-scenario/descendant::x:scenario
                  [ancestor::node()[self::document-node() or self::x:scenario][1] is $parent-document-node-or-scenario]
                  [current() >> .]
                  [x:is-user-content(.) => not()]" />

            <xsl:sequence select="local-name() || (count($preceding-sibling-scenarios) + 1)" />
         </xsl:for-each>
      </xsl:variable>

      <xsl:sequence select="string-join($ancestor-or-self-tokens, '-')" />
   </xsl:template>

   <xsl:template match="x:expect" as="xs:string" mode="x:generate-id">
      <!-- Find preceding sibling x:expect, taking x:pending into account -->
      <xsl:variable name="scenario" as="element(x:scenario)" select="ancestor::x:scenario[1]" />
      <xsl:variable name="preceding-sibling-expects" as="element(x:expect)*"
         select="$scenario/descendant::x:expect
            [ancestor::x:scenario[1] is $scenario]
            [current() >> .]
            [x:is-user-content(.) => not()]" />

      <xsl:variable name="scenario-id" as="xs:string">
         <xsl:apply-templates select="$scenario" mode="#current" />
      </xsl:variable>

      <xsl:sequence select="$scenario-id || '-' || local-name() || (count($preceding-sibling-expects) + 1)" />
   </xsl:template>

</xsl:stylesheet>