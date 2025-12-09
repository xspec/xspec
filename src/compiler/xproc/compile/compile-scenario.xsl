<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/XSL/TransformAlias"
    xmlns:local="urn:x-xspec:compiler:xproc:compile:compile-scenarios:local"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    version="3.0">

    <!--
        Generates the templates that perform the tests.
        Called during mode="local:compile-scenarios-or-expects" in
        compile-child-scenarios-or-expects.xsl.
    -->
   <xsl:template name="x:compile-scenario" as="element(xsl:template)+">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />
      <xsl:param name="reason-for-pending" as="xs:string?" required="yes" />
      <xsl:param name="run-sut-now" as="xs:boolean" required="yes" />
      <xsl:param name="this-scenario" as="element(x:scenario)" select="."/>

      <xsl:variable name="local-preceding-vardecls" as="element()*" select="
            (x:param | x:variable)[following-sibling::x:call]
            | x:param[$run-sut-now]
            | x:variable[following-sibling::x:param][$run-sut-now]" />

      <!-- We have to create these error messages at this stage because before now
         we didn't have merged versions of the environment -->
      <xsl:if test="x:context">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">Can't use {x:xspec-name('context', .)} in a test suite for XProc</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$call/@template">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">{name($call)}/@template not supported for XProc</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$call/@function">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">{name($call)}/@function not supported for XProc</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$call[$run-sut-now][not(@step)]">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">{name($call)} must specify a step to call</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="x:expect and empty($call)">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <!-- Use x:xspec-name() for displaying the element names with the prefix preferred by
                     the user -->
                  <xsl:text expand-text="yes">There are {x:xspec-name('expect', .)} but no {x:xspec-name('call', .)} has been given</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>

      <xsl:element name="xsl:template" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="x:known-UQName('x:' || @id)" />
         <xsl:attribute name="as" select="'element(' || x:known-UQName('x:scenario') || ')'" />

         <!-- Runtime context item of the template being generated at this compile time must be
            absent (xspec/xspec#423). Even when the template being generated at this compile time is
            called with a context item at run time, it must be removed by
            xsl:context-item[@use="absent"]. -->
         <xsl:element name="xsl:context-item" namespace="{$x:xsl-namespace}">
            <xsl:attribute name="use" select="'absent'" />
         </xsl:element>

         <xsl:for-each select="accumulator-before('stacked-vardecls-distinct-uqnames')">
            <param name="{.}" as="item()*" required="yes" />
         </xsl:for-each>

         <message>
            <xsl:if test="exists($reason-for-pending)">
               <xsl:text>PENDING: </xsl:text>
               <xsl:for-each select="normalize-space($reason-for-pending)[.]">
                  <xsl:text expand-text="yes">({.}) </xsl:text>
               </xsl:for-each>
            </xsl:if>
            <xsl:if test="parent::x:scenario">
               <xsl:text>..</xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(x:label(.))" />
         </message>

         <!-- <x:scenario> -->
         <xsl:element name="xsl:element" namespace="{$x:xsl-namespace}">
            <xsl:attribute name="name" select="local-name()" />
            <xsl:attribute name="namespace" select="namespace-uri()" />

            <xsl:variable name="scenario-attributes" as="attribute()+">
               <xsl:sequence select="@id" />
               <xsl:attribute name="xspec" select="(@original-xspec, @xspec)[1]" />
               <xsl:sequence select="x:pending-attribute-from-reason($reason-for-pending)" />
            </xsl:variable>
            <xsl:apply-templates select="$scenario-attributes" mode="x:node-constructor" />

            <xsl:apply-templates select="x:label(.)" mode="x:node-constructor" />

            <xsl:call-template name="x:timestamp">
               <xsl:with-param name="event" select="'start'" />
            </xsl:call-template>

            <!-- Handle local preceding variable declarations and x:call in document
               order, instead of x:call first and variable declarations second. -->
            <xsl:for-each select="$local-preceding-vardecls | x:call">
               <xsl:choose>
                  <xsl:when test="self::x:call">
                     <!-- Copy the input to the test result report XML -->
                     <!-- Undeclare the default namespace in the wrapper element, because
                        x:param/@select may use the default namespace such as xs:QName('foo'). -->
                     <xsl:call-template name="x:wrap-node-constructors-and-undeclare-default-ns">
                        <xsl:with-param name="wrapper-name" select="'input-wrap'" />
                        <xsl:with-param name="node-constructors" as="element(xsl:element)">
                           <xsl:apply-templates select="." mode="x:node-constructor" />
                        </xsl:with-param>
                     </xsl:call-template>

                  </xsl:when>

                  <xsl:when test=". intersect $local-preceding-vardecls">
                     <!-- Handle local preceding variable declarations. The other local variable
                        declarations are handled in mode="local:invoke-compiled-scenarios-or-expects"
                        in invoke-compiled-child-scenarios-or-expects.xsl. -->
                     <xsl:apply-templates select=".[x:reason-for-pending(.) => empty()]"
                        mode="x:declare-variable" />
                  </xsl:when>

                  <xsl:otherwise>
                     <xsl:message terminate="yes">
                        <xsl:call-template name="x:prefix-diag-message">
                           <xsl:with-param name="message" select="'Unhandled'" />
                        </xsl:call-template>
                     </xsl:message>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>

            <xsl:if test="$run-sut-now">
               <variable name="{x:known-UQName('x:result')}" as="item()*">
                  <!-- Set up variables containing the input and option values -->
                  <xsl:for-each select="($call)[1]/(x:input | x:option)">
                     <xsl:apply-templates select="." mode="x:declare-variable">
                        <xsl:with-param name="comment" select="concat(@port (: x:input :), @name (: x:option :), ' ', local-name())" />
                     </xsl:apply-templates>
                  </xsl:for-each>

                  <xsl:variable name="invocation-type" as="xs:string">call-step</xsl:variable>

                  <!-- Enter SUT -->
                  <xsl:choose>
                     <!-- TODO: Remove code for external transformations after confirming that it doesn't apply to XProc
                     <xsl:when test="$is-external">
                        <!-/- Set up the $impl:transform-options variable -/->
                        <xsl:call-template name="x:transform-options">
                           <xsl:with-param name="invocation-type" select="$invocation-type" />
                        </xsl:call-template>

                        <!-/- Generate XSLT elements which perform entering SUT -/->
                        <xsl:variable name="enter-sut" as="element()+">
                           <xsl:call-template name="x:enter-sut">
                              <xsl:with-param name="instruction" as="element(xsl:sequence)">
                                 <sequence
                                    select="transform(${x:known-UQName('impl:transform-options')})?output" />
                              </xsl:with-param>
                           </xsl:call-template>
                        </xsl:variable>

                        <!-/- Invoke transform() -/->
                        <xsl:sequence select="$enter-sut" />
                     </xsl:when>
                     -->

                     <xsl:when test="$invocation-type eq 'call-step'">
                        <!-- Create the step call -->
                        <xsl:call-template name="x:enter-sut">
                           <xsl:with-param name="instruction" as="element(xsl:sequence)">
                              <sequence>
                                 <!-- The step being called may use namespace prefixes for
                                    parsing the input/option values -->
                                 <xsl:sequence select="x:copy-of-namespaces($call)" />

                                 <xsl:attribute name="select"
                                    select="x:step-call-text($call, $this-scenario)"/>
                              </sequence>
                           </xsl:with-param>
                        </xsl:call-template>
                     </xsl:when>

                     <xsl:otherwise>
                        <!-- TODO: Adapt to a new error reporting facility (above usages too). -->
                        <xsl:message terminate="yes">
                           <xsl:call-template name="x:prefix-diag-message">
                              <xsl:with-param name="message" select="'cannot happen.'" />
                           </xsl:call-template>
                        </xsl:message>
                     </xsl:otherwise>
                  </xsl:choose>
               </variable>

               <xsl:call-template name="x:call-report-sequence">
                  <xsl:with-param name="sequence-variable-eqname"
                     select="x:known-UQName('x:result')" />
               </xsl:call-template>
               <xsl:comment> invoke each compiled x:expect </xsl:comment>
            </xsl:if>

            <xsl:call-template name="x:invoke-compiled-child-scenarios-or-expects">
               <xsl:with-param name="handled-child-vardecls" select="$local-preceding-vardecls" />
            </xsl:call-template>

            <xsl:call-template name="x:timestamp">
               <xsl:with-param name="event" select="'end'" />
            </xsl:call-template>

         <!-- </x:scenario> -->
         </xsl:element>
      </xsl:element>

      <xsl:call-template name="x:compile-child-scenarios-or-expects" />
   </xsl:template>

   <!-- Returns a text node of the step function call expression. The names of the step and the
      option variables are URIQualifiedName. -->
   <xsl:function name="x:step-call-text" as="text()">
      <xsl:param name="call" as="element(x:call)"/>
      <xsl:param name="parent-scenario" as="element(x:scenario)"><!-- For context of error messages --></xsl:param>

      <!-- xsl:for-each is not for iteration but for simplifying XPath -->
      <xsl:for-each select="$call">
         <xsl:variable name="step-uqname" as="xs:string" select="x:UQName-of-step(@step)"/>
         <xsl:variable name="declared-inputs" as="element(p:input)*" select="x:get-step-inputs(., $parent-scenario)"/>

         <xsl:value-of>
            <xsl:text expand-text="yes">{$step-uqname}(</xsl:text>
            <xsl:iterate select="($declared-inputs, .[exists(x:option)])">
               <xsl:param name="separator" as="xs:string" select="''"/>
               <xsl:variable name="argument-to-construct" as="element()" select="."/>
               <xsl:sequence select="$separator"/>
               <xsl:choose>
                  <xsl:when test="self::p:input">
                     <xsl:variable name="x-input" as="element(x:input)*"
                        select="$call/x:input[@port eq string($argument-to-construct/@port)]"/>
                     <xsl:choose>
                        <xsl:when test="empty($x-input)">
                           <xsl:for-each select="$parent-scenario/x:call">
                              <xsl:message terminate="yes">
                                 <xsl:call-template name="x:prefix-diag-message">
                                    <xsl:with-param name="message">
                                       <xsl:text expand-text="yes">Missing x:input for port '{ $argument-to-construct/@port }'.</xsl:text>
                                    </xsl:with-param>
                                 </xsl:call-template>
                              </xsl:message>
                           </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="count($x-input) gt 1">
                           <xsl:for-each select="$parent-scenario/x:call">
                              <xsl:message terminate="yes">
                                 <xsl:call-template name="x:prefix-diag-message">
                                    <xsl:with-param name="message">
                                       <xsl:text expand-text="yes">Multiple x:input elements for port '{ $argument-to-construct/@port }'.</xsl:text>
                                    </xsl:with-param>
                                 </xsl:call-template>
                              </xsl:message>
                           </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:text expand-text="yes">${x:variable-UQName($x-input)}</xsl:text>
                           <xsl:if test="exists(ancestor-or-self::*/@use-when)">
                              <xsl:for-each select="$parent-scenario">
                                 <xsl:message>
                                    <xsl:call-template name="x:prefix-diag-message">
                                       <xsl:with-param name="level" select="'WARNING'" />
                                       <xsl:with-param name="message">
                                          <xsl:text expand-text="yes">Declaration of port {
                                             $x-input/@port} is under @use-when, which XSpec assumes is true.</xsl:text>
                                       </xsl:with-param>
                                    </xsl:call-template>
                                 </xsl:message>
                              </xsl:for-each>
                           </xsl:if>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:call-template name="option-map-text">
                        <xsl:with-param name="parent-scenario" select="$parent-scenario"/>
                     </xsl:call-template>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:next-iteration>
                  <!-- Add comma between adjacent arguments -->
                  <xsl:with-param name="separator" select="', '"/>
               </xsl:next-iteration>
            </xsl:iterate>
            <xsl:text>)</xsl:text>
         </xsl:value-of>
         <xsl:if test="count($call/x:input) ne count($declared-inputs)">
            <xsl:for-each select="$parent-scenario/x:call">
               <xsl:message terminate="yes">
                  <xsl:call-template name="x:prefix-diag-message">
                     <xsl:with-param name="message">
                        <xsl:text expand-text="yes">Too many x:input elements for calling step { $call/@step }.</xsl:text>
                     </xsl:with-param>
                  </xsl:call-template>
               </xsl:message>
            </xsl:for-each>
         </xsl:if>
      </xsl:for-each>
   </xsl:function>

   <!--
      Local templates and functions
   -->

   <xsl:template name="option-map-text" as="text()">
      <xsl:context-item as="element(x:call)" use="required"/>
      <xsl:param name="parent-scenario" as="element(x:scenario)"
         required="yes"><!-- For context of error messages --></xsl:param>
      <!-- Check duplicate option name -->
      <xsl:variable name="dup-option-error-string" as="xs:string?"
         select="local:option-dup-name-error-string(.)"/>
      <xsl:if test="$dup-option-error-string">
         <xsl:for-each select="$parent-scenario/x:call">
            <xsl:message terminate="yes">
               <xsl:call-template name="x:prefix-diag-message">
                  <xsl:with-param name="message" select="$dup-option-error-string"/>
               </xsl:call-template>
            </xsl:message>
         </xsl:for-each>
      </xsl:if>

      <xsl:value-of>
         <xsl:iterate select="x:option">
            <xsl:param name="start-or-between" as="xs:string" select="'map{'">
               <!-- Start the map construct -->
            </xsl:param>
            <xsl:on-completion>
               <!-- End the map construct with closing curly brace -->
               <xsl:text>}</xsl:text>
            </xsl:on-completion>
            <xsl:variable name="resolved-option-QName" as="xs:string"
               select="x:UQName-from-EQName-ignoring-default-ns(@name, .)"/>
            <xsl:value-of expand-text="yes">{$start-or-between}'{$resolved-option-QName}': ${
               x:variable-UQName(.)}</xsl:value-of>
            <xsl:next-iteration>
               <!-- Add comma between adjacent map entries -->
               <xsl:with-param name="start-or-between" select="', '"/>
            </xsl:next-iteration>
         </xsl:iterate>
      </xsl:value-of>
   </xsl:template>

   <!-- Returns an error string if the given element has duplicate x:option/@name -->
   <!-- This function is adapted from local:param-dup-name-error-string in
      base/compile/compile-child-scenarios-or-expects.xsl -->
   <xsl:function name="local:option-dup-name-error-string" as="xs:string?">
      <xsl:param name="owner" as="element(x:call)" />

      <xsl:variable name="uqnames" as="xs:string*"
         select="$owner/x:option/@name ! x:UQName-from-EQName-ignoring-default-ns(., parent::x:option)" />
      <xsl:for-each select="$uqnames[subsequence($uqnames, 1, position() - 1) = .][1]">
         <xsl:text expand-text="yes">Duplicate option name, {.}, used in {name($owner)}.</xsl:text>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>