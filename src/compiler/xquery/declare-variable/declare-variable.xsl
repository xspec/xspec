<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:xquery:declare-variable:declare-variable:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:declare-variable"
      Generates XQuery variable declaration(s) from the current element.
      
      This mode itself does not handle whitespace-only text nodes specially. To handle
      whitespace-only text node in a special manner, the text node should be handled specially
      before applying this mode and/or mode="x:node-constructor" should be overridden.
   -->
   <xsl:mode name="x:declare-variable" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="element()" as="node()+" mode="x:declare-variable">
      <!-- Reflects @pending, x:pending or @focus -->
      <xsl:param name="pending" as="node()?" tunnel="yes" />

      <xsl:param name="comment" as="xs:string?" />

      <!-- XQuery-specific checks -->
      <xsl:call-template name="local:check-xquery-vardecl" />

      <!-- URIQualifiedName of the variable being declared -->
      <xsl:variable name="uqname" as="xs:string" select="x:variable-UQName(.)" />

      <xsl:variable name="pending" as="node()?"
         select="($pending, ancestor::x:scenario/@pending)[1]" />

      <!-- True if the variable being declared is considered pending -->
      <xsl:variable name="is-pending-vardecl" as="xs:boolean"
         select="self::x:variable
            and (exists($pending) and empty(ancestor::x:scenario/@focus))" />

      <!-- Child nodes to be excluded -->
      <xsl:variable name="exclude" as="element(x:label)?"
         select="self::x:expect/x:label" />

      <!-- True if the variable should be declared as global -->
      <xsl:variable name="is-global" as="xs:boolean" select="exists(parent::x:description)" />

      <!-- True if the variable should be declared as external.
         TODO: If true, declare an XQuery external variable. (But it isn't worth implementing.
         External variables are of no use in XSpec.) -->
      <!--<xsl:variable name="is-param" as="xs:boolean" select="self::x:param and $is-global" />-->

      <!-- URIQualifiedName of the temporary runtime variable which holds a document specified by
         child::node() or @href -->
      <xsl:variable name="temp-doc-uqname" as="xs:string?">
         <xsl:if test="not($is-pending-vardecl) and (node() or @href)">
            <xsl:sequence
               select="x:known-UQName('impl:' || local-name() || '-' || generate-id() || '-doc')" />
         </xsl:if>
      </xsl:variable>

      <!--
         Output
            declare variable $TEMPORARYNAME-doc as document-node() := DOCUMENT;
         or
                         let $TEMPORARYNAME-doc as document-node() := DOCUMENT
         
         where DOCUMENT is
            doc('RESOLVED-HREF')
         or
            document { NODE-CONSTRUCTORS }
      -->
      <xsl:if test="$temp-doc-uqname">
         <xsl:call-template name="x:declare-or-let-variable">
            <xsl:with-param name="is-global" select="$is-global" />
            <xsl:with-param name="name" select="$temp-doc-uqname" />
            <xsl:with-param name="type" select="'document-node()'" />
            <xsl:with-param name="value" as="node()+">
               <xsl:choose>
                  <xsl:when test="@href">
                     <xsl:text expand-text="yes">doc({@href => resolve-uri(base-uri()) => x:quote-with-apos()})</xsl:text>
                  </xsl:when>

                  <xsl:otherwise>
                     <xsl:text>document {&#x0A;</xsl:text>
                     <xsl:call-template name="x:zero-or-more-node-constructors">
                        <xsl:with-param name="nodes" select="node() except $exclude" />
                     </xsl:call-template>
                     <xsl:text>&#x0A;</xsl:text>
                     <xsl:text>}</xsl:text>
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
      <xsl:call-template name="x:declare-or-let-variable">
         <xsl:with-param name="is-global" select="$is-global" />
         <xsl:with-param name="name" select="$uqname" />
         <xsl:with-param name="type" select="if ($is-pending-vardecl) then () else (@as)" />
         <xsl:with-param name="value" as="text()?">
            <xsl:choose>
               <xsl:when test="$is-pending-vardecl">
                  <!-- Do not give variable a value (or type, above) because the value specified
                    in test file might not be executable. -->
               </xsl:when>

               <xsl:when test="$temp-doc-uqname">
                  <xsl:variable name="selection" as="xs:string"
                     select="(@select, '.'[current()/@href], 'node()')[1]" />
                  <xsl:text expand-text="yes">${$temp-doc-uqname} ! ( {x:disable-escaping($selection)} )</xsl:text>
               </xsl:when>

               <xsl:when test="@select">
                  <xsl:value-of select="x:disable-escaping(@select)" />
               </xsl:when>
            </xsl:choose>
         </xsl:with-param>
         <xsl:with-param name="comment" select="$comment" />
      </xsl:call-template>
   </xsl:template>

   <!--
      Outputs
         declare variable $NAME as TYPE := ( VALUE );
      or
                      let $NAME as TYPE := ( VALUE )
   -->
   <xsl:template name="x:declare-or-let-variable" as="node()+">
      <xsl:context-item use="absent" />

      <xsl:param name="is-global" as="xs:boolean" required="yes" />
      <xsl:param name="name" as="xs:string" required="yes" />
      <xsl:param name="type" as="xs:string?" required="yes" />
      <xsl:param name="value" as="node()*" required="yes" />
      <xsl:param name="comment" as="xs:string?" />

      <xsl:choose>
         <xsl:when test="$is-global">
            <xsl:text>declare variable</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>let</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text expand-text="yes"> ${$name}</xsl:text>

      <xsl:if test="$type">
         <xsl:text expand-text="yes"> as {$type}</xsl:text>
      </xsl:if>

      <xsl:if test="$comment">
         <xsl:text expand-text="yes"> (:{$comment}:)</xsl:text>
      </xsl:if>

      <xsl:text> := (&#x0A;</xsl:text>

      <xsl:choose>
         <xsl:when test="$value">
            <xsl:sequence select="$value" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>()</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text>&#x0A;)</xsl:text>

      <xsl:if test="$is-global">
         <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <!--
      Local templates
   -->

   <xsl:template name="local:check-xquery-vardecl" as="empty-sequence()">
      <xsl:context-item as="element()" use="required" />

      <!-- Reject x:param if it is analogous to /xsl:stylesheet/xsl:param -->
      <xsl:if test="self::x:param[parent::x:description]">
         <xsl:message terminate="yes">
            <!-- x:combine() removes the name prefix from x:description. That's why URIQualifiedName
               is used. -->
            <xsl:text expand-text="yes">ERROR: {parent::element() => x:node-UQName()} has {name()} (named {@name}), which is not supported for XQuery.</xsl:text>
         </xsl:message>
      </xsl:if>

      <!-- Reject @static=yes -->
      <xsl:if test="x:yes-no-synonym(@static, false())">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">ERROR: Enabling @static in {name()} (named {@name}) is not supported for XQuery.</xsl:text>
         </xsl:message>
      </xsl:if>
   </xsl:template>

</xsl:stylesheet>