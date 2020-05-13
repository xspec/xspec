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
   <xsl:function name="x:xspec-prefix" as="xs:string">
      <xsl:param name="e" as="element()" />

      <xsl:sequence select="
         (
            in-scope-prefixes($e)
               [namespace-uri-for-prefix(., $e) eq $xspec-namespace]
               [. (: Do not allow zero-length string :)],
            
            (: Fallback. Intentionally made weird in order to avoid collision. :)
            'XsPeC'
         )[1]"/>
   </xsl:function>

   <!--
       Drive the overall compilation of a suite.  Apply template on
       the x:description element, in the mode
   -->
   <xsl:template name="x:generate-tests">
      <!-- Actually, xsl:context-item/@as is "document-node(element(x:description))".
         "element(x:description)" is omitted in order to enable the "Source document is not XSpec..."
         error message. -->
      <xsl:context-item as="document-node()" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:variable name="deprecation-warning" as="xs:string?" select="
         if (x:saxon-version() lt x:pack-version((9, 8)))
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
            <xsl:element name="{x:xspec-name($this/*,'description')}" namespace="{$xspec-namespace}">
               <xsl:sequence select="x:copy-namespaces($this/x:description)" />
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
          <xsl:sequence select="document(@href) treat as document-node(element(x:description))" />
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

   <!-- *** x:gather-specs *** -->
   <!-- This mode makes each spec less context-dependent by performing these transformations:
      * Copy @xslt-version from x:description to descendant x:scenario
      * Add @xspec (and @xspec-original-location if applicable) to each scenario to record
        absolute URI of originating .xspec file
      * Resolve x:*/@href into absolute URI
      * Discard whitespace-only text node in user-content unless otherwise specified by an ancestor
      * Discard whitespace-only text node in non user-content unless it's in x:label
      * Remove leading and trailing whitespace from names
      * Wrap user-content text node in x:text resolving @expand-text specified by an ancestor -->

   <!-- Dispatch user-content to its dedicated mode. This must be done in the highest priority. -->
   <xsl:template match="node()[x:is-user-content(.)]" as="node()?" mode="x:gather-specs" priority="1">
      <xsl:apply-templates select="." mode="x:gather-user-content" />
   </xsl:template>

   <!-- This mode always starts from this template -->
   <xsl:template match="x:description" mode="x:gather-specs">
      <xsl:apply-templates mode="#current">
         <xsl:with-param name="xslt-version"   tunnel="yes" select="x:xslt-version(.)"/>
         <xsl:with-param name="preserve-space" tunnel="yes" select="x:parse-preserve-space(.)" />
         <xsl:with-param name="xspec-module-uri" tunnel="yes"
            select="x:resolve-xml-uri-with-catalog(document-uri(/))" />
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="x:scenario" as="element(x:scenario)" mode="x:gather-specs">
      <xsl:param name="xslt-version" as="xs:decimal" tunnel="yes" required="yes"/>
      <xsl:param name="xspec-module-uri" as="xs:anyURI" tunnel="yes" required="yes" />

      <xsl:copy>
         <xsl:attribute name="xslt-version" select="$xslt-version" />
         <xsl:attribute name="xspec" select="$xspec-module-uri" />
         <xsl:sequence select="
            (: Keep this sequence order for local @xspec-original-location to take precedence
               over x:description's one. :)
            /x:description/@xspec-original-location,
            @*" />

         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="text()[not(normalize-space())]" as="text()?" mode="x:gather-specs">
      <xsl:if test="parent::x:label">
         <!-- TODO: The specification of @label and x:label is not clear about whitespace.
            Preserve it for now. -->
         <xsl:sequence select="." />
      </xsl:if>
   </xsl:template>

   <xsl:template match="@href" as="attribute(href)" mode="x:gather-specs">
      <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
         select="resolve-uri(., x:base-uri(.))" />
   </xsl:template>

   <xsl:template match="@as | @function | @mode | @name | @template" as="attribute()"
      mode="x:gather-specs">
      <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}" select="x:trim(.)" />
   </xsl:template>

   <xsl:template match="node() | attribute()" as="node()" mode="x:gather-specs">
      <xsl:call-template name="x:identity" />
   </xsl:template>

   <!-- *** x:gather-user-content *** -->
   <!-- This mode works as a part of x:gather-specs mode and handles user-content. Once you enter
      this mode, you never go back to x:gather-specs mode. -->

   <!-- x:space has been replaced with x:text -->
   <xsl:template match="x:space" as="empty-sequence()" mode="x:gather-user-content">
      <xsl:message terminate="yes">
         <xsl:value-of select="name()" />
         <xsl:text> is obsolete. Use </xsl:text>
         <xsl:value-of select="x:xspec-name(., 'text')" />
         <xsl:text> instead.</xsl:text>
      </xsl:message>
   </xsl:template>

   <xsl:template match="@x:expand-text" as="empty-sequence()" mode="x:gather-user-content" />

   <xsl:template match="x:text" as="element(x:text)?" mode="x:gather-user-content">
      <!-- Unwrap -->
      <xsl:apply-templates mode="#current" />
   </xsl:template>

   <xsl:template match="text()" as="element(x:text)?" mode="x:gather-user-content">
      <xsl:param name="preserve-space" as="xs:QName*" tunnel="yes" select="()"/>

      <xsl:if test="normalize-space()
         or x:is-ws-only-text-node-significant(., $preserve-space)">
         <xsl:element name="{x:xspec-name(parent::*, 'text')}" namespace="{$xspec-namespace}">
            <xsl:variable name="expand-text" as="attribute()?"
               select="
                  ancestor::*[if (self::x:*)
                              then @expand-text
                              else @x:expand-text][1]
                  /@*[if (parent::x:*)
                      then self::attribute(expand-text)
                      else self::attribute(x:expand-text)]" />
            <xsl:if test="$expand-text">
               <xsl:attribute name="expand-text" select="$expand-text"/>
            </xsl:if>

            <xsl:sequence select="." />
         </xsl:element>
      </xsl:if>
   </xsl:template>

   <!-- @priority is to avoid the ambiguity with the @match="text()" template -->
   <xsl:template match="node()|@*" as="node()" mode="x:gather-user-content" priority="-1">
      <xsl:call-template name="x:identity" />
   </xsl:template>

   <!--
       Drive the compilation of scenarios to generate call
       instructions (the scenarios are compiled to an XSLT named
       template or an XQuery function, which must have the
       corresponding call instruction at some point).
   -->
   <xsl:template name="x:call-scenarios">
      <xsl:context-item as="element()" use="required"
         use-when="element-available('xsl:context-item')" />

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
      <xsl:context-item as="element()" use="required"
         use-when="element-available('xsl:context-item')" />

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
       A scenario is called by its ID.
       
       Call "x:output-call", which must on turn call "x:continue-call-scenarios".
   -->
   <xsl:template match="x:scenario" mode="x:generate-calls">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(x:var)*"/>

      <xsl:call-template name="x:output-call">
         <xsl:with-param name="last" select="empty(following-sibling::x:scenario)"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <xsl:element name="param" namespace="">
                  <xsl:sequence select="x:copy-namespaces(.)" />
                  <xsl:sequence select="@name" />
                  <xsl:attribute name="select" select="concat('$', @name)" />
               </xsl:element>
            </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       An expectation is called by its ID.
       
       Call "x:output-call", which must on turn call "x:continue-call-scenarios".
   -->
   <xsl:template match="x:expect" mode="x:generate-calls">
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:param name="vars"    select="()" tunnel="yes" as="element(x:var)*"/>

      <xsl:call-template name="x:output-call">
         <xsl:with-param name="last" select="empty(following-sibling::x:expect)"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <xsl:element name="param" namespace="">
                  <xsl:attribute name="name" select="x:xspec-name(., 'result')" />
                  <xsl:attribute name="select" select="concat('$', x:xspec-name(., 'result'))" />
               </xsl:element>
            </xsl:if>
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <xsl:element name="param" namespace="">
                  <xsl:sequence select="x:copy-namespaces(.)"/>
                  <xsl:sequence select="@name" />
                  <xsl:attribute name="select" select="concat('$', @name)" />
               </xsl:element>
            </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       x:variable element generates a variable declaration and adds a
       variable on the stack (the tunnel param $vars).
   -->
   <xsl:template match="x:variable" mode="x:generate-calls">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(x:var)*"/>

      <xsl:call-template name="x:detect-reserved-variable-name"/>
      <!-- The variable declaration. -->
      <xsl:if test="empty(following-sibling::x:call) and empty(following-sibling::x:context)">
         <xsl:apply-templates select="." mode="test:generate-variable-declarations" />
      </xsl:if>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current">
         <xsl:with-param name="vars" tunnel="yes" as="element(x:var)+">
            <xsl:sequence select="$vars"/>
            <xsl:element name="x:var">
               <xsl:attribute name="name" select="@name"/>
               <xsl:if test="not(contains(@name,'Q{')) and contains(@name,':')">
                  <xsl:attribute name="namespace-uri" select="namespace-uri-from-QName(resolve-QName(@name,.))"/>
               </xsl:if>
            </xsl:element>
         </xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       Global x:variable and x:param elements are not handled like
       local variables and params (which are passed through calls).
       They are declared globally.
   -->
   <xsl:template match="x:description/x:param|x:description/x:variable" mode="x:generate-calls">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(x:var)*"/>

      <xsl:if test="self::x:variable">
        <xsl:call-template name="x:detect-reserved-variable-name"/>
      </xsl:if>
      <!-- Continue walking the siblings. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
   </xsl:template>

   <!--
       Drive the compilation of global params and variables.
   -->
   <xsl:template name="x:compile-global-params-and-vars">
      <xsl:context-item as="element(x:description)" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:variable name="this" select="." as="element(x:description)"/>
      <xsl:apply-templates select="$this/(x:param|x:variable)" mode="test:generate-variable-declarations"/>
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
      <xsl:context-item as="element()" use="required"
         use-when="element-available('xsl:context-item')" />

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
      <xsl:param name="vars"    select="()" tunnel="yes" as="element(x:var)*"/>

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
               <xsl:for-each select="x:apply">
                  <xsl:copy>
                     <xsl:sequence select="$apply/@*"/>
                     <xsl:sequence select="@*"/>
                     <xsl:sequence select="
                        $apply/x:param[not(@name = $local-params/@name)],
                        $local-params"/>
                     <!-- TODO: Test that "x:apply/(node() except x:param)" is empty. -->
                  </xsl:copy>
               </xsl:for-each>
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
               <xsl:for-each select="x:context">
                  <xsl:copy>
                     <xsl:sequence select="$context/@*"/>
                     <xsl:sequence select="@*"/>
                     <xsl:sequence select="
                       $context/x:param[not(@name = $local-params/@name)],
                       $local-params"/>
                     <xsl:sequence select="
                       if ( ./(node() except x:param) ) then
                       ./(node() except x:param)
                       else
                       $context/(node() except x:param)"/>
                  </xsl:copy>
               </xsl:for-each>
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
               <xsl:for-each select="x:call">
                  <xsl:copy>
                     <xsl:sequence select="$call/@*"/>
                     <xsl:sequence select="@*"/>
                     <xsl:sequence select="
                        $call/x:param[not(@name = $local-params/@name)],
                        $local-params"/>
                     <!-- TODO: Test that "x:call/(node() except x:param)" is empty. -->
                  </xsl:copy>
               </xsl:for-each>
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
               <xsl:element name="param" namespace="">
                  <xsl:sequence select="x:copy-namespaces(.)"/>
                  <xsl:sequence select="@name" />
                  <xsl:attribute name="required" select="'yes'" />
               </xsl:element>
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
      <xsl:param name="vars"    select="()"    tunnel="yes" as="element(x:var)*"/>

      <!-- Call the serializing template (for XSLT or XQuery). -->
      <xsl:call-template name="x:output-expect">
         <xsl:with-param name="pending" tunnel="yes" select="
             ( $pending, ancestor::x:scenario/@pending )[1]"/>
         <xsl:with-param name="context" tunnel="yes" select="$context"/>
         <xsl:with-param name="call"    tunnel="yes" select="$call"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <xsl:element name="param" namespace="">
                  <xsl:attribute name="name" select="x:xspec-name(., 'result')" />
                  <xsl:attribute name="required" select="'yes'" />
               </xsl:element>
            </xsl:if>
            <xsl:for-each select="x:distinct-variable-names($vars)">
               <xsl:element name="param" namespace="">
                  <xsl:sequence select="x:copy-namespaces(.)"/>
                  <xsl:sequence select="@name" />
                  <xsl:attribute name="required" select="'yes'" />
               </xsl:element>
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
      <xsl:apply-templates select="." mode="test:generate-variable-declarations" />

      <!-- Continue walking the siblings (only other x:param elements, within this
           x:call or x:context). -->
      <xsl:apply-templates select="following-sibling::*[self::x:param][1]" mode="#current"/>
   </xsl:template>

   <!--
       x:variable element adds a variable on the stack (the tunnel
       param $vars).
   -->
   <xsl:template match="x:variable" mode="x:compile">
      <xsl:param name="vars" select="()" tunnel="yes" as="element(x:var)*"/>

      <!-- Continue walking the siblings, adding a new variable on the stack. -->
      <xsl:apply-templates select="following-sibling::*[1]" mode="#current">
         <xsl:with-param name="vars" tunnel="yes" as="element(x:var)+">
            <xsl:sequence select="$vars"/>
            <xsl:element name="x:var">
               <xsl:attribute name="name" select="@name"/>
               <xsl:if test="not(contains(@name,'Q{')) and contains(@name,':')">
                  <xsl:attribute name="namespace-uri" select="namespace-uri-from-QName(resolve-QName(@name,.))"/>
               </xsl:if>
            </xsl:element>
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

   <xsl:key name="scenarios" match="x:scenario[not(x:is-user-content(.))]" use="x:label(.)" />

   <xsl:template match="document-node() | attribute() | node()" as="node()*" mode="x:unshare-scenarios">
      <xsl:choose>
         <!-- Leave user-content intact -->
         <xsl:when test="x:is-user-content(.)">
            <xsl:sequence select="." />
         </xsl:when>

         <!-- Discard @shared and shared x:scenario -->
         <xsl:when test="self::attribute(shared)[parent::x:scenario]
            or self::x:scenario[@shared = 'yes']" />

         <!-- Replace x:like with specified scenario's child elements -->
         <xsl:when test="self::x:like">
            <xsl:variable name="label" as="element(x:label)" select="x:label(.)" />
            <xsl:variable name="scenario" as="element(x:scenario)*" select="key('scenarios', $label)" />
            <xsl:choose>
               <xsl:when test="empty($scenario)">
                  <xsl:sequence select="error(xs:QName('x:XSPEC009'),
                     concat(name(), ': Scenario not found: ', $label))" />
               </xsl:when>
               <xsl:when test="$scenario[2]">
                  <xsl:sequence select="error(xs:QName('x:XSPEC010'),
                     concat(name(), ': ', count($scenario), ' scenarios found with same label: ', $label))" />
               </xsl:when>
               <xsl:when test="$scenario intersect ancestor::x:scenario">
                  <xsl:sequence select="error(xs:QName('x:XSPEC011'),
                     concat(name(), ': Reference to ancestor scenario creates infinite loop: ', $label))" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="$scenario/element()" mode="#current" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>

         <!-- By default, apply identity template -->
         <xsl:otherwise>
            <xsl:call-template name="x:identity" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- *** x:report *** -->

   <xsl:template match="document-node() | attribute() | node()" as="node()+" mode="x:report">
      <xsl:apply-templates select="." mode="test:create-node-generator" />
   </xsl:template>

   <!-- Generates a gateway from x:scenario to System Under Test.
      The actual instruction to enter SUT is provided by the caller. The instruction
      should not contain other actions. -->
   <xsl:template name="x:enter-sut" as="node()+">
      <xsl:context-item as="element(x:scenario)" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:param name="instruction" as="node()+" required="yes" />

      <xsl:choose>
         <xsl:when test="x:yes-no-synonym(ancestor-or-self::*[@catch][1]/@catch, false())">
            <xsl:call-template name="x:output-try-catch">
               <xsl:with-param name="instruction" select="$instruction" />
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$instruction" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- Generates the ID of current x:scenario or x:expect.
      These default templates assume that all the scenarios have already been gathered and unshared.
      So the default ID may not always be usable for backtracking. For such backtracking purposes,
      override these default templates and implement your own ID generation. The generated ID must
      be castable as xs:NCName, because ID is used as a part of local name. -->
   <xsl:template match="x:scenario" as="xs:string" mode="x:generate-id">
      <xsl:variable name="ancestor-or-self-tokens" as="xs:string+">
         <xsl:for-each select="ancestor-or-self::x:scenario">
            <!-- Find preceding sibling x:scenario, taking x:pending into account -->
            <xsl:variable name="parent-description-or-scenario" as="element()"
               select="ancestor::element()[self::x:description or self::x:scenario][1]" />
            <xsl:variable name="preceding-sibling-scenarios" as="element(x:scenario)*"
               select="$parent-description-or-scenario/descendant::x:scenario
                  [ancestor::element()[self::x:description or self::x:scenario][1] is $parent-description-or-scenario]
                  [current() >> .]
                  [not(x:is-user-content(.))]" />

            <xsl:sequence select="concat(
               local-name(),
               count($preceding-sibling-scenarios) + 1)" />
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
            [not(x:is-user-content(.))]" />

      <xsl:variable name="scenario-id" as="xs:string">
         <xsl:apply-templates select="$scenario" mode="#current" />
      </xsl:variable>

      <xsl:sequence select="concat(
         $scenario-id,
         '-',
         local-name(),
         count($preceding-sibling-expects) + 1)" />
   </xsl:template>

   <!-- Generate error message for user-defined usage of names in XSpec namespace.
        Context node is an x:variable element. -->
   <xsl:template name="x:detect-reserved-variable-name" as="empty-sequence()">
      <xsl:context-item as="element(x:variable)" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:variable name="qname" as="xs:QName"
         select="x:resolve-EQName-ignoring-default-ns(@name, .)" />

      <xsl:if test="namespace-uri-from-QName($qname) eq $xspec-namespace">
         <xsl:variable name="msg" as="xs:string"
            select="concat('User-defined XSpec variable, ',
                           @name,
                           ', must not use the XSpec namespace.')" />
         <xsl:sequence select="error(xs:QName('x:XSPEC008'), $msg)" />
      </xsl:if>
   </xsl:template>

   <!-- Given <x:vars> elements from tunnel parameter, return distinct EQNames.
        The tunnel parameter originates in the match="x:variable" template with
        mode="x:generate-calls" or mode="x:compile". -->
   <xsl:function name="x:distinct-variable-names" as="element(x:var)*">
      <xsl:param name="vars" as="element(x:var)*"/>

      <!-- Create sequence of xs:QName values, so we can use distinct-values to compare them all. -->
      <xsl:variable name="qnames" as="xs:QName*">
         <xsl:for-each select="$vars">
            <xsl:sequence select="if (starts-with(@name, 'Q{'))
                                  then x:resolve-URIQualifiedName(@name)
                                  else QName(@namespace-uri, @name)" />
         </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="distinct-qnames" as="xs:QName*" select="distinct-values($qnames)"/>

      <!-- Return distinctly named <x:var> elements. Any unprefixed name with nonempty URI
         or any prefixed name that is not uniquely bound in the set of variables
         uses Q{} notation to record the namespace URI. -->
      <xsl:for-each select="$distinct-qnames">
         <xsl:variable name="this-qname" select="."/>
         <xsl:variable name="this-prefix" select="prefix-from-QName($this-qname)"/>
         <xsl:element name="x:var">
            <xsl:choose>
               <xsl:when test="empty(prefix-from-QName($this-qname)) and (string-length(namespace-uri-from-QName($this-qname)) gt 0)">
                  <!-- No prefix but there is a nonempty namespace URI -->
                  <xsl:attribute name="name" select="concat('Q{',namespace-uri-from-QName($this-qname),'}',local-name-from-QName($this-qname))"/>
               </xsl:when>
               <xsl:when test="string-length(namespace-uri-from-QName($this-qname)) eq 0">
                  <!-- No namespace -->
                  <xsl:attribute name="name" select="local-name-from-QName($this-qname)"/>
               </xsl:when>
               <xsl:otherwise>
                  <!-- Prefix bound to a namespace -->
                  <xsl:namespace name="{$this-prefix}" select="namespace-uri-from-QName($this-qname)"/>
                  <xsl:attribute name="name" select="$this-qname"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:for-each>
   </xsl:function>

   <xsl:function name="x:label" as="element(x:label)">
      <xsl:param name="labelled" as="element()" />

      <xsl:element name="{x:xspec-name($labelled,'label')}" namespace="{$xspec-namespace}">
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
      <xsl:param name="context" as="element()"/>
      <xsl:param name="local-name" as="xs:string" />

      <xsl:sequence select="concat(x:xspec-prefix($context), ':'[x:xspec-prefix($context)], $local-name)" />
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
