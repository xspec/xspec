<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-xspec-tests.xsl                                 -->
<!--  Author:     Jeni Tennison                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <xsl:import href="generate-common-tests.xsl" />
   <xsl:import href="generate-tests-helper.xsl" />

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-xspec-tests.xsl</pkg:import-uri>

   <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl" />

   <xsl:output indent="yes" />

   <!-- Absolute URI of .xsl file to be tested.
      This needs to be resolved here, not in mode="x:generate-tests" where base-uri() is not available -->
   <xsl:variable name="stylesheet-uri" as="xs:anyURI"
      select="/x:description/resolve-uri(@stylesheet, base-uri())" />

   <!--
      mode="x:generate-tests"
   -->
   <xsl:template match="x:description" as="element(xsl:stylesheet)" mode="x:generate-tests">
      <!-- True if this XSpec is testing Schematron -->
      <xsl:variable name="is-schematron" as="xs:boolean" select="exists(@xspec-original-location)" />

      <!-- The compiled stylesheet element. -->
      <!-- The generated xsl:stylesheet must not have @exclude-result-prefixes. The test result
         report XML may use namespace prefixes in XPath expressions even when the prefixes are not
         used in node names. -->
      <stylesheet version="{x:xslt-version(.) => x:decimal-string()}">
         <xsl:sequence select="x:copy-of-namespaces(.)" />

         <xsl:if test="not($is-external)">
            <xsl:text>&#10;   </xsl:text><xsl:comment> the tested stylesheet </xsl:comment>
            <import href="{$stylesheet-uri}" />
         </xsl:if>

         <xsl:comment> an XSpec stylesheet providing tools </xsl:comment>
         <include href="{resolve-uri('generate-tests-utils.xsl')}" />

         <xsl:choose>
            <xsl:when test="$is-schematron">
               <include href="{resolve-uri('../schematron/sch-location-compare.xsl')}" />
               <!-- xspec-utils.xsl is included by sch-location-compare.xsl -->
            </xsl:when>
            <xsl:otherwise>
               <include href="{resolve-uri('../common/xspec-utils.xsl')}" />
            </xsl:otherwise>
         </xsl:choose>

         <!-- Absolute URI of the master .xspec file (Original one if specified i.e. Schematron) -->
         <xsl:variable name="xspec-master-uri" as="xs:anyURI"
            select="(@xspec-original-location, $actual-document-uri)[1] cast as xs:anyURI" />
         <variable name="{x:known-UQName('x:xspec-uri')}" as="{x:known-UQName('xs:anyURI')}">
            <xsl:value-of select="$xspec-master-uri" />
         </variable>

         <!-- Compile global params and global variables. -->
         <xsl:call-template name="x:compile-global-params-and-vars" />

         <xsl:if test="$is-external">
            <!-- If no $x:saxon-config is provided by global x:variable, declare a dummy one so that
               $x:saxon-config is always available -->
            <xsl:if
               test="
                  empty(
                     x:variable[x:resolve-EQName-ignoring-default-ns(@name, .) eq xs:QName('x:saxon-config')]
                  )">
               <variable name="{x:known-UQName('x:saxon-config')}" as="empty-sequence()" />
            </xsl:if>
         </xsl:if>

         <!-- The main compiled template. -->
         <xsl:comment> the main template to run the suite </xsl:comment>
         <template name="{x:known-UQName('x:main')}" as="empty-sequence()">
            <xsl:text>&#10;      </xsl:text><xsl:comment> info message </xsl:comment>
            <!-- Message content must be constructed at run time -->
            <message>
               <text>Testing with </text>
               <value-of select="system-property('{x:known-UQName('xsl:product-name')}')" />
               <text>
                  <xsl:text> </xsl:text>
               </text>
               <value-of select="system-property('{x:known-UQName('xsl:product-version')}')" />
            </message>

            <xsl:comment> set up the result document (the report) </xsl:comment>
            <!-- Use xsl:result-document/@format to avoid clashes with <xsl:output> in the stylesheet
               being tested which would otherwise govern the output of the report XML. -->
            <xsl:element name="xsl:result-document" namespace="{$x:xsl-namespace}">
               <xsl:choose>
                  <xsl:when test="$x:saxon-version lt x:pack-version((9, 9, 1, 1))">
                     <!-- Workaround for a Saxon bug: https://saxonica.plan.io/issues/4093 -->

                     <!-- Create a temp XSpec namespace node, because non-zero-length XSpec prefix
                        is not always available here. Any non-zero-length non-xsl prefix will do,
                        because the temp namespace node is only for the xsl:result-document element -->
                     <xsl:variable name="temp-prefix" as="xs:string"
                        select="'workaround-for-saxon-bug-4093'" />
                     <xsl:namespace name="{$temp-prefix}" select="$x:xspec-namespace" />

                     <xsl:attribute name="format"
                        select="$temp-prefix || ':xml-report-serialization-parameters'" />
                  </xsl:when>

                  <xsl:otherwise>
                     <!-- Escape curly braces because @format is AVT -->
                     <xsl:attribute name="format"
                        select="'Q{{' || $x:xspec-namespace || '}}xml-report-serialization-parameters'" />
                  </xsl:otherwise>
               </xsl:choose>

               <xsl:element name="xsl:element" namespace="{$x:xsl-namespace}">
                  <xsl:attribute name="name" select="x:xspec-name('report', .)" />
                  <xsl:attribute name="namespace" select="$x:xspec-namespace" />

                  <xsl:apply-templates select="x:element-additional-namespace-nodes(.)"
                     mode="test:create-node-generator"/>

                  <xsl:variable name="attributes" as="attribute()+">
                     <xsl:attribute name="xspec" select="$xspec-master-uri" />

                     <!-- This bit of jiggery-pokery with the $stylesheet-uri variable is so
                        that the URI appears in the trace report generated from running the
                        test stylesheet, which can then be picked up by stylesheets that
                        process *that* to generate a coverage report -->
                     <xsl:attribute name="stylesheet" select="$stylesheet-uri" />

                     <!-- Do not always copy @schematron.
                        @schematron may exist even when this XSpec is not testing Schematron. -->
                     <xsl:if test="$is-schematron">
                        <xsl:sequence select="@schematron" />
                     </xsl:if>
                  </xsl:variable>
                  <xsl:apply-templates select="$attributes" mode="test:create-node-generator" />

                  <!-- @date must be evaluated at run time -->
                  <xsl:element name="xsl:attribute" namespace="{$x:xsl-namespace}">
                     <xsl:attribute name="name" select="'date'" />
                     <xsl:attribute name="namespace" />
                     <xsl:attribute name="select" select="'current-dateTime()'" />
                  </xsl:element>

                  <!-- Generate calls to the compiled top-level scenarios. -->
                  <xsl:text>&#10;            </xsl:text><xsl:comment> a call instruction for each top-level scenario </xsl:comment>
                  <xsl:call-template name="x:call-scenarios" />
               </xsl:element>
            </xsl:element>
         </template>

         <!-- Compile the top-level scenarios. -->
         <xsl:call-template name="x:compile-scenarios" />
      </stylesheet>
   </xsl:template>

   <!-- *** x:output-call *** -->
   <!-- Generates a call to the template compiled from a scenario or an expect element. -->

   <xsl:template name="x:output-call">
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="last" as="xs:boolean" />

      <!-- URIQualifiedNames of the variables that will be passed as the parameters (of the same
         URIQualifiedName) to the call -->
      <xsl:param name="with-param-uqnames" as="xs:string*" />

      <xsl:variable name="local-name" as="xs:string">
         <xsl:apply-templates select="." mode="x:generate-id" />
      </xsl:variable>

      <call-template name="{x:known-UQName('x:' || $local-name)}">
         <xsl:for-each select="$with-param-uqnames">
            <with-param name="{.}" select="${.}" />
         </xsl:for-each>
      </call-template>

      <!-- Continue compiling calls. -->
      <xsl:call-template name="x:continue-call-scenarios" />
   </xsl:template>

   <!-- *** x:compile *** -->
   <!-- Generates the templates that perform the tests -->

   <xsl:template name="x:output-scenario" as="element(xsl:template)+">
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

      <xsl:variable name="scenario-id" as="xs:string">
         <xsl:apply-templates select="." mode="x:generate-id" />
      </xsl:variable>

      <!-- We have to create these error messages at this stage because before now
         we didn't have merged versions of the environment -->
      <xsl:if test="$context/@href and ($context/node() except $context/x:param)">
         <xsl:call-template name="x:output-scenario-error">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Can't set the context document using both the href attribute and the content of the {name($context)} element</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$call/@template and $call/@function">
         <xsl:call-template name="x:output-scenario-error">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text>Can't call a function and a template at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$apply and $context">
         <xsl:call-template name="x:output-scenario-error">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Can't use {name($apply)} and set a context at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$apply and $call">
         <xsl:call-template name="x:output-scenario-error">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">Can't use {name($apply)} and {name($call)} at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$context and $call/@function">
         <xsl:call-template name="x:output-scenario-error">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text>Can't set a context and call a function at the same time</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="x:expect and empty($call) and empty($apply) and empty($context)">
         <xsl:call-template name="x:output-scenario-error">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">There are {x:xspec-name('expect', .)} but no {x:xspec-name('call', .)}, {x:xspec-name('apply', .)} or {x:xspec-name('context', .)} has been given</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>

      <template name="{x:known-UQName('x:' || $scenario-id)}"
         as="element({x:known-UQName('x:scenario')})">
         <xsl:sequence select="x:copy-of-namespaces(.)" />

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
            <xsl:attribute name="name" select="x:xspec-name('scenario', .)" />
            <xsl:attribute name="namespace" select="$x:xspec-namespace" />

            <xsl:variable name="scenario-attributes" as="attribute()+">
               <xsl:attribute name="id" select="$scenario-id" />
               <xsl:attribute name="xspec" select="(@xspec-original-location, @xspec)[1]" />
               <xsl:if test="$pending-p">
                  <xsl:sequence select="x:pending-attribute-from-pending-node($pending)" />
               </xsl:if>
            </xsl:variable>
            <xsl:apply-templates select="$scenario-attributes" mode="test:create-node-generator" />

            <xsl:apply-templates select="x:label(.)" mode="test:create-node-generator" />

            <!-- Handle variables and apply/call/context in document order,
               instead of apply/call/context first and variables second. -->
            <xsl:for-each select="$local-preceding-variables | x:apply | x:call | x:context">
               <xsl:choose>
                  <xsl:when test="self::x:apply or self::x:call or self::x:context">
                     <!-- Copy the input to the test result report XML -->
                     <xsl:apply-templates select="." mode="test:create-node-generator" />
                  </xsl:when>
                  <xsl:when test="self::x:variable">
                     <xsl:apply-templates select="." mode="test:generate-variable-declarations" />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:message select="'Unhandled', name()" terminate="yes" />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>

            <xsl:if test="not($pending-p) and x:expect">
               <variable name="{x:known-UQName('x:result')}" as="item()*">
                  <!-- Set up variables before entering SUT -->
                  <xsl:choose>
                     <xsl:when test="$call">
                        <!-- Set up variables containing the parameter values -->
                        <xsl:apply-templates select="$call/x:param[1]" mode="x:compile" />

                        <!-- Set up the $impl:context variable -->
                        <xsl:apply-templates select="$context[$call/@template]"
                           mode="test:generate-variable-declarations" />
                     </xsl:when>

                     <xsl:when test="$apply">
                        <!-- Set up variables containing the parameter values -->
                        <xsl:apply-templates select="$apply/x:param[1]" mode="x:compile" />
                     </xsl:when>

                     <xsl:when test="$context">
                        <!-- Set up the $impl:context variable -->
                        <xsl:apply-templates select="$context" mode="test:generate-variable-declarations" />

                        <!-- Set up variables containing the parameter values -->
                        <xsl:apply-templates select="$context/x:param[1]" mode="x:compile" />
                     </xsl:when>
                  </xsl:choose>

                  <!-- Enter SUT -->
                  <xsl:choose>
                     <xsl:when test="$is-external">
                        <!-- Set up the $impl:transform-options variable -->
                        <xsl:call-template name="x:setup-transform-options" />

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

               <call-template name="{x:known-UQName('test:report-sequence')}">
                  <with-param name="sequence" select="${x:known-UQName('x:result')}" />
                  <with-param name="wrapper-name" as="{x:known-UQName('xs:string')}">
                     <xsl:value-of select="x:xspec-name('result', .)" />
                  </with-param>
               </call-template>
               <xsl:comment> a call instruction for each x:expect element </xsl:comment>
            </xsl:if>

            <xsl:call-template name="x:call-scenarios" />

         <!-- </x:scenario> -->
         </xsl:element>
      </template>

      <xsl:call-template name="x:compile-scenarios" />
   </xsl:template>

   <!-- Constructs options for transform() -->
   <xsl:template name="x:setup-transform-options" as="element(xsl:variable)">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="call" as="element(x:call)?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" tunnel="yes" />

      <variable name="{x:known-UQName('impl:transform-options')}" as="map({x:known-UQName('xs:string')}, item()*)">
         <map>
            <!--
               Common options
            -->
            <map-entry key="'cache'" select="false()" /><!-- cache=true() invalidates different static parameters -->
            <map-entry key="'delivery-format'" select="'raw'" />

            <!-- 'stylesheet-node' might be faster than 'stylesheet-location' when repeated. (Just a guess.
               Haven't tested.) But 'stylesheet-node' disables $x:result?err?line-number on @catch=true. -->
            <map-entry key="'stylesheet-location'">
               <xsl:value-of select="$stylesheet-uri" />
            </map-entry>

            <map-entry key="'stylesheet-params'">
               <map>
                  <xsl:apply-templates select="/x:description/x:param" mode="x:param-to-map-entry" />
               </map>
            </map-entry>
            <if test="${x:known-UQName('x:saxon-config')} => exists()">
               <if
                  test="${x:known-UQName('x:saxon-config')} => {x:known-UQName('test:is-saxon-config')}() => not()">
                  <message terminate="yes">
                     <xsl:text expand-text="yes">ERROR: ${x:xspec-name('saxon-config', .)} does not appear to be a Saxon configuration</xsl:text>
                  </message>
               </if>
               <map-entry key="'vendor-options'">
                  <map>
                     <map-entry key="QName('http://saxon.sf.net/', 'configuration')">
                        <choose>
                           <when
                              test="${x:known-UQName('x:saxon-version')} le {x:known-UQName('x:pack-version')}((9, 9, 1, 6))">
                              <apply-templates select="${x:known-UQName('x:saxon-config')}"
                                 mode="{x:known-UQName('test:fixup-saxon-config')}" />
                           </when>
                           <otherwise>
                              <sequence select="${x:known-UQName('x:saxon-config')}" />
                           </otherwise>
                        </choose>
                     </map-entry>
                  </map>
               </map-entry>
            </if>

            <!--
               Options for call-template invocation and apply-templates invocation
            -->
            <xsl:for-each select="($call[@template], $context)[1]">
               <map-entry key="'template-params'">
                  <map>
                     <xsl:apply-templates
                        select="x:param[x:yes-no-synonym(@tunnel, false()) => not()]"
                        mode="x:param-to-map-entry" />
                  </map>
               </map-entry>
               <map-entry key="'tunnel-params'">
                  <map>
                     <xsl:apply-templates
                        select="x:param[x:yes-no-synonym(@tunnel, false())]"
                        mode="x:param-to-map-entry" />
                  </map>
               </map-entry>
            </xsl:for-each>

            <!--
               Invocation-specific options
            -->
            <xsl:choose>
               <xsl:when test="$call/@template">
                  <map-entry key="'initial-template'"
                     select="{x:QName-expression-from-EQName-ignoring-default-ns($call/@template, $call)}" />
               </xsl:when>

               <xsl:when test="$call/@function">
                  <map-entry key="'function-params'">
                     <xsl:attribute name="select">
                        <xsl:text>[</xsl:text>
                        <xsl:value-of separator=", ">
                           <xsl:apply-templates select="$call/x:param" mode="x:param-to-select-attr">
                              <xsl:sort select="xs:integer(@position)" />
                           </xsl:apply-templates>
                        </xsl:value-of>
                        <xsl:text>]</xsl:text>
                     </xsl:attribute>
                  </map-entry>
                  <map-entry key="'initial-function'"
                     select="{x:QName-expression-from-EQName-ignoring-default-ns($call/@function, $call)}" />
               </xsl:when>

               <xsl:when test="$context">
                  <map-entry
                     key="if (${x:variable-UQName($context)} instance of node()) then 'source-node' else 'initial-match-selection'"
                     select="${x:variable-UQName($context)}" />
                  <xsl:if test="$context/@mode">
                     <map-entry key="'initial-mode'"
                        select="{x:QName-expression-from-EQName-ignoring-default-ns($context/@mode, $context)}" />
                  </xsl:if>
               </xsl:when>
            </xsl:choose>
         </map>
      </variable>
   </xsl:template>

   <xsl:template name="x:output-try-catch" as="element(xsl:try)">
      <xsl:context-item use="absent" />

      <xsl:param name="instruction" as="element()" required="yes" />

      <try>
         <xsl:sequence select="$instruction" />
         <catch>
            <map>
               <map-entry key="'err'">
                  <map>
                     <!-- Variables available within xsl:catch:
                        https://www.w3.org/TR/xslt-30/#element-catch -->
                     <xsl:for-each
                        select="'code', 'description', 'value', 'module', 'line-number', 'column-number'">
                        <map-entry key="'{.}'" select="${x:known-UQName('err:' || .)}" />
                     </xsl:for-each>
                  </map>
               </map-entry>
            </map>
         </catch>
      </try>
   </xsl:template>

   <xsl:template name="x:output-expect" as="element(xsl:template)">
      <xsl:context-item as="element(x:expect)" use="required" />

      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" required="yes" tunnel="yes" />
      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />

      <!-- URIQualifiedNames of the (required) parameters of the template being generated -->
      <xsl:param name="param-uqnames" as="xs:string*" required="yes" />

      <xsl:variable name="pending-p" as="xs:boolean"
         select="exists($pending) and empty(ancestor::*/@focus)" />

      <xsl:variable name="expect-id" as="xs:string">
         <xsl:apply-templates select="." mode="x:generate-id" />
      </xsl:variable>

      <template name="{x:known-UQName('x:' || $expect-id)}" as="element({x:known-UQName('x:test')})">
         <xsl:sequence select="x:copy-of-namespaces(.)" />

         <xsl:for-each select="$param-uqnames">
            <param name="{.}" required="yes" />
         </xsl:for-each>

         <message>
            <xsl:if test="$pending-p">
               <xsl:text>PENDING: </xsl:text>
               <xsl:if test="normalize-space($pending)">
                  <xsl:text expand-text="yes">({normalize-space($pending)}) </xsl:text>
               </xsl:if>
            </xsl:if>
            <xsl:value-of select="x:label(.) => normalize-space()" />
         </message>

         <xsl:if test="not($pending-p)">
            <xsl:variable name="xslt-version" as="xs:decimal" select="x:xslt-version(.)" />

            <!-- Set up the $impl:expected variable -->
            <xsl:apply-templates select="." mode="test:generate-variable-declarations">
               <xsl:with-param name="comment" select="'expected result'" />
            </xsl:apply-templates>

            <!-- Flags for test:deep-equal() enclosed in ''. -->
            <xsl:variable name="deep-equal-flags" as="xs:string"
               select="$x:apos || '1'[$xslt-version eq 1] || $x:apos" />

            <xsl:choose>
               <xsl:when test="@test">
                  <xsl:comment> wrap $x:result into a doc node if possible </xsl:comment>
                  <!-- This variable declaration could be moved from here (the
                     template generated from x:expect) to the template
                     generated from x:scenario. It depends only on
                     $x:result, so could be computed only once. -->
                  <variable name="{x:known-UQName('impl:test-items')}" as="item()*">
                     <choose>
                        <!-- From trying this out, it seems like it's useful for the test
                           to be able to test the nodes that are generated in the
                           $x:result as if they were *children* of the context node.
                           Have to experiment a bit to see if that really is the case.
                           TODO: To remove. Use directly $x:result instead.  See issue 14. -->
                        <when
                           test="exists(${x:known-UQName('x:result')}) and {x:known-UQName('test:wrappable-sequence')}(${x:known-UQName('x:result')})">
                           <sequence select="{x:known-UQName('test:wrap-nodes')}(${x:known-UQName('x:result')})" />
                        </when>
                        <otherwise>
                           <sequence select="${x:known-UQName('x:result')}" />
                        </otherwise>
                     </choose>
                  </variable>

                  <xsl:comment> evaluate the predicate with $x:result as context node if $x:result is a single node; if not, just evaluate the predicate </xsl:comment>
                  <variable name="{x:known-UQName('impl:test-result')}" as="item()*">
                     <choose>
                        <when test="count(${x:known-UQName('impl:test-items')}) eq 1">
                           <for-each select="${x:known-UQName('impl:test-items')}">
                              <sequence select="{ @test }" version="{ $xslt-version }" />
                           </for-each>
                        </when>
                        <otherwise>
                           <sequence select="{ @test }" version="{ $xslt-version }" />
                        </otherwise>
                     </choose>
                  </variable>

                  <!-- TODO: A predicate should always return exactly one boolean, or
                     this is an error.  See issue 5.-->
                  <variable name="{x:known-UQName('impl:boolean-test')}" as="{x:known-UQName('xs:boolean')}"
                     select="${x:known-UQName('impl:test-result')} instance of {x:known-UQName('xs:boolean')}" />

                  <xsl:if test="@href or @select or (node() except x:label)">
                     <if test="${x:known-UQName('impl:boolean-test')}">
                        <message>
                           <xsl:text expand-text="yes">WARNING: {name()} has boolean @test (i.e. assertion) along with @href, @select or child node (i.e. comparison). Comparison factors will be ignored.</xsl:text>
                        </message>
                     </if>
                  </xsl:if>

                  <xsl:comment> did the test pass? </xsl:comment>
                  <variable name="{x:known-UQName('impl:successful')}" as="{x:known-UQName('xs:boolean')}">
                     <choose>
                        <when test="${x:known-UQName('impl:boolean-test')}">
                           <!-- Without boolean(), Saxon warning SXWN9000 (xspec/xspec#46).
                              "cast as" does not work (xspec/xspec#153). -->
                           <sequence select="boolean(${x:known-UQName('impl:test-result')})" />
                        </when>
                        <otherwise>
                           <sequence select="{x:known-UQName('test:deep-equal')}(${x:variable-UQName(.)}, ${x:known-UQName('impl:test-result')}, {$deep-equal-flags})" />
                        </otherwise>
                     </choose>
                  </variable>
               </xsl:when>

               <xsl:otherwise>
                  <variable name="{x:known-UQName('impl:successful')}" as="{x:known-UQName('xs:boolean')}"
                     select="{x:known-UQName('test:deep-equal')}(${x:variable-UQName(.)}, ${x:known-UQName('x:result')}, {$deep-equal-flags})" />
               </xsl:otherwise>
            </xsl:choose>

            <if test="not(${x:known-UQName('impl:successful')})">
               <message>
                  <xsl:text>      FAILED</xsl:text>
               </message>
            </if>
         </xsl:if>

         <!-- <x:test> -->
         <xsl:element name="xsl:element" namespace="{$x:xsl-namespace}">
            <xsl:attribute name="name" select="x:xspec-name('test', .)" />
            <xsl:attribute name="namespace" select="$x:xspec-namespace" />

            <xsl:variable name="test-element-attributes" as="attribute()+">
               <xsl:attribute name="id" select="$expect-id" />
               <xsl:if test="$pending-p">
                  <xsl:sequence select="x:pending-attribute-from-pending-node($pending)" />
               </xsl:if>
            </xsl:variable>
            <xsl:apply-templates select="$test-element-attributes" mode="test:create-node-generator" />

            <xsl:if test="not($pending-p)">
               <!-- @successful must be evaluated at run time -->
               <xsl:element name="xsl:attribute" namespace="{$x:xsl-namespace}">
                  <xsl:attribute name="name" select="'successful'" />
                  <xsl:attribute name="select" select="'$' || x:known-UQName('impl:successful')" />
               </xsl:element>
            </xsl:if>

            <xsl:apply-templates select="x:label(.)" mode="test:create-node-generator" />

            <!-- Report -->
            <xsl:if test="not($pending-p)">
               <xsl:if test="@test">
                  <if test="not(${x:known-UQName('impl:boolean-test')})">
                     <call-template name="{x:known-UQName('test:report-sequence')}">
                        <with-param name="sequence" select="${x:known-UQName('impl:test-result')}" />
                        <with-param name="wrapper-name" as="{x:known-UQName('xs:string')}">
                           <xsl:value-of select="x:xspec-name('result', .)" />
                        </with-param>
                     </call-template>
                  </if>
               </xsl:if>

               <call-template name="{x:known-UQName('test:report-sequence')}">
                  <with-param name="sequence" select="${x:variable-UQName(.)}" />
                  <with-param name="wrapper-name" as="{x:known-UQName('xs:string')}"
                     select="'{name()}'" />

                  <xsl:if test="@test">
                     <with-param name="test-attr" as="attribute(test)">
                        <xsl:apply-templates select="@test" mode="test:create-node-generator" />
                     </with-param>
                     <with-param name="additional-namespaces" as="namespace-node()*">
                        <!-- $test-attr may use namespace prefixes and/or the default namespace such
                           as xs:QName('foo') -->
                        <xsl:apply-templates select="x:element-additional-namespace-nodes(.)"
                           mode="test:create-node-generator" />
                     </with-param>
                  </xsl:if>
               </call-template>
            </xsl:if>

         <!-- </x:test> -->
         </xsl:element>
      </template>
   </xsl:template>

   <!--
      mode="x:param-to-map-entry"
      Transforms x:param to xsl:map-entry
   -->
   <xsl:mode name="x:param-to-map-entry" on-multiple-match="fail" on-no-match="fail" />
   <xsl:template match="x:param" as="element(xsl:map-entry)" mode="x:param-to-map-entry">
      <map-entry key="{x:QName-expression-from-EQName-ignoring-default-ns(@name, .)}">
         <xsl:apply-templates select="." mode="x:param-to-select-attr" />
      </map-entry>
   </xsl:template>

   <!--
      mode="x:param-to-select-attr"
      Transforms x:param to @select which is connected to the generated xsl:variable
   -->
   <xsl:mode name="x:param-to-select-attr" on-multiple-match="fail" on-no-match="fail" />
   <xsl:template match="x:param" as="attribute(select)" mode="x:param-to-select-attr">
      <xsl:attribute name="select" select="'$' || x:variable-UQName(.)" />
   </xsl:template>

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
