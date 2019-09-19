<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-common-tests.xsl                                -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="2.0"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-common-tests.xsl</pkg:import-uri>

   <xsl:include href="../common/xspec-utils.xsl"/>

   <xsl:variable name="actual-document-uri" as="xs:anyURI"
      select="x:resolve-xml-uri-with-catalog(document-uri(/))"/>

   <!-- XSpec namespace URI -->
   <xsl:variable name="xspec-namespace" as="xs:anyURI"
      select="xs:anyURI('http://www.jenitennison.com/xslt/xspec')" />

   <!-- XSpec namespace prefix -->
   <xsl:variable name="xspec-prefix" as="xs:string">
      <xsl:variable name="e" select="/element()" as="element(x:description)" />
      <xsl:sequence select="
         (
            in-scope-prefixes($e)
               [namespace-uri-for-prefix(., $e) eq $xspec-namespace]
               [. (: Do not allow zero-length string :)],
            
            (: Fallback. Intentionally made weird in order to avoid collision. :)
            'XsPeC'
         )[1]"/>
   </xsl:variable>

   <xsl:variable name="html-reporter-pi" as="processing-instruction(xml-stylesheet)">
      <xsl:processing-instruction name="xml-stylesheet">
         <xsl:text>type="text/xsl" href="</xsl:text>
         <xsl:value-of select="resolve-uri('../reporter/format-xspec-report.xsl')" />
         <xsl:text>"</xsl:text>
      </xsl:processing-instruction>
   </xsl:variable>

   <xsl:variable name="default-xslt-version" as="xs:decimal" select="2.0" />

   <!--
       Drive the overall compilation of a suite.  Apply template on
       the x:description element, in the mode
   -->
   <xsl:template name="x:generate-tests">
      <xsl:variable name="deprecation-warning" as="xs:string?" select="
         if (x:saxon-version() lt x:pack-version(9,8,0,0))
         then 'Saxon version 9.7 or less is deprecated. XSpec will stop supporting it in the near future.'
         else ()" />
      <xsl:message select="
         if ($deprecation-warning)
         then ('WARNING:', $deprecation-warning)
         else ' ' (: Always write a single non-empty line to help Bats tests to predict line numbers. :)" />

      <xsl:variable name="description-name" as="xs:QName" select="xs:QName('x:description')" />
      <xsl:if test="not(node-name(element()) eq $description-name)">
         <xsl:message terminate="yes">
            <xsl:text>Source document is not XSpec. /</xsl:text>
            <xsl:value-of select="$description-name" />
            <xsl:text> is missing. Supplied source has /</xsl:text>
            <xsl:value-of select="name(element())"/>
            <xsl:text> instead.</xsl:text>
         </xsl:message>
      </xsl:if>

      <xsl:variable name="this" select="." as="document-node(element(x:description))"/>
      <xsl:variable name="all-specs" as="document-node(element(x:description))">
         <xsl:document>
            <xsl:element name="{x:xspec-name('description')}" namespace="{$xspec-namespace}">
               <xsl:apply-templates select="$this/x:description" mode="x:copy-namespaces"/>
               <xsl:copy-of select="$this/x:description/@*"/>
               <xsl:apply-templates select="x:gather-specs($this/x:description)"
                                    mode="x:gather-specs"/>
            </xsl:element>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="unshared-scenarios" as="document-node()">
         <xsl:document>
            <xsl:apply-templates select="$all-specs/*" mode="x:unshare-scenarios"/>
         </xsl:document>
      </xsl:variable>
      <xsl:apply-templates select="$unshared-scenarios/*" mode="x:generate-tests"/>
   </xsl:template>

   <xsl:template match="x:description" as="node()*" mode="x:copy-namespaces">
      <xsl:sequence select="x:copy-namespaces(.)" />
   </xsl:template>

   <xsl:function name="x:gather-specs" as="element(x:description)+">
      <xsl:param name="visit" as="element(x:description)+"/>

      <!-- "$visit/x:import" without sorting -->
      <xsl:variable name="imports" as="element(x:import)*">
        <xsl:for-each select="$visit">
          <xsl:sequence select="x:import" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="imports" as="element(x:import)*"
        select="x:distinct-nodes-stable($imports)" />

      <!-- "document($imports/@href)" without sorting -->
      <xsl:variable name="docs" as="document-node(element(x:description))*">
        <xsl:for-each select="$imports">
          <xsl:sequence select="document(@href)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="docs" as="document-node(element(x:description))*"
        select="x:distinct-nodes-stable($docs)" />

      <!-- "$docs/x:description" without sorting -->
      <xsl:variable name="imported" as="element(x:description)*">
        <xsl:for-each select="$docs">
          <xsl:sequence select="x:description" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="imported" as="element(x:description)*"
        select="x:distinct-nodes-stable($imported)" />

      <!-- "$imported except $visit" without sorting -->
      <xsl:variable name="imported-except-visit" as="element(x:description)*"
                    select="$imported[empty($visit intersect .)]"/>

      <xsl:choose>
         <xsl:when test="empty($imported-except-visit)">
            <xsl:sequence select="$visit"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="x:gather-specs(($visit, $imported-except-visit))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:template match="x:description" mode="x:gather-specs">
      <xsl:apply-templates mode="#current">
         <xsl:with-param name="xslt-version"   tunnel="yes" select="
             ( @xslt-version, $default-xslt-version )[1]"/>
         <xsl:with-param name="preserve-space" tunnel="yes" select="
             for $qname in tokenize(@preserve-space, '\s+') return
               resolve-QName($qname, .)"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="x:scenario" as="element(x:scenario)" mode="x:gather-specs">
      <xsl:param name="xslt-version" as="xs:decimal" tunnel="yes" required="yes"/>

      <xsl:element name="{x:xspec-name('scenario')}" namespace="{$xspec-namespace}">
         <xsl:attribute name="xslt-version" select="$xslt-version" />
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="x:*/@href" as="attribute(href)" mode="x:gather-specs">
      <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
         select="resolve-uri(., x:base-uri(.))" />
   </xsl:template>

   <xsl:template match="text()[not(normalize-space())]" as="node()?" mode="x:gather-specs">
      <xsl:param name="preserve-space" as="xs:QName*" tunnel="yes" select="()"/>

      <xsl:choose>
         <xsl:when test="parent::x:text">
            <!-- Preserve -->
            <xsl:sequence select="." />
         </xsl:when>

         <xsl:when test="
            (ancestor::*[@xml:space][1]/@xml:space = 'preserve')
            or (node-name(parent::*) = $preserve-space)">
            <!-- Preserve and wrap in <x:text> -->
            <xsl:element name="{x:xspec-name('text')}" namespace="{$xspec-namespace}">
               <xsl:sequence select="." />
            </xsl:element>
         </xsl:when>

         <xsl:otherwise>
            <!-- Discard -->
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="node()|@*" as="node()" mode="x:gather-specs">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" mode="#current" />
      </xsl:copy>
   </xsl:template>

   <!--
       Drive the compilation of scenarios to generate call
       instructions (the scenarios are compiled to an XSLT named
       template or an XQuery function, which must have the
       corresponding call instruction at some point).
   -->
   <xsl:template name="x:call-scenarios">
      <!-- Default value of $pending does not affect compiler output but is here if needed in the future -->
      <xsl:param name="pending" select="(.//@focus)[1]" tunnel="yes" as="node()?"/>
      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:sequence select="
             error(
                 xs:QName('x:XSPEC006'),
                 concat('$this must be a description or a scenario, but is: ', name(.))
               )"/>
      </xsl:if>
      <xsl:apply-templates select="$this/*[1]" mode="x:generate-calls">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template name="x:continue-call-scenarios">
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       Those elements are ignored in this mode.
       
       x:label elements can be ignored, they are used by x:label()
       (which selects either the x:label element or the label
       attribute).
       
       TODO: Imports are "resolved" in x:gather-specs().  But this is
       not done the usual way, instead it returns all x:description
       elements.  Change this by using the usual recursive template
       resolving x:import elements in place.  Bur for now, those
       elements are still here, so we have to ignore them...
   -->
   <xsl:template match="x:apply|x:call|x:context|x:import|x:label" mode="x:generate-calls">
      <!-- Nothing, but must continue the sibling-walking... -->
      <xsl:call-template name="x:continue-call-scenarios"/>
   </xsl:template>

   <!--
       Default rule for that mode generates an error.
   -->
   <xsl:template match="@*|node()" mode="x:generate-calls">
      <xsl:sequence select="
          error(
              xs:QName('x:XSPEC001'),
              concat('Unhandled node in x:generate-calls mode: ', name(.))
            )"/>
   </xsl:template>

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:generate-calls">
      <xsl:apply-templates select="*[1]" mode="x:generate-calls">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
      <!-- Continue walking the siblings. -->
      <xsl:call-template name="x:continue-call-scenarios"/>
   </xsl:template>

   <!--
       A scenario is called by the name { generate-id() }.
       
       Call "x:output-call", which must on turn call "x:continue-call-scenarios".
   -->
   <xsl:template match="x:scenario" mode="x:generate-calls">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(var)*"/>
      <xsl:call-template name="x:output-call">
         <xsl:with-param name="local-name" select="generate-id()"/>
         <xsl:with-param name="last" select="empty(following-sibling::x:scenario)"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <param name="{ . }" select="${ . }"/>
            </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       An expectation is called by the name { generate-id() }.
       
       Call "x:output-call", which must on turn call "x:continue-call-scenarios".
   -->
   <xsl:template match="x:expect" mode="x:generate-calls">
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:param name="vars"    select="()" tunnel="yes" as="element(var)*"/>
      <xsl:call-template name="x:output-call">
         <xsl:with-param name="local-name" select="generate-id()"/>
         <xsl:with-param name="last" select="empty(following-sibling::x:expect)"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <param name="{x:xspec-name('result')}" select="${x:xspec-name('result')}" />
            </xsl:if>
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <param name="{ . }" select="${ . }"/>
            </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       x:variable element generates a variable declaration and adds a
       variable on the stack (the tunnel param $vars).
   -->
   <xsl:template match="x:variable" mode="x:generate-calls">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(var)*"/>
      <xsl:call-template name="x:detect-reserved-variable-name"/>
      <!-- The variable declaration. -->
      <xsl:if test="empty(following-sibling::x:call) and empty(following-sibling::x:context)">
         <xsl:apply-templates select="." mode="test:generate-variable-declarations">
            <xsl:with-param name="var"  select="@name"/>
            <xsl:with-param name="type" select="'variable'"/>
         </xsl:apply-templates>
      </xsl:if>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current">
         <xsl:with-param name="vars" tunnel="yes" as="element(var)+">
            <xsl:sequence select="$vars"/>
            <var name="{ @name }">
               <xsl:if test="not(contains(@name,'Q{')) and contains(@name,':')">
                  <xsl:attribute name="namespace-uri" select="namespace-uri-from-QName(resolve-QName(@name,.))"/>
               </xsl:if>
            </var>
         </xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       Global x:variable and x:param elements are not handled like
       local variables and params (which are passed through calls).
       They are declared globally.
   -->
   <xsl:template match="x:description/x:param|x:description/x:variable" mode="x:generate-calls">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(var)*"/>
      <xsl:if test="self::x:variable">
        <xsl:call-template name="x:detect-reserved-variable-name"/>
      </xsl:if>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       Drive the compilation of test suite params (aka global params
       and variables).
   -->
   <xsl:template name="x:compile-params">
      <xsl:variable name="this" select="." as="element(x:description)"/>
      <xsl:apply-templates select="$this/(x:param|x:variable)" mode="x:generate-declarations"/>
   </xsl:template>

   <!--
       Mode: compile.
       
       Must be "fired" by the named template "x:compile-scenarios".
       It is a "sibling walking" mode: x:compile-scenarios applies the
       template in this mode on the first child, then each template
       rule must apply the template in this same mode on the next
       sibling.  The reason for this navigation style is to easily
       represent variable scopes.
   -->

   <!--
       Drive the compilation of scenarios to either XSLT named
       templates or XQuery functions.
   -->
   <xsl:template name="x:compile-scenarios">
      <xsl:param name="pending" as="node()?" select="(.//@focus)[1]" tunnel="yes"/>
      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:sequence select="
             error(
                 xs:QName('x:XSPEC007'),
                 concat('$this must be a description or a scenario, but is: ', name(.))
               )"/>
      </xsl:if>
      <xsl:apply-templates select="$this/*[1]" mode="x:compile">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:compile">
      <xsl:apply-templates select="*[1]" mode="x:compile">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       Compile a scenario.
   -->
   <xsl:template match="x:scenario" mode="x:compile">
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:param name="apply"   select="()" tunnel="yes" as="element(x:apply)?"/>
      <xsl:param name="call"    select="()" tunnel="yes" as="element(x:call)?"/>
      <xsl:param name="context" select="()" tunnel="yes" as="element(x:context)?"/>
      <xsl:param name="vars"    select="()" tunnel="yes" as="element(var)*"/>
      <!-- The new $pending. -->
      <xsl:variable name="new-pending" as="node()?" select="
          if ( @focus ) then
            ()
          else if ( @pending ) then
            @pending
          else
            $pending"/>
      <!-- The new apply. -->
      <xsl:variable name="new-apply" as="element(x:apply)?">
         <xsl:choose>
            <xsl:when test="x:apply">
               <xsl:variable name="local-params" as="element(x:param)*" select="x:apply/x:param"/>
               <xsl:element name="{x:xspec-name('apply')}" namespace="{$xspec-namespace}">
                  <xsl:sequence select="$apply/@*"/>
                  <xsl:sequence select="x:apply/@*"/>
                  <xsl:sequence select="
                      $apply/x:param[not(@name = $local-params/@name)],
                      $local-params"/>
                  <!-- TODO: Test that "x:apply/(node() except x:param)" is empty. -->
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$apply"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!-- The new context. -->
      <xsl:variable name="new-context" as="element(x:context)?">
         <xsl:choose>
            <xsl:when test="x:context">
               <xsl:variable name="local-params" as="element(x:param)*" select="x:context/x:param"/>
               <xsl:element name="{x:xspec-name('context')}" namespace="{$xspec-namespace}">
                  <xsl:sequence select="$context/@*"/>
                  <xsl:sequence select="x:context/@*"/>
                  <xsl:sequence select="
                      $context/x:param[not(@name = $local-params/@name)],
                      $local-params"/>
                  <xsl:sequence select="
                      if ( x:context/(node() except x:param) ) then
                        x:context/(node() except x:param)
                      else
                        $context/(node() except x:param)"/>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$context"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!-- The new call. -->
      <xsl:variable name="new-call" as="element(x:call)?">
         <xsl:choose>
            <xsl:when test="x:call">
               <xsl:variable name="local-params" as="element(x:param)*" select="x:call/x:param"/>
               <xsl:element name="{x:xspec-name('call')}" namespace="{$xspec-namespace}">
                  <xsl:sequence select="$call/@*"/>
                  <xsl:sequence select="x:call/@*"/>
                  <xsl:sequence select="
                      $call/x:param[not(@name = $local-params/@name)],
                      $local-params"/>
                  <!-- TODO: Test that "x:call/(node() except x:param)" is empty. -->
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$call"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!-- Call the serializing template (for XSLT or XQuery). -->
      <xsl:call-template name="x:output-scenario">
         <xsl:with-param name="pending"   select="$new-pending" tunnel="yes"/>
         <xsl:with-param name="apply"     select="$new-apply"   tunnel="yes"/>
         <xsl:with-param name="call"      select="$new-call"    tunnel="yes"/>
         <xsl:with-param name="context"   select="$new-context" tunnel="yes"/>
         <!-- the variable declarations preceding the x:call or x:context (if any). -->
         <xsl:with-param name="variables" select="x:call/preceding-sibling::x:variable | x:context/preceding-sibling::x:variable"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <param name="{ . }" required="yes"/>
            </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       Compile an expectation.
   -->
   <xsl:template match="x:expect" mode="x:compile">
      <xsl:param name="pending" select="()"    tunnel="yes" as="node()?"/>
      <xsl:param name="context" required="yes" tunnel="yes" as="element(x:context)?"/>
      <xsl:param name="call"    required="yes" tunnel="yes" as="element(x:call)?"/>
      <xsl:param name="vars"    select="()"    tunnel="yes" as="element(var)*"/>
      <!-- Call the serializing template (for XSLT or XQuery). -->
      <xsl:call-template name="x:output-expect">
         <xsl:with-param name="pending" tunnel="yes" select="
             ( $pending, ancestor::x:scenario/@pending )[1]"/>
         <xsl:with-param name="context" tunnel="yes" select="$context"/>
         <xsl:with-param name="call"    tunnel="yes" select="$call"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <param name="{x:xspec-name('result')}" required="yes" />
            </xsl:if>
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <param name="{ . }" required="yes"/>
            </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       x:param elements generate actual call param's variable.
   -->
   <xsl:template match="x:param" mode="x:compile">
      <xsl:apply-templates select="." mode="test:generate-variable-declarations">
         <xsl:with-param name="var"  select="( @name, generate-id() )[1]"/>
         <xsl:with-param name="type" select="'variable'"/>
      </xsl:apply-templates>
      <!-- Continue walking the siblings (only other x:param elements, within this
           x:call or x:context). -->
      <xsl:apply-templates select="following-sibling::*[self::x:param][1]" mode="#current"/>
   </xsl:template>

   <!--
       x:variable element adds a variable on the stack (the tunnel
       param $vars).
   -->
   <xsl:template match="x:variable" mode="x:compile">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(var)*"/>
      <!-- Continue walking the siblings, adding a new variable on the stack. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current">
         <xsl:with-param name="vars" tunnel="yes" as="element(var)+">
            <xsl:sequence select="$vars"/>
            <var name="{ @name }">
               <xsl:if test="not(contains(@name,'Q{')) and contains(@name,':')">
                  <xsl:attribute name="namespace-uri" select="namespace-uri-from-QName(resolve-QName(@name,.))"/>
               </xsl:if>
            </var>
         </xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       Those elements are ignored in this mode.
       
       x:label elements can be ignored, they are used by x:label()
       (which selects either the x:label element or the label
       attribute).
       
       TODO: Imports are "resolved" in x:gather-specs().  But this is
       not done the usual way, instead it returns all x:description
       elements.  Change this by using the usual recursive template
       resolving x:import elements in place.  Bur for now, those
       elements are still here, so we have to ignore them...
   -->
   <xsl:template match="x:description/x:param
                        |x:description/x:variable
                        |x:apply
                        |x:call
                        |x:context
                        |x:import
                        |x:label" mode="x:compile">
      <!-- Nothing... -->
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       Default rule for that mode generates an error.
   -->
   <xsl:template match="@*|node()" mode="x:compile">
      <xsl:sequence select="
          error(
              xs:QName('x:XSPEC002'),
              concat('Unhandled node in x:compile mode: ', name(.))
            )"/>
   </xsl:template>

   <!-- *** x:unshare-scenarios *** -->
   <!-- This mode resolves all the <like> elements to bring in the scenarios that
        they specify -->

   <xsl:template match="x:description" as="element(x:description)" mode="x:unshare-scenarios">
      <xsl:copy>
         <xsl:apply-templates select="." mode="x:copy-namespaces"/>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="x:unshare-scenarios"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="x:scenario" as="element(x:scenario)" mode="x:unshare-scenarios">
      <xsl:element name="{x:xspec-name('scenario')}" namespace="{$xspec-namespace}">
         <xsl:copy-of select="@* except @shared"/>
         <xsl:apply-templates mode="x:unshare-scenarios"/>
      </xsl:element>
   </xsl:template>

   <xsl:key name="scenarios" match="x:scenario" use="x:label(.)"/>

   <xsl:template match="x:like" mode="x:unshare-scenarios">
      <xsl:apply-templates select="key('scenarios', x:label(.))/*" mode="x:unshare-scenarios"/>
   </xsl:template>

   <xsl:template match="x:pending" as="element(x:pending)" mode="x:unshare-scenarios">
      <xsl:element name="{x:xspec-name('pending')}" namespace="{$xspec-namespace}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="x:unshare-scenarios"/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="x:scenario[@shared = 'yes']" mode="x:unshare-scenarios"/>

   <xsl:template match="node()" as="node()" mode="x:unshare-scenarios">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="x:unshare-scenarios"/>
      </xsl:copy>
   </xsl:template>

   <!-- *** x:report *** -->

   <xsl:template match="document-node() | attribute() | node()" as="node()+" mode="x:report">
      <xsl:apply-templates select="." mode="test:create-node-generator" />
   </xsl:template>

   <!-- Generates variable declarations for x:expect -->
   <xsl:template name="x:setup-expected" as="node()+">
      <!--<xsl:context-item as="element(x:expect)" use="required" />-->

      <xsl:param name="var" as="xs:string" required="yes" />

      <!-- Remove x:label from x:expect -->
      <xsl:variable name="expect" as="element(x:expect)">
         <xsl:copy>
            <xsl:sequence select="(attribute() | node()) except x:label" />
         </xsl:copy>
      </xsl:variable>

      <!-- Generate <xsl:variable name="impl:expected"> (XSLT)
         or "let $local:expected := ..." (XQuery) to represent the expected items -->
      <xsl:apply-templates select="$expect" mode="test:generate-variable-declarations">
         <xsl:with-param name="var" select="$var" />
      </xsl:apply-templates>
   </xsl:template>

   <!-- Generate error message for user-defined usage of names in XSpec namespace.
        Context node is an x:variable element. -->
   <xsl:template name="x:detect-reserved-variable-name" as="empty-sequence()">
      <xsl:variable name="msg" as="xs:string"
         select="concat('User-defined XSpec variable, ',@name,', must not use the XSpec namespace.')"/>
      <xsl:choose>
         <xsl:when test="starts-with(normalize-space(@name),'Q{')">
            <!-- URI-qualified name -->
            <xsl:if test="replace(@name,'(^\s*Q\{)|(\}.*$)','') eq $xspec-namespace">
               <xsl:sequence select="error(xs:QName('x:XSPEC008'), $msg)"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="namespace-uri-from-QName(
               if (contains(@name,':')) then resolve-QName(@name,.) else QName('',@name)
            ) eq $xspec-namespace">
            <xsl:sequence select="error(xs:QName('x:XSPEC008'), $msg)"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <!-- Given <vars> elements from tunnel parameter, return distinct EQNames.
        The tunnel parameter originates in the match="x:variable" template with
        mode="x:generate-calls" or mode="x:compile". -->
   <xsl:function name="x:distinct-variable-names" as="xs:string*">
      <xsl:param name="vars" as="element(var)*"/>
      <!-- Create sequence of xs:QName values, so we can use distinct-values to compare them all. -->
      <xsl:variable name="qnames" as="xs:QName*"
         select="for $thisvar in $vars return
         if (starts-with(normalize-space($thisvar/@name),'Q{'))
         then QName(replace($thisvar/@name,'(^\s*Q\{)|(\}.*$)',''), substring-after($thisvar/@name,'}'))
         else QName($thisvar/@namespace-uri, $thisvar/@name)
         "/>
      <xsl:variable name="distinctqnames" as="xs:QName*" select="distinct-values($qnames)"/>
      <!-- Return distinct strings, except that any unprefixed name with nonempty URI
         needs Q{} notation to record the namespace URI. -->
      <xsl:sequence select="for $thisqname in $distinctqnames return
         if ( empty(prefix-from-QName($thisqname)) and (string-length(namespace-uri-from-QName($thisqname)) gt 0) )
         then concat('Q{',namespace-uri-from-QName($thisqname),'}',local-name-from-QName($thisqname))
         else string($thisqname)
         "/>
   </xsl:function>

   <xsl:function name="x:label" as="element(x:label)">
      <xsl:param name="labelled" as="element()" />

      <xsl:element name="{x:xspec-name('label')}" namespace="{$xspec-namespace}">
         <xsl:value-of select="($labelled/x:label, $labelled/@label)[1]" />
      </xsl:element>
   </xsl:function>

   <xsl:function name="x:create-pending-attr-generator" as="node()+">
      <xsl:param name="pending-node" as="node()" />

      <xsl:variable name="pending-attr" as="attribute(pending)">
         <xsl:attribute name="pending" select="$pending-node" />
      </xsl:variable>

      <xsl:apply-templates select="$pending-attr" mode="test:create-node-generator" />
   </xsl:function>

   <!-- Returns a lexical QName in XSpec namespace that can be used at runtime.
      Usually 'x:local-name'. -->
   <xsl:function name="x:xspec-name" as="xs:string">
      <xsl:param name="local-name" as="xs:string" />

      <xsl:sequence select="concat($xspec-prefix, ':'[$xspec-prefix], $local-name)" />
   </xsl:function>

   <!-- Removes duplicate nodes from a sequence of nodes. (Removes a node if it appears
     in a prior position of the sequence.)
     This function does not sort nodes in document order.
     Based on http://www.w3.org/TR/xpath-functions-31/#func-distinct-nodes-stable -->
   <xsl:function name="x:distinct-nodes-stable" as="node()*">
     <xsl:param name="nodes" as="node()*"/>

     <xsl:sequence select="$nodes[empty(subsequence($nodes, 1, position() - 1) intersect .)]"/>
   </xsl:function>

   <!--
       Debugging tool.  Return a human-readable path of a node.
   -->
   <xsl:function name="x:node-path" as="xs:string">
      <xsl:param name="n" as="node()"/>
      <xsl:value-of separator="">
         <xsl:for-each select="$n/ancestor-or-self::*">
            <xsl:variable name="prec" select="
                preceding-sibling::*[node-name(.) eq node-name(current())]"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:if test="exists($prec)">
               <xsl:text>[</xsl:text>
               <xsl:value-of select="count($prec) + 1"/>
               <xsl:text>]</xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:choose>
            <xsl:when test="$n instance of attribute()">
               <xsl:text/>/@<xsl:value-of select="name($n)"/>
            </xsl:when>
            <xsl:when test="$n instance of text()">
               <xsl:text>/{text: </xsl:text>
               <xsl:value-of select="substring($n, 1, 5)"/>
               <xsl:text>...}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of comment()">
               <xsl:text>/{comment}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of processing-instruction()">
               <xsl:text>/{pi: </xsl:text>
               <xsl:value-of select="name($n)"/>
               <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of document-node()">
               <xsl:text>/</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of element()"/>
            <xsl:otherwise>
               <xsl:text>/{ns: </xsl:text>
               <xsl:value-of select="name($n)"/>
               <xsl:text>}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:value-of>
   </xsl:function>

</xsl:stylesheet>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2008, 2010 Jeni Tennison                                -->
<!--                                                                       -->
<!-- The contents of this file are subject to the MIT License (see the URI -->
<!-- http://www.opensource.org/licenses/mit-license.php for details).      -->
<!--                                                                       -->
<!-- Permission is hereby granted, free of charge, to any person obtaining -->
<!-- a copy of this software and associated documentation files (the       -->
<!-- "Software"), to deal in the Software without restriction, including   -->
<!-- without limitation the rights to use, copy, modify, merge, publish,   -->
<!-- distribute, sublicense, and/or sell copies of the Software, and to    -->
<!-- permit persons to whom the Software is furnished to do so, subject to -->
<!-- the following conditions:                                             -->
<!--                                                                       -->
<!-- The above copyright notice and this permission notice shall be        -->
<!-- included in all copies or substantial portions of the Software.       -->
<!--                                                                       -->
<!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       -->
<!-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    -->
<!-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.-->
<!-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  -->
<!-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  -->
<!-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     -->
<!-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
