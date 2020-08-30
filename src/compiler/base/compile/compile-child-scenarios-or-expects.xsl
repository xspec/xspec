<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
       Drive the compilation of scenarios to either XSLT named
       templates or XQuery functions.
   -->
   <xsl:template name="x:compile-child-scenarios-or-expects">
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="pending" as="node()?" select="(.//@focus)[1]" tunnel="yes"/>

      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:message terminate="yes"
            select="'$this must be a description or a scenario, but is: ' || name()" />
      </xsl:if>
      <xsl:apply-templates select="$this/*[1]" mode="x:compile-scenarios-or-expects">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
      mode="x:compile-scenarios-or-expects"
      Must be "fired" by the named template "x:compile-child-scenarios-or-expects".
      It is a "sibling walking" mode: x:compile-child-scenarios-or-expects applies the template in
      this mode on the first child, then each template rule must apply the template in this same
      mode on the next sibling. The reason for this navigation style is to easily represent variable
      scopes.
   -->
   <xsl:mode name="x:compile-scenarios-or-expects" on-multiple-match="fail" on-no-match="fail" />

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:compile-scenarios-or-expects">
      <xsl:apply-templates select="*[1]" mode="#current">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>

      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

   <!--
       Compile a scenario.
   -->
   <xsl:template match="x:scenario" mode="x:compile-scenarios-or-expects">
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
   <xsl:template match="x:expect" mode="x:compile-scenarios-or-expects">
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
      x:param elements generate actual invocation param's variable.
   -->
   <xsl:template match="x:param" mode="x:compile-scenarios-or-expects">
      <xsl:apply-templates select="." mode="x:declare-variable" />

      <!-- Continue walking the siblings (only other x:param elements, within this x:call or
         x:context). -->
      <xsl:apply-templates select="following-sibling::*[self::x:param][1]" mode="#current"/>
   </xsl:template>

   <!--
      x:variable element adds a variable on the stack (the tunnel param $stacked-variables).
   -->
   <xsl:template match="x:variable" mode="x:compile-scenarios-or-expects">
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
                 mode="x:compile-scenarios-or-expects">
      <!-- Nothing, but must continue the sibling-walking... -->
      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

</xsl:stylesheet>