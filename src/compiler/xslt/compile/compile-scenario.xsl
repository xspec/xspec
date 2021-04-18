<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:local="urn:x-xspec:compiler:xslt:compile:compile-scenario:local"
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

      <xsl:param name="apply" as="element(x:apply)?" required="yes" tunnel="yes" />
      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" required="yes" tunnel="yes" />
      <xsl:param name="reason-for-pending" as="xs:string?" required="yes" />
      <xsl:param name="run-sut-now" as="xs:boolean" required="yes" />

      <xsl:variable name="local-preceding-vardecls" as="element()*" select="
            (x:param | x:variable)[following-sibling::x:call or following-sibling::x:context]
            | x:param[$run-sut-now]
            | x:variable[following-sibling::x:param][$run-sut-now]" />

      <!-- We have to create these error messages at this stage because before now
         we didn't have merged versions of the environment -->
      <xsl:if test="$context/@href and ($context/node() except $context/x:param)">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">Can't set the context document using both the href attribute and the content of the {name($context)} element</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$call/@template and $call/@function">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text>Can't call a function and a template at the same time</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$apply and $context">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">Can't use {name($apply)} and set a context at the same time</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$apply and $call">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">Can't use {name($apply)} and {name($call)} at the same time</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$context and $call/@function">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text>Can't set a context and call a function at the same time</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$context/x:param and $call">
         <xsl:message>
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="level" select="'WARNING'" />
               <xsl:with-param name="message" as="xs:string">
                  <xsl:text expand-text="yes">{name($context)}/{name($context/x:param[1])} will have no effect on {name($call)}</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:message>
      </xsl:if>
      <xsl:if test="$run-sut-now">
         <xsl:call-template name="x:check-param-max-position" />
      </xsl:if>
      <xsl:if test="x:expect and empty($call) and empty($apply) and empty($context)">
         <xsl:message terminate="yes">
            <xsl:call-template name="x:prefix-diag-message">
               <xsl:with-param name="message" as="xs:string">
                  <!-- Use x:xspec-name() for displaying the element names with the prefix preferred by
                     the user -->
                  <xsl:text expand-text="yes">There are {x:xspec-name('expect', .)} but no {x:xspec-name('call', .)}, {x:xspec-name('apply', .)} or {x:xspec-name('context', .)} has been given</xsl:text>
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

            <!-- Handle local preceding variable declarations and apply/call/context in document
               order, instead of apply/call/context first and variable declarations second. -->
            <xsl:for-each select="$local-preceding-vardecls | x:apply | x:call | x:context">
               <xsl:choose>
                  <xsl:when test="self::x:apply or self::x:call or self::x:context">
                     <!-- Copy the input to the test result report XML -->
                     <!-- Undeclare the default namespace in the wrapper element, because
                        x:param/@select may use the default namespace such as xs:QName('foo'). -->
                     <xsl:call-template name="x:wrap-node-constructors-and-undeclare-default-ns">
                        <xsl:with-param name="wrapper-name" select="'input-wrap'" />
                        <xsl:with-param name="node-constructors" as="element(xsl:element)">
                           <xsl:apply-templates select="." mode="x:node-constructor" />
                        </xsl:with-param>
                     </xsl:call-template>

                     <xsl:if test="self::x:context and $run-sut-now">
                        <!-- Set up context, still in document order with respect to x:variable siblings.
                             Pass $context through as tunnel parameter. -->
                        <xsl:call-template name="local:set-up-context"/>
                     </xsl:if>
                  </xsl:when>

                  <xsl:when test=". intersect $local-preceding-vardecls">
                     <!-- Handle local preceding variable declarations. The other local variable
                        declarations are handled in mode="local:invoke-compiled-scenarios-or-expects"
                        in invoke-compiled-child-scenarios-or-expects.xsl. -->
                     <xsl:apply-templates select="." mode="x:declare-variable" />
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
               <xsl:if test="$context and not(x:context)">
                  <!-- If context was not set up in xsl:for-each above, set it up here.
                     Context might have come from an ancestor scenario.
                     Pass $context through as tunnel parameter. -->
                  <xsl:call-template name="local:set-up-context"/>
               </xsl:if>

               <variable name="{x:known-UQName('x:result')}" as="item()*">
                  <!-- Set up variables containing the parameter values -->
                  <xsl:apply-templates select="($call, $apply, $context)[1]/x:param"
                     mode="x:declare-variable" />

                  <!-- Enter SUT -->
                  <xsl:choose>
                     <xsl:when test="$is-external">
                        <!-- Set up the $impl:transform-options variable -->
                        <xsl:call-template name="x:transform-options" />

                        <!-- Generate XSLT elements which perform entering SUT -->
                        <xsl:variable name="enter-sut" as="element()+">
                           <xsl:call-template name="x:enter-sut">
                              <xsl:with-param name="instruction" as="element(xsl:sequence)">
                                 <sequence
                                    select="transform(${x:known-UQName('impl:transform-options')})?output" />
                              </xsl:with-param>
                           </xsl:call-template>
                        </xsl:variable>

                        <!-- Invoke transform() -->
                        <xsl:choose>
                           <xsl:when test="$call/@template and $context">
                              <for-each select="${x:variable-UQName($context)}">
                                 <variable name="{x:known-UQName('impl:transform-options')}" as="map({x:known-UQName('xs:string')}, item()*)">
                                    <xsl:attribute name="select">
                                       <xsl:text expand-text="yes">{x:known-UQName('map:put')}(${x:known-UQName('impl:transform-options')}, 'global-context-item', .)</xsl:text>
                                    </xsl:attribute>
                                 </variable>
                                 <xsl:sequence select="$enter-sut" />
                              </for-each>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:sequence select="$enter-sut" />
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:when>

                     <xsl:when test="$call/@template">
                        <!-- Create the template call -->
                        <xsl:variable name="template-call" as="element()">
                           <xsl:call-template name="x:enter-sut">
                              <xsl:with-param name="instruction" as="element(xsl:call-template)">
                                 <call-template
                                    name="{$call ! x:UQName-from-EQName-ignoring-default-ns(@template, .)}">
                                    <xsl:for-each select="$call/x:param">
                                       <with-param>
                                          <!-- @as may use namespace prefixes -->
                                          <xsl:sequence select="x:copy-of-namespaces(.)" />

                                          <xsl:attribute name="name"
                                             select="x:UQName-from-EQName-ignoring-default-ns(@name, .)" />
                                          <xsl:attribute name="select"
                                             select="'$' || x:variable-UQName(.)" />

                                          <xsl:sequence select="@tunnel, @as" />
                                       </with-param>
                                    </xsl:for-each>
                                 </call-template>
                              </xsl:with-param>
                           </xsl:call-template>
                        </xsl:variable>

                        <xsl:choose>
                           <xsl:when test="$context">
                              <!-- Switch to the context and call the template -->
                              <for-each select="${x:variable-UQName($context)}">
                                 <xsl:sequence select="$template-call" />
                              </for-each>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:sequence select="$template-call" />
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:when>

                     <xsl:when test="$call/@function">
                        <!-- Create the function call -->
                        <xsl:call-template name="x:enter-sut">
                           <xsl:with-param name="instruction" as="element(xsl:sequence)">
                              <sequence>
                                 <!-- The function being called may use namespace prefixes for
                                    parsing the parameter values -->
                                 <xsl:sequence select="x:copy-of-namespaces($call)" />

                                 <xsl:attribute name="select" select="x:function-call-text($call)" />
                              </sequence>
                           </xsl:with-param>
                        </xsl:call-template>
                     </xsl:when>

                     <xsl:when test="$apply">
                        <!-- TODO: x:apply not implemented yet -->
                        <!-- Create the apply templates instruction -->
                        <!-- TODO: This code path (including @catch, namespaces and @as) has not been tested. -->
                        <xsl:call-template name="x:enter-sut">
                           <xsl:with-param name="instruction" as="element(xsl:apply-templates)">
                              <apply-templates>
                                 <!-- $apply/@select may use namespace prefixes and/or the default
                                    namespace such as xs:QName('foo') -->
                                 <xsl:sequence select="x:copy-of-namespaces($apply)" />

                                 <xsl:sequence select="$apply/@select" />

                                 <xsl:if test="$apply/@mode => exists()">
                                    <xsl:attribute name="mode"
                                       select="$apply ! x:UQName-from-EQName-ignoring-default-ns(@mode, .)" />
                                 </xsl:if>

                                 <xsl:for-each select="$apply/x:param">
                                    <with-param>
                                       <!-- @as may use namespace prefixes -->
                                       <xsl:sequence select="x:copy-of-namespaces(.)" />

                                       <xsl:attribute name="name"
                                          select="x:UQName-from-EQName-ignoring-default-ns(@name, .)" />
                                       <xsl:attribute name="select"
                                          select="'$' || x:variable-UQName(.)" />

                                       <xsl:sequence select="@tunnel, @as" />
                                    </with-param>
                                 </xsl:for-each>
                              </apply-templates>
                           </xsl:with-param>
                        </xsl:call-template>
                     </xsl:when>

                     <xsl:when test="$context">
                        <!-- Create the template call -->
                        <xsl:call-template name="x:enter-sut">
                           <xsl:with-param name="instruction" as="element(xsl:apply-templates)">
                              <apply-templates select="${x:variable-UQName($context)}">
                                 <xsl:if test="$context/@mode => exists()">
                                    <xsl:attribute name="mode"
                                       select="$context ! x:UQName-from-EQName-ignoring-default-ns(@mode, .)" />
                                 </xsl:if>

                                 <xsl:for-each select="$context/x:param">
                                    <with-param>
                                       <!-- @as may use namespace prefixes -->
                                       <xsl:sequence select="x:copy-of-namespaces(.)" />

                                       <xsl:attribute name="name"
                                          select="x:UQName-from-EQName-ignoring-default-ns(@name, .)" />
                                       <xsl:attribute name="select"
                                          select="'$' || x:variable-UQName(.)" />

                                       <xsl:sequence select="@tunnel, @as" />
                                    </with-param>
                                 </xsl:for-each>
                              </apply-templates>
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

               <call-template name="{x:known-UQName('rep:report-sequence')}">
                  <with-param name="sequence" select="${x:known-UQName('x:result')}" />
                  <with-param name="report-name" select="'result'" />
               </call-template>
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

   <!--
      Local templates
   -->

   <xsl:template name="local:set-up-context" as="element(xsl:variable)+">
      <xsl:context-item use="absent" />

      <xsl:param name="context" as="element(x:context)" required="yes" tunnel="yes"/>

      <!-- Set up the variable of x:context -->
      <xsl:apply-templates select="$context" mode="x:declare-variable"/>

      <!-- Set up its alias variable ($x:context) for publishing it along with $x:result -->
      <xsl:element name="xsl:variable" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="x:known-UQName('x:context')"/>
         <xsl:attribute name="select" select="'$' || x:variable-UQName($context)"/>
      </xsl:element>
   </xsl:template>

</xsl:stylesheet>