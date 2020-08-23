<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-common-tests.xsl                                -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="3.0"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-common-tests.xsl</pkg:import-uri>

   <xsl:include href="../common/xspec-utils.xsl"/>
   <xsl:include href="gatherer.xsl" />

   <xsl:param name="is-external" as="xs:boolean" select="$initial-document/x:description/@run-as = 'external'" />

   <xsl:param name="force-focus" as="xs:string?" />
   <xsl:variable name="force-focus-ids" as="xs:string*" select="tokenize($force-focus, '\s+')[.]" />

   <!-- The initial XSpec document (the source document of the whole transformation).
      Note that this initial document is different from the document node generated within the
      name="x:generate-tests" template. The latter document is a restructured copy of the initial
      document. Usually the compiler templates should handle the restructured one, but in rare cases
      some of the compiler templates may need to access the initial document. -->
   <xsl:variable name="initial-document" as="document-node(element(x:description))" select="/" />

   <xsl:variable name="actual-document-uri" as="xs:anyURI"
      select="x:actual-document-uri($initial-document)" />

   <!--
      mode="#default"
   -->
   <xsl:mode on-multiple-match="fail" on-no-match="fail" />

   <!-- Actually, xsl:template/@match is "document-node(element(x:description))".
      "element(x:description)" is omitted in order to accept any source document and then reject it
      with a proper error message if it's broken. -->
   <xsl:template match="document-node()" as="node()+">
      <xsl:call-template name="x:perform-initial-checks" />
      <xsl:call-template name="x:generate-tests"/>
   </xsl:template>

   <!--
      Drive the overall compilation of a suite. Apply template on the x:description element, in the
      mode
   -->
   <xsl:template name="x:generate-tests" as="node()+">
      <xsl:context-item as="document-node(element(x:description))" use="required" />

      <!-- Resolve x:import and gather all the children of x:description -->
      <xsl:variable name="specs" as="node()+" select="x:resolve-import(x:description)" />

      <!-- Combine all the children of x:description into a single document so that the following
         language-specific transformation can handle them as a document. -->
      <xsl:variable name="combined-doc" as="document-node(element(x:description))"
         select="x:combine($specs)" />

      <!-- Dispatch to a language-specific transformation (XSLT or XQuery) -->
      <xsl:apply-templates select="$combined-doc/element()" mode="x:generate-tests" />
   </xsl:template>

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
               <xsl:sequence select="@schematron | @xspec-original-location" />

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

   <xsl:template name="x:perform-initial-checks" as="empty-sequence()">
      <xsl:context-item as="document-node()" use="required" />

      <xsl:variable name="deprecation-warning" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$x:saxon-version lt x:pack-version((9, 8))">
               <xsl:text>Saxon version 9.7 or less is not supported.</xsl:text>
            </xsl:when>
            <xsl:when test="$x:saxon-version lt x:pack-version((9, 9))">
               <xsl:text>Saxon version 9.8 is not recommended. Consider migrating to Saxon 9.9.</xsl:text>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:message select="
         if ($deprecation-warning)
         then ('WARNING:', $deprecation-warning)
         else ' ' (: Always write a single non-empty line to help Bats tests to predict line numbers. :)" />

      <xsl:variable name="description-name" as="xs:QName" select="xs:QName('x:description')" />
      <xsl:if test="not(node-name(element()) eq $description-name)">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">Source document is not XSpec. /{$description-name} is missing. Supplied source has /{element() => name()} instead.</xsl:text>
         </xsl:message>
      </xsl:if>
   </xsl:template>

   <!--
       Drive the compilation of scenarios to generate call
       instructions (the scenarios are compiled to an XSLT named
       template or an XQuery function, which must have the
       corresponding call instruction at some point).
   -->
   <xsl:template name="x:call-scenarios">
      <xsl:context-item as="element()" use="required" />

      <!-- Default value of $pending does not affect compiler output but is here if needed in the future -->
      <xsl:param name="pending" select="(.//@focus)[1]" tunnel="yes" as="node()?"/>

      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:message terminate="yes"
            select="'$this must be a description or a scenario, but is: ' || name()" />
      </xsl:if>

      <xsl:apply-templates select="$this/*[1]" mode="x:generate-calls">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      Apply the current mode templates to the following sibling element.
   -->
   <xsl:template name="x:continue-walking-siblings">
      <xsl:context-item as="element()" use="required" />

      <xsl:apply-templates select="following-sibling::*[1]" mode="#current" />
   </xsl:template>

   <!--
      mode="x:generate-calls"
   -->
   <xsl:mode name="x:generate-calls" on-multiple-match="fail" on-no-match="fail" />

   <!--
       Those elements are ignored in this mode.
       
       x:label elements can be ignored, they are used by x:label()
       (which selects either the x:label element or the label
       attribute).
       
       TODO: Imports are "resolved" in x:gather-descriptions().  But this is
       not done the usual way, instead it returns all x:description
       elements.  Change this by using the usual recursive template
       resolving x:import elements in place.  But for now, those
       elements are still here, so we have to ignore them...
   -->
   <xsl:template match="x:apply|x:call|x:context|x:label" mode="x:generate-calls">
      <!-- Nothing, but must continue the sibling-walking... -->
      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:generate-calls">
      <xsl:apply-templates select="*[1]" mode="#current">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>

      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
       A scenario is called by its ID.
   -->
   <xsl:template match="x:scenario" mode="x:generate-calls">
      <xsl:param name="stacked-variables" tunnel="yes" as="element(x:variable)*" />

      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template which in turn continues
         walking the siblings -->
      <xsl:call-template name="x:output-call">
         <xsl:with-param name="last" select="empty(following-sibling::x:scenario)"/>
         <xsl:with-param name="with-param-uqnames"
            select="x:distinct-strings-stable($stacked-variables ! x:variable-UQName(.))" />
      </xsl:call-template>
   </xsl:template>

   <!--
       An expectation is called by its ID.
   -->
   <xsl:template match="x:expect" mode="x:generate-calls">
      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="stacked-variables" as="element(x:variable)*" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" tunnel="yes" />

      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template which in turn continues
         walking the siblings -->
      <xsl:call-template name="x:output-call">
         <xsl:with-param name="last" select="empty(following-sibling::x:expect)"/>
         <xsl:with-param name="with-param-uqnames" as="xs:string*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <xsl:sequence select="$context ! x:known-UQName('x:context')" />
               <xsl:sequence select="x:known-UQName('x:result')" />
            </xsl:if>
            <xsl:sequence
               select="x:distinct-strings-stable($stacked-variables ! x:variable-UQName(.))" />
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       x:variable element generates a variable declaration and adds itself
       on the stack (the tunnel param $stacked-variables).
   -->
   <xsl:template match="x:variable" mode="x:generate-calls">
      <xsl:param name="stacked-variables" tunnel="yes" as="element(x:variable)*" />

      <!-- Reject reserved variables -->
      <xsl:call-template name="x:detect-reserved-variable-name" />

      <!-- The variable declaration. -->
      <xsl:if test="empty(following-sibling::x:call) and empty(following-sibling::x:context)">
         <xsl:apply-templates select="." mode="x:declare-variable" />
      </xsl:if>

      <!-- Continue walking the siblings, adding a new variable on the stack. -->
      <xsl:call-template name="x:continue-walking-siblings">
         <xsl:with-param name="stacked-variables" tunnel="yes" select="$stacked-variables, ." />
      </xsl:call-template>
   </xsl:template>

   <!--
       Global x:variable and x:param elements are not handled like
       local variables and params (which are passed through calls).
       They are declared globally.
       
       x:helper is global.
   -->
   <xsl:template match="x:description/x:helper
                       |x:description/x:param
                       |x:description/x:variable"
                 mode="x:generate-calls">
      <xsl:if test="self::x:variable">
        <xsl:call-template name="x:detect-reserved-variable-name"/>
      </xsl:if>

      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
       Drive the compilation of global params and variables.
   -->
   <xsl:template name="x:compile-global-params-and-variables">
      <xsl:context-item as="element(x:description)" use="required" />

      <xsl:variable name="this" select="." as="element(x:description)"/>

      <!-- mode="x:declare-variable" is not aware of $is-external. That's why @static is checked
         here. -->
      <xsl:if test="not($is-external)">
         <xsl:for-each select="$this/x:param[x:yes-no-synonym(@static, false())]">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">Enabling @static in {name()} is supported only when /{$initial-document/x:description => name()} has @run-as='external'.</xsl:text>
            </xsl:message>
         </xsl:for-each>
      </xsl:if>

      <xsl:apply-templates select="$this/(x:param|x:variable)" mode="x:declare-variable" />
   </xsl:template>

   <!--
       Drive the compilation of scenarios to either XSLT named
       templates or XQuery functions.
   -->
   <xsl:template name="x:compile-scenarios">
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="pending" as="node()?" select="(.//@focus)[1]" tunnel="yes"/>

      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:message terminate="yes"
            select="'$this must be a description or a scenario, but is: ' || name()" />
      </xsl:if>
      <xsl:apply-templates select="$this/*[1]" mode="x:compile-each-element">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      mode="x:compile-each-element"
      Must be "fired" by the named template "x:compile-scenarios".
      It is a "sibling walking" mode: x:compile-scenarios applies the template in this mode on the
      first child, then each template rule must apply the template in this same mode on the next
      sibling. The reason for this navigation style is to easily represent variable scopes.
   -->
   <xsl:mode name="x:compile-each-element" on-multiple-match="fail" on-no-match="fail" />

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:compile-each-element">
      <xsl:apply-templates select="*[1]" mode="#current">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>

      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
       Compile a scenario.
   -->
   <xsl:template match="x:scenario" mode="x:compile-each-element">
      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="apply" as="element(x:apply)?" tunnel="yes" />
      <xsl:param name="call" as="element(x:call)?" tunnel="yes"/>
      <xsl:param name="context" as="element(x:context)?" tunnel="yes"/>

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
               <xsl:copy select="x:apply">
                  <xsl:sequence select="($apply, .) ! attribute()" />

                  <xsl:variable name="local-params" as="element(x:param)*" select="x:param"/>
                  <xsl:sequence
                     select="
                        $apply/x:param[not(@name = $local-params/@name)],
                        $local-params" />
               </xsl:copy>
               <!-- TODO: Test that "x:apply/(node() except x:param)" is empty. -->
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
               <xsl:copy select="x:context">
                  <xsl:sequence select="($context, .)  ! attribute()" />

                  <xsl:variable name="local-params" as="element(x:param)*" select="x:param"/>
                  <xsl:sequence
                     select="
                        $context/x:param[not(@name = $local-params/@name)],
                        $local-params"/>

                  <xsl:sequence
                     select="
                        if (node() except x:param) then
                           (node() except x:param)
                        else
                           $context/(node() except x:param)" />
               </xsl:copy>
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
               <xsl:copy select="x:call">
                  <xsl:sequence select="($call, .) ! attribute()" />

                  <xsl:variable name="local-params" as="element(x:param)*" select="x:param"/>
                  <xsl:sequence
                     select="
                        $call/x:param[not(@name = $local-params/@name)],
                        $local-params"/>
               </xsl:copy>
               <!-- TODO: Test that "x:call/(node() except x:param)" is empty. -->
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$call"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Check duplicate parameter name -->
      <xsl:for-each select="$new-apply, $new-call, $new-context">
         <xsl:variable name="param-owner-name" as="xs:string" select="name()" />
         <xsl:variable name="param-uqnames" as="xs:string*" select="x:param ! x:variable-UQName(.)" />
         <xsl:for-each select="$param-uqnames[subsequence($param-uqnames, 1, position() - 1) = .]">
            <xsl:message terminate="yes">
               <xsl:text expand-text="yes">Duplicate parameter name, {.}, used in {$param-owner-name}.</xsl:text>
            </xsl:message>
         </xsl:for-each>
      </xsl:for-each>

      <!-- Check x:apply -->
      <!-- TODO: Remove this after implementing x:apply -->
      <xsl:if test="$new-apply">
         <xsl:message>
            <xsl:text expand-text="yes">WARNING: The instruction {name($new-apply)} is not supported yet!</xsl:text>
         </xsl:message>
      </xsl:if>

      <!-- Call the serializing template (for XSLT or XQuery). -->
      <xsl:call-template name="x:compile-scenario">
         <xsl:with-param name="pending"   select="$new-pending" tunnel="yes"/>
         <xsl:with-param name="apply"     select="$new-apply"   tunnel="yes"/>
         <xsl:with-param name="call"      select="$new-call"    tunnel="yes"/>
         <xsl:with-param name="context"   select="$new-context" tunnel="yes"/>
      </xsl:call-template>

      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
       Compile an expectation.
   -->
   <xsl:template match="x:expect" mode="x:compile-each-element">
      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" required="yes" tunnel="yes" />
      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />
      <xsl:param name="stacked-variables" as="element(x:variable)*" tunnel="yes" />

      <!-- Call the serializing template (for XSLT or XQuery). -->
      <xsl:call-template name="x:compile-expect">
         <xsl:with-param name="pending" tunnel="yes" select="
             ( $pending, ancestor::x:scenario/@pending )[1]"/>
         <xsl:with-param name="context" tunnel="yes" select="$context"/>
         <xsl:with-param name="call"    tunnel="yes" select="$call"/>
         <xsl:with-param name="param-uqnames" as="xs:string*">
            <xsl:if test="empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus)">
               <xsl:sequence select="$context ! x:known-UQName('x:context')" />
               <xsl:sequence select="x:known-UQName('x:result')" />
            </xsl:if>
            <xsl:sequence
               select="x:distinct-strings-stable($stacked-variables ! x:variable-UQName(.))" />
         </xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
      x:param elements generate actual call param's variable.
   -->
   <xsl:template match="x:param" mode="x:compile-each-element">
      <xsl:apply-templates select="." mode="x:declare-variable" />

      <!-- Continue walking the siblings (only other x:param elements, within this x:call or
         x:context). -->
      <xsl:apply-templates select="following-sibling::*[self::x:param][1]" mode="#current"/>
   </xsl:template>

   <!--
      x:variable element adds a variable on the stack (the tunnel param $stacked-variables).
   -->
   <xsl:template match="x:variable" mode="x:compile-each-element">
      <xsl:param name="stacked-variables" tunnel="yes" as="element(x:variable)*" />

      <!-- Continue walking the siblings, adding a new variable on the stack. -->
      <xsl:call-template name="x:continue-walking-siblings">
         <xsl:with-param name="stacked-variables" tunnel="yes" select="$stacked-variables, ." />
      </xsl:call-template>
   </xsl:template>

   <!--
       Those elements are ignored in this mode.
       
       x:label elements can be ignored, they are used by x:label()
       (which selects either the x:label element or the label
       attribute).
       
       TODO: Imports are "resolved" in x:gather-descriptions().  But this is
       not done the usual way, instead it returns all x:description
       elements.  Change this by using the usual recursive template
       resolving x:import elements in place.  But for now, those
       elements are still here, so we have to ignore them...
   -->
   <xsl:template match="x:description/x:helper
                        |x:description/x:param
                        |x:description/x:variable
                        |x:apply
                        |x:call
                        |x:context
                        |x:label"
                 mode="x:compile-each-element">
      <!-- Nothing, but must continue the sibling-walking... -->
      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

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
      mode="x:generate-tests"
      Does the generation of the test stylesheet.
      This mode assumes that all the scenarios have already been gathered and unshared.
      Actual processing of this mode depends on compile-xquery-tests.xsl and
      compile-xslt-tests.xsl.
   -->
   <xsl:mode name="x:generate-tests" on-multiple-match="fail" on-no-match="fail" />

   <!-- Generates a gateway from x:scenario to System Under Test.
      The actual instruction to enter SUT is provided by the caller. The instruction
      should not contain other actions. -->
   <xsl:template name="x:enter-sut" as="node()+">
      <xsl:context-item as="element(x:scenario)" use="required" />

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

   <!-- Generate error message for user-defined usage of names in XSpec namespace.
        Context node is an x:variable element. -->
   <xsl:template name="x:detect-reserved-variable-name" as="empty-sequence()">
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

   <xsl:template name="x:error-compiling-scenario" as="empty-sequence()">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="message" as="xs:string" />

      <xsl:message terminate="yes">
         <xsl:text expand-text="yes">ERROR in {name()} ('{x:label(.)}'): {$message}</xsl:text>
      </xsl:message>
   </xsl:template>

   <xsl:template name="x:report-test-attribute" as="node()+">
      <xsl:context-item as="element(x:expect)" use="required" />

      <xsl:variable name="expect-test" as="element(x:expect)">
         <!-- Do not set xsl:copy/@copy-namespaces="no". @test may use namespace prefixes and/or the
            default namespace such as xs:QName('foo') -->
         <xsl:copy>
            <xsl:sequence select="@test" />
         </xsl:copy>
      </xsl:variable>

      <!-- Undeclare the default namespace in the wrapper element, because @test may use the default
         namespace such as xs:QName('foo'). -->
      <xsl:call-template name="x:wrap-node-constructors-and-undeclare-default-ns">
         <xsl:with-param name="wrapper-name" select="local-name() || '-test-wrap'" />
         <xsl:with-param name="node-constructors" as="node()+">
            <xsl:apply-templates select="$expect-test" mode="x:node-constructor" />
         </xsl:with-param>
      </xsl:call-template>
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
