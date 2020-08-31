<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl" />

   <!--
      Generates the templates that perform the tests.
      Called during mode="local:compile-scenarios-or-expects" in
      compile-child-scenarios-or-expects.xsl.
   -->
   <xsl:template name="x:compile-scenario" as="element(xsl:template)+">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="apply" as="element(x:apply)?" tunnel="yes" />
      <xsl:param name="call" as="element(x:call)?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" tunnel="yes" />
      <xsl:param name="stacked-variables" as="element(x:variable)*" tunnel="yes" />

      <xsl:variable name="local-preceding-variables" as="element(x:variable)*"
         select="x:call/preceding-sibling::x:variable | x:context/preceding-sibling::x:variable" />

      <xsl:variable name="pending-p" as="xs:boolean"
         select="exists($pending) and empty(ancestor-or-self::*/@focus)" />

      <!-- We have to create these error messages at this stage because before now
         we didn't have merged versions of the environment -->
      <xsl:if test="$context/@href and ($context/node() except $context/x:param)">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Can't set the context document using both the href attribute and the content of the {name($context)} element</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$call/@template and $call/@function">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text>Can't call a function and a template at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$apply and $context">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Can't use {name($apply)} and set a context at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$apply and $call">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Can't use {name($apply)} and {name($call)} at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$context and $call/@function">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text>Can't set a context and call a function at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="x:expect and empty($call) and empty($apply) and empty($context)">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <!-- Use x:xspec-name() for displaying the element names with the prefix preferred by
                  the user -->
               <xsl:text expand-text="yes">There are {x:xspec-name('expect', .)} but no {x:xspec-name('call', .)}, {x:xspec-name('apply', .)} or {x:xspec-name('context', .)} has been given</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>

      <xsl:element name="xsl:template" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="x:known-UQName('x:' || @id)" />
         <xsl:attribute name="as" select="'element(' || x:known-UQName('x:scenario') || ')'" />

         <xsl:element name="xsl:context-item" namespace="{$x:xsl-namespace}">
            <xsl:attribute name="use" select="'absent'" />
         </xsl:element>

         <xsl:for-each select="distinct-values($stacked-variables ! x:variable-UQName(.))">
            <param name="{.}" required="yes" />
         </xsl:for-each>

         <message>
            <xsl:if test="$pending-p">
               <xsl:text>PENDING: </xsl:text>
               <xsl:if test="$pending != ''">
                  <xsl:text expand-text="yes">({normalize-space($pending)}) </xsl:text>
               </xsl:if>
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
               <xsl:if test="$pending-p">
                  <xsl:sequence select="x:pending-attribute-from-pending-node($pending)" />
               </xsl:if>
            </xsl:variable>
            <xsl:apply-templates select="$scenario-attributes" mode="x:node-constructor" />

            <xsl:apply-templates select="x:label(.)" mode="x:node-constructor" />

            <!-- Handle variables and apply/call/context in document order,
               instead of apply/call/context first and variables second. -->
            <xsl:for-each select="$local-preceding-variables | x:apply | x:call | x:context">
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
                  </xsl:when>
                  <xsl:when test="self::x:variable">
                     <xsl:apply-templates select="." mode="x:declare-variable" />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:message select="'Unhandled', name()" terminate="yes" />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>

            <xsl:if test="not($pending-p) and x:expect">
               <xsl:if test="$context">
                  <!-- Set up the variable of x:context -->
                  <xsl:apply-templates select="$context" mode="x:declare-variable" />

                  <!-- Set up its alias variable ($x:context) for publishing it along with $x:result -->
                  <xsl:element name="xsl:variable" namespace="{$x:xsl-namespace}">
                     <xsl:attribute name="name" select="x:known-UQName('x:context')" />
                     <xsl:attribute name="select" select="'$' || x:variable-UQName($context)" />
                  </xsl:element>
               </xsl:if>

               <variable name="{x:known-UQName('x:result')}" as="item()*">
                  <!-- Set up variables containing the parameter values -->
                  <!-- #current is mode="local:compile-scenarios-or-expects" in
                     compile-child-scenarios-or-expects.xsl. -->
                  <xsl:apply-templates select="($call, $apply, $context)[1]/x:param[1]"
                     mode="#current" />

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
                        <xsl:variable name="template-call">
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
                        <xsl:message terminate="yes">Error: cannot happen.</xsl:message>
                     </xsl:otherwise>
                  </xsl:choose>
               </variable>

               <call-template name="{x:known-UQName('rep:report-sequence')}">
                  <with-param name="sequence" select="${x:known-UQName('x:result')}" />
                  <with-param name="report-name" select="'result'" />
               </call-template>
               <xsl:comment> invoke each compiled x:expect </xsl:comment>
            </xsl:if>

            <xsl:call-template name="x:invoke-compiled-child-scenarios-or-expects" />

         <!-- </x:scenario> -->
         </xsl:element>
      </xsl:element>

      <xsl:call-template name="x:compile-child-scenarios-or-expects" />
   </xsl:template>

</xsl:stylesheet>