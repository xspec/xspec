<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!-- Constructs options for transform() -->
   <xsl:template name="x:transform-options" as="element(xsl:variable)">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="call" as="element(x:call)?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" tunnel="yes" />

      <variable name="{x:known-UQName('impl:transform-options')}" as="map({x:known-UQName('xs:string')}, item()*)">
         <map>
            <!--
               Common options
            -->

            <map-entry key="'delivery-format'" select="'raw'" />

            <!-- 'stylesheet-node' might be faster than 'stylesheet-location' when repeated. (Just a guess.
               Haven't tested.) But 'stylesheet-node' disables $x:result?err?line-number on @catch=true. -->
            <map-entry key="'stylesheet-location'">
               <xsl:value-of select="/x:description/@stylesheet" />
            </map-entry>

            <map-entry key="'static-params'">
               <map>
                  <xsl:sequence
                     select="
                        /x:description/x:param[x:yes-no-synonym(@static, false())]
                        ! x:param-to-map-entry(.)" />
               </map>
            </map-entry>
            <map-entry key="'stylesheet-params'">
               <map>
                  <xsl:sequence
                     select="
                        /x:description/x:param[x:yes-no-synonym(@static, false()) => not()]
                        ! x:param-to-map-entry(.)" />
               </map>
            </map-entry>

            <if test="${x:known-UQName('x:saxon-config')} => exists()">
               <!-- Check that the variable appears to be a Saxon configuration -->
               <choose>
                  <when test="${x:known-UQName('x:saxon-config')} instance of element({x:known-UQName('config:configuration')})" />
                  <when test="${x:known-UQName('x:saxon-config')} instance of document-node(element({x:known-UQName('config:configuration')}))" />
                  <otherwise>
                     <message terminate="yes">
                        <!-- Use URIQualifiedName for displaying the $x:saxon-config variable name,
                           for we do not know the name prefix of the originating variable. -->
                        <xsl:text expand-text="yes">ERROR: ${x:known-UQName('x:saxon-config')} does not appear to be a Saxon configuration</xsl:text>
                     </message>
                  </otherwise>
               </choose>

               <!-- cache must be false(): https://saxonica.plan.io/issues/4667 -->
               <map-entry key="'cache'" select="false()" />

               <map-entry key="'vendor-options'">
                  <map>
                     <map-entry key="QName('http://saxon.sf.net/', 'configuration')"
                        select="${x:known-UQName('x:saxon-config')}" />
                  </map>
               </map-entry>
            </if>

            <!--
               Options for call-template invocation and apply-templates invocation
            -->
            <xsl:for-each select="($call[@template], $context)[1]">
               <map-entry key="'template-params'">
                  <map>
                     <xsl:sequence
                        select="
                           x:param[x:yes-no-synonym(@tunnel, false()) => not()]
                           ! x:param-to-map-entry(.)" />
                  </map>
               </map-entry>
               <map-entry key="'tunnel-params'">
                  <map>
                     <xsl:sequence
                        select="
                           x:param[x:yes-no-synonym(@tunnel, false())]
                           ! x:param-to-map-entry(.)" />
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
                           <xsl:for-each select="$call/x:param">
                              <xsl:sort select="xs:integer(@position)" />
                              <xsl:sequence select="x:param-to-select-attr(.)" />
                           </xsl:for-each>
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

   <!--
      Transforms x:param to xsl:map-entry
   -->
   <xsl:function name="x:param-to-map-entry" as="element(xsl:map-entry)">
      <xsl:param name="param" as="element(x:param)" />

      <map-entry key="{$param ! x:QName-expression-from-EQName-ignoring-default-ns(@name, .)}">
         <xsl:sequence select="x:param-to-select-attr($param)" />
      </map-entry>
   </xsl:function>

   <!--
      Transforms x:param to @select which is connected to the generated xsl:variable
   -->
   <xsl:function name="x:param-to-select-attr" as="attribute(select)">
      <xsl:param name="param" as="element(x:param)" />

      <xsl:attribute name="select" select="'$' || x:variable-UQName($param)" />
   </xsl:function>

</xsl:stylesheet>