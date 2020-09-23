<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:compile:compile-child-scenarios-or-expects:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Drive the compilation of (child::x:scenario | child::x:expect) to either XSLT named templates
      or XQuery functions, taking x:pending into account.
   -->
   <xsl:template name="x:compile-child-scenarios-or-expects" as="node()*">
      <!-- Context item is x:description or x:scenario -->
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="pending" as="node()?" select="(.//@focus)[1]" tunnel="yes"/>

      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:message terminate="yes"
            select="'$this must be a description or a scenario, but is: ' || name()" />
      </xsl:if>

      <xsl:apply-templates select="$this/element()" mode="local:compile-scenarios-or-expects">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      mode="local:compile-scenarios-or-expects"
      Must be "fired" by the named template "x:compile-child-scenarios-or-expects".
   -->
   <xsl:mode name="local:compile-scenarios-or-expects" on-multiple-match="fail"
      on-no-match="deep-skip" />

   <!--
      At x:pending elements, we switch the $pending tunnel param value for children.
   -->
   <xsl:template match="x:pending" as="node()+" mode="local:compile-scenarios-or-expects">
      <xsl:apply-templates select="element()" mode="#current">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      Compile x:scenario.
   -->
   <xsl:template match="x:scenario" as="node()+" mode="local:compile-scenarios-or-expects">
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

      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template -->
      <xsl:call-template name="x:compile-scenario">
         <xsl:with-param name="pending"   select="$new-pending" tunnel="yes"/>
         <xsl:with-param name="apply"     select="$new-apply"   tunnel="yes"/>
         <xsl:with-param name="call"      select="$new-call"    tunnel="yes"/>
         <xsl:with-param name="context"   select="$new-context" tunnel="yes"/>
      </xsl:call-template>
   </xsl:template>

   <!--
      Compile x:expect.
   -->
   <xsl:template match="x:expect" as="node()+" mode="local:compile-scenarios-or-expects">
      <xsl:param name="pending" as="node()?" tunnel="yes" />
      <xsl:param name="context" as="element(x:context)?" required="yes" tunnel="yes" />
      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />

      <!-- Dispatch to a language-specific (XSLT or XQuery) worker template -->
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
            <xsl:sequence select="accumulator-before('stacked-variables-distinct-uqnames')" />
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

</xsl:stylesheet>