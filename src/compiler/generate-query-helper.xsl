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
            use="x:resolve-EQName-ignoring-default-ns(@name, .)" />

   <xsl:key name="named-templates" 
            match="xsl:template[@name]"
            use="x:resolve-EQName-ignoring-default-ns(@name, .)" />

   <xsl:key name="matching-templates" 
            match="xsl:template[@match]" 
            use="concat('match=', normalize-space(@match), '+',
                        'mode=', normalize-space(@mode))" />

   <!-- Namespace prefix used privately at run time -->
   <xsl:variable as="xs:string" name="test:private-prefix" select="'local'" />

   <!--
      Generates XQuery variable declaration(s) from the current element.
      
      This mode itself does not handle whitespace-only text nodes specially. To handle
      whitespace-only text node in a special manner, the text node should be handled specially
      before applying this mode and/or mode="test:create-node-generator" should be overridden.
   -->
   <xsl:template match="*" as="node()+" mode="test:generate-variable-declarations">
      <!-- Reflects @pending or x:pending -->
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?" />

      <!-- Name of the variable being declared -->
      <xsl:variable name="name" as="xs:string" select="test:variable-name(.)" />

      <!-- True if the variable being declared is considered pending -->
      <xsl:variable name="is-pending" as="xs:boolean"
         select="self::x:variable
            and not(empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus))" />

      <!-- Child nodes to be excluded -->
      <xsl:variable name="exclude" as="element(x:label)?"
         select="self::x:expect/x:label" />

      <!-- True if the variable should be declared as global -->
      <xsl:variable name="is-global" as="xs:boolean" select="exists(parent::x:description)" />

      <!-- True if the variable should be declared as external.
         TODO: If true, define external variable (which can have a default value in
         XQuery 1.1, but not in 1.0, so we will need to generate an error for global
         x:param with default value...) -->
      <!--<xsl:variable name="is-param" as="xs:boolean" select="self::x:param and $is-global" />-->

      <!-- Name of the temporary runtime variable which holds a document specified by
         child::node() or @href -->
      <xsl:variable name="temp-doc-name" as="xs:string?"
         select="if (not($is-pending) and (node() or @href))
                 then concat($test:private-prefix, ':', local-name(), '-', generate-id(), '-doc')
                 else ()" />

      <!-- Name of the temporary runtime variable which holds the resolved URI of @href -->
      <xsl:variable name="temp-uri-name" as="xs:string?"
         select="if ($temp-doc-name and @href)
                 then concat($test:private-prefix, ':', local-name(), '-', generate-id(), '-uri')
                 else ()" />

      <!--
         Output
            declare variable $TEMPORARYNAME-uri as xs:anyURI := xs:anyURI("RESOLVED-HREF");
         or
                         let $TEMPORARYNAME-uri as xs:anyURI := xs:anyURI("RESOLVED-HREF")
      -->
      <xsl:if test="$temp-uri-name">
         <xsl:call-template name="test:declare-or-let-variable">
            <xsl:with-param name="is-global" select="$is-global" />
            <xsl:with-param name="name" select="$temp-uri-name" />
            <xsl:with-param name="type" select="'xs:anyURI'" />
            <xsl:with-param name="value" as="text()+">
               <xsl:text>xs:anyURI("</xsl:text>
               <xsl:value-of select="resolve-uri(@href, base-uri())" />
               <xsl:text>")</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>

      <!--
         Output
            declare variable $TEMPORARYNAME-doc as document-node() := DOCUMENT;
         or
                         let $TEMPORARYNAME-doc as document-node() := DOCUMENT
         
         where DOCUMENT is
            doc($TEMPORARYNAME-uri)
         or
            document { NODE-GENERATORS }
      -->
      <xsl:if test="$temp-doc-name">
         <xsl:call-template name="test:declare-or-let-variable">
            <xsl:with-param name="is-global" select="$is-global" />
            <xsl:with-param name="name" select="$temp-doc-name" />
            <xsl:with-param name="type" select="'document-node()'" />
            <xsl:with-param name="value" as="node()+">
               <xsl:choose>
                  <xsl:when test="@href">
                     <xsl:text>doc($</xsl:text>
                     <xsl:value-of select="$temp-uri-name" />
                     <xsl:text>)</xsl:text>
                  </xsl:when>

                  <xsl:otherwise>
                     <xsl:text>document { </xsl:text>
                     <xsl:call-template name="test:create-zero-or-more-node-generators">
                        <xsl:with-param name="nodes" select="node() except $exclude" />
                     </xsl:call-template>
                     <xsl:text> }</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>

      <!--
         Output
            declare variable ${$name} as TYPE := SELECTION;
         or
                         let ${$name} as TYPE := SELECTION
         
         where SELECTION is
            ( $TEMPORARYNAME-doc ! ( EXPRESSION ) )
         or
            ( EXPRESSION )
      -->
      <xsl:call-template name="test:declare-or-let-variable">
         <xsl:with-param name="is-global" select="$is-global" />
         <xsl:with-param name="name" select="$name" />
         <xsl:with-param name="type" select="if ($is-pending) then () else (@as)" />
         <xsl:with-param name="value" as="text()+">
            <xsl:choose>
               <xsl:when test="$is-pending">
                  <!-- Do not give variable a value (or type, above) because the value specified
                    in test file might not be executable. -->
                  <xsl:text> </xsl:text>
               </xsl:when>

               <xsl:when test="$temp-doc-name">
                  <xsl:text>$</xsl:text>
                  <xsl:value-of select="$temp-doc-name" />
                  <xsl:text> ! ( </xsl:text>
                  <xsl:value-of select="(@select, '.'[current()/@href], 'node()')[1]" />
                  <xsl:text> )</xsl:text>
               </xsl:when>

               <xsl:otherwise>
                  <xsl:value-of select="(@select, '()')[1]" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
      Returns the variable name generated by mode="test:generate-variable-declarations"
   -->
   <xsl:function as="xs:string" name="test:variable-name">
      <xsl:param as="element()" name="source-element" />

      <xsl:for-each select="$source-element">
         <xsl:choose>
            <xsl:when test="@name">
               <xsl:sequence select="@name" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence
                  select="concat($test:private-prefix, ':', local-name(), '-', generate-id())" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>

   <!--
      Outputs
         declare variable $NAME as TYPE := ( VALUE );
      or
                      let $NAME as TYPE := ( VALUE )
   -->
   <xsl:template name="test:declare-or-let-variable" as="node()+">
      <xsl:context-item use="absent"
         use-when="element-available('xsl:context-item')" />

      <xsl:param name="is-global" as="xs:boolean" required="yes" />
      <xsl:param name="name" as="xs:string" required="yes" />
      <xsl:param name="type" as="xs:string?" required="yes" />
      <xsl:param name="value" as="node()+" required="yes" />

      <xsl:choose>
         <xsl:when test="$is-global">
            <xsl:text>declare variable</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>  let</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text> $</xsl:text>
      <xsl:value-of select="$name" />

      <xsl:if test="$type">
         <xsl:text> as </xsl:text>
         <xsl:value-of select="$type" />
      </xsl:if>

      <xsl:text> := ( </xsl:text>

      <xsl:sequence select="$value" />

      <xsl:text> )</xsl:text>

      <xsl:if test="$is-global">
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
            <xsl:element name="temp" namespace="">
               <xsl:value-of select="." />
            </xsl:element>
         </xsl:when>

         <!-- TODO: TVT
         <xsl:when test="(. instance of text()) and x:is-user-content(.)
            and x:yes-no-synonym(parent::x:text/@expand-text)">
         </xsl:when>
         -->

         <xsl:otherwise>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="replace(., '(&quot;)', '$1$1')" />
            <xsl:text>"</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text> }</xsl:text>
   </xsl:template>

   <!-- x:text represents its child text node -->
   <xsl:template match="x:text" as="node()+" mode="test:create-node-generator">
      <!-- Unwrap -->
      <xsl:apply-templates mode="#current" />
   </xsl:template>

   <xsl:template name="test:create-zero-or-more-node-generators" as="node()+">
      <xsl:context-item use="absent"
         use-when="element-available('xsl:context-item')" />

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
