<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-query-helper.xsl                                -->
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
                exclude-result-prefixes="#all"
                extension-element-prefixes="test">
  
   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-query-helper.xsl</pkg:import-uri>

   <xsl:key name="functions" 
            match="xsl:function" 
            use="resolve-QName(@name, .)"/>

   <xsl:key name="named-templates" 
            match="xsl:template[@name]"
            use="if ( contains(@name, ':') ) then
                   resolve-QName(@name, .)
                 else
                   QName('', @name)"/>

   <xsl:key name="matching-templates" 
            match="xsl:template[@match]" 
            use="concat('match=', normalize-space(@match), '+',
                        'mode=', normalize-space(@mode))"/>

   <xsl:template match="*" as="node()+" mode="test:generate-variable-declarations">
      <xsl:param name="var"    as="xs:string"  required="yes"/>
      <xsl:param name="global" as="xs:boolean" select="false()"/>
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:variable name="variable_is_pending" as="xs:boolean"
         select="self::x:variable and not(empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus))"/>
      <xsl:choose>
         <xsl:when test="$global">
            <xsl:text>declare variable $</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>  let $</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$var"/>
      <xsl:if test="@as and not($variable_is_pending)"><!-- 2nd part avoids data type error for pending var with empty definition -->
         <xsl:text> as </xsl:text>
         <xsl:value-of select="@as"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$variable_is_pending">
            <!-- Do not give variable a value (or @as, above) because the value specified in test file might not be executable. -->
            <xsl:text> := ()</xsl:text>
         </xsl:when>
         <xsl:when test="@href">
            <xsl:text> := doc('</xsl:text>
            <xsl:value-of select="resolve-uri(@href, base-uri(.))"/>
            <xsl:text>')</xsl:text>
            <xsl:if test="@select">/( <xsl:value-of select="@select"/> )</xsl:if>
         </xsl:when>
         <xsl:when test="node()">
            <xsl:text> := ( document {</xsl:text>
            <xsl:call-template name="test:create-zero-or-more-node-generators">
               <xsl:with-param name="nodes" select="node()" />
            </xsl:call-template>
            <xsl:text>} )/</xsl:text>
            <xsl:choose>
               <xsl:when test="@select">( <xsl:value-of select="@select"/> )</xsl:when>
               <xsl:otherwise>node()</xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="@select">
            <xsl:text> := ( </xsl:text>
            <xsl:value-of select="@select"/>
            <xsl:text> )</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text> := ()</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$global">
         <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="element()" as="element()" mode="test:create-node-generator">
      <xsl:copy>
         <xsl:text>{ </xsl:text>
         <xsl:call-template name="test:create-zero-or-more-node-generators">
            <xsl:with-param name="nodes" select="attribute() | node()" />
         </xsl:call-template>
         <xsl:text> }&#x0A;</xsl:text>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="attribute() | comment() | processing-instruction() | text()"
      as="node()+" mode="test:create-node-generator">
      <xsl:value-of select="x:node-type(.), name()" />
      <xsl:text> { </xsl:text>

      <xsl:choose>
         <xsl:when test="(. instance of attribute()) and x:is-user-content(.)">
            <!-- AVT -->
            <temp>
               <xsl:value-of select="." />
            </temp>
         </xsl:when>

         <xsl:otherwise>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="replace(., '(&quot;)', '$1$1')" />
            <xsl:text>"</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template name="test:create-zero-or-more-node-generators" as="node()+">
      <xsl:param name="nodes" as="node()*" />

      <xsl:choose>
         <xsl:when test="$nodes">
            <xsl:for-each select="$nodes">
               <xsl:apply-templates select="." mode="test:create-node-generator" />
               <xsl:if test="position() ne last()">
                  <xsl:text>,&#x0A;</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>

         <xsl:otherwise>
            <xsl:text>()</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:function name="test:matching-xslt-elements" as="element()*">
     <xsl:param name="element-kind" as="xs:string" />
     <xsl:param name="element-id" as="item()" />
     <xsl:param name="stylesheet" as="document-node()" />
     <xsl:sequence select="key($element-kind, $element-id, $stylesheet)" />
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
