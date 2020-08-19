<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:common:report-sequence:local"
                xmlns:rep="urn:x-xspec:common:report-sequence"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:template name="rep:report-sequence" as="element()">
      <xsl:context-item use="absent" />

      <xsl:param name="sequence" as="item()*" required="yes" />
      <xsl:param name="report-name" as="xs:string" required="yes" />
      <xsl:param name="report-namespace" as="xs:string" select="$x:xspec-namespace" />

      <xsl:variable name="attribute-nodes" as="attribute()*"      select="$sequence[. instance of attribute()]" />
      <xsl:variable name="document-nodes"  as="document-node()*"  select="$sequence[. instance of document-node()]" />
      <xsl:variable name="namespace-nodes" as="namespace-node()*" select="$sequence[. instance of namespace-node()]" />
      <xsl:variable name="text-nodes"      as="text()*"           select="$sequence[. instance of text()]" />

      <xsl:variable name="content-wrapper" as="element(content-wrap)">
         <!-- Do not set a prefix in this element name. This prefix-less name undeclares the default
            namespace that pollutes the namespaces in the content. -->
         <xsl:element name="content-wrap" namespace="" />
      </xsl:variable>

      <xsl:variable name="report-element" as="element()">
         <xsl:element name="{$report-name}" namespace="{$report-namespace}">
            <xsl:choose>
               <!-- Empty -->
               <xsl:when test="empty($sequence)">
                  <xsl:attribute name="select" select="'()'" />
               </xsl:when>

               <!-- One or more atomic values -->
               <xsl:when test="$sequence instance of xs:anyAtomicType+">
                  <xsl:attribute name="select"
                     select="
                        ($sequence ! rep:report-atomic-value(.))
                        => string-join(',&#x0A;')" />
               </xsl:when>

               <!-- One or more nodes of the same type which can be a child of document node -->
               <xsl:when
                  test="
                     ($sequence instance of comment()+)
                     or ($sequence instance of element()+)
                     or ($sequence instance of processing-instruction()+)
                     or ($sequence instance of text()+)">
                  <xsl:attribute name="select"
                     select="'/' || x:node-type($sequence[1]) || '()'" />

                  <xsl:copy select="$content-wrapper">
                     <xsl:apply-templates select="$sequence" mode="local:report-node" />
                  </xsl:copy>
               </xsl:when>

               <!-- Single document node -->
               <xsl:when test="$sequence instance of document-node()">
                  <!-- People do not always notice '/' in the report HTML. So express it more verbosely.
                     Also the expression must match the one in ../reporter/format-xspec-report.xsl. -->
                  <xsl:attribute name="select" select="'/self::document-node()'" />

                  <xsl:copy select="$content-wrapper">
                     <xsl:apply-templates select="$sequence" mode="local:report-node" />
                  </xsl:copy>
               </xsl:when>

               <!-- One or more nodes which can be stored in an element safely and without losing each position.
                  Those nodes include document nodes and text nodes. By storing them in an element, they will
                  be unwrapped and/or merged with adjacent nodes. When it happens, the report does not
                  represent the sequence precisely. That's ok, because
                  * Otherwise the report will be cluttered with pseudo elements.
                  * XSpec in general including its deq:deep-equal() inclines to merge them. -->
               <xsl:when
                  test="
                     ($sequence instance of node()+)
                     and not($attribute-nodes or $namespace-nodes)">
                  <xsl:attribute name="select" select="'/node()'" />

                  <xsl:copy select="$content-wrapper">
                     <xsl:apply-templates select="$sequence" mode="local:report-node" />
                  </xsl:copy>
               </xsl:when>

               <!-- Otherwise each item needs to be represented as a pseudo element -->
               <xsl:otherwise>
                  <xsl:attribute name="select">
                     <!-- Select the pseudo elements -->
                     <xsl:text>/*</xsl:text>

                     <xsl:choose>
                        <!-- If all items are instance of node, they can be expressed in @select.
                           (Document nodes are unwrapped, though.) -->
                        <xsl:when test="$sequence instance of node()+">
                           <xsl:variable name="expressions" as="xs:string+"
                              select="
                                 '@*'[$attribute-nodes],
                                 'namespace::*'[$namespace-nodes],
                                 'node()'[$sequence except ($attribute-nodes | $namespace-nodes)]" />
                           <xsl:variable name="multi-expr" as="xs:boolean"
                              select="count($expressions) ge 2" />

                           <xsl:text>/</xsl:text>
                           <xsl:if test="$multi-expr">
                              <xsl:text>(</xsl:text>
                           </xsl:if>
                           <xsl:value-of select="$expressions" separator=" | " />
                           <xsl:if test="$multi-expr">
                              <xsl:text>)</xsl:text>
                           </xsl:if>
                        </xsl:when>

                        <xsl:otherwise>
                           <!-- Not all items can be expressed in @select. Just leave the pseudo elements selected. -->
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:attribute>

                  <xsl:copy select="$content-wrapper">
                     <xsl:sequence
                        select="$sequence ! local:report-pseudo-item(., $report-namespace)" />
                  </xsl:copy>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:variable>

      <!-- Output the report element -->
      <xsl:choose>
         <!-- If too many nodes, save the report element as an external doc -->
         <xsl:when test="count($report-element/descendant-or-self::node()) ge 1000">
            <!-- URI of the external file.
               Ensure that each report outputs to a unique URI (expath/xspec#67). -->
            <xsl:variable name="href" as="xs:string"
               select="'result-' || generate-id($report-element) || '.xml'" />

            <!-- Save the report element as the external file.
               You can't unwrap the report element, because not all nodes can be located in the document root. -->
            <!-- Use @format to avoid clashes with <xsl:output> in another stylesheet which would
               otherwise govern the output of the external file. -->
            <xsl:result-document href="{$href}" format="x:xml-report-serialization-parameters">
               <xsl:sequence select="$report-element" />
            </xsl:result-document>

            <!-- Alter the report element, discarding its stale @select -->
            <xsl:copy select="$report-element">
               <xsl:sequence select="attribute() except @select" />
               <xsl:attribute name="href" select="$href" />
            </xsl:copy>
         </xsl:when>

         <!-- Not too many nodes. Just output the report element as is. -->
         <xsl:otherwise>
            <xsl:sequence select="$report-element" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:function name="local:report-pseudo-item" as="element()">
      <xsl:param name="item" as="item()" />
      <xsl:param name="report-namespace" as="xs:string" />

      <xsl:variable name="local-name-prefix" as="xs:string" select="'pseudo-'" />

      <xsl:choose>
         <xsl:when test="$item instance of xs:anyAtomicType">
            <xsl:element name="{$local-name-prefix}atomic-value" namespace="{$report-namespace}">
               <xsl:value-of select="rep:report-atomic-value($item)" />
            </xsl:element>
         </xsl:when>

         <xsl:when test="$item instance of node()">
            <xsl:element name="{$local-name-prefix}{x:node-type($item)}" namespace="{$report-namespace}">
               <xsl:choose>
                  <!-- Can't apply templates to namespace nodes -->
                  <xsl:when test="$item instance of namespace-node()">
                     <xsl:sequence select="$item" />
                  </xsl:when>

                  <xsl:otherwise>
                     <xsl:apply-templates select="$item" mode="local:report-node" />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:element>
         </xsl:when>

         <xsl:when test="x:instance-of-function($item)">
            <xsl:element name="{$local-name-prefix}{x:function-type($item)}"
               namespace="{$report-namespace}">
               <xsl:value-of select="local:serialize-adaptive($item)" />
            </xsl:element>
         </xsl:when>

         <xsl:otherwise>
            <xsl:element name="{$local-name-prefix}other" namespace="{$report-namespace}" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <!--
      mode="local:report-node"
      Copies the nodes while wrapping whitespace-only text nodes in <x:ws>.
      You can't use @on-no-match="shallow-copy", because SUT may have xsl:template[@mode="#all"].
   -->
   <xsl:mode name="local:report-node" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="document-node() | attribute() | node()" as="node()"
      mode="local:report-node">
      <xsl:call-template name="x:identity" />
   </xsl:template>

   <xsl:template match="text()[normalize-space() => not()]" as="element(x:ws)"
      mode="local:report-node">
      <xsl:element name="ws" namespace="{$x:xspec-namespace}">
         <xsl:sequence select="." />
      </xsl:element>
   </xsl:template>

   <!--
      This function should be local:. But ../../test/report-sequence.xspec requires this to be
      exposed.
   -->
   <xsl:function name="rep:report-atomic-value" as="xs:string">
      <xsl:param name="value" as="xs:anyAtomicType" />

      <xsl:choose>
         <!-- Derived types must be handled before their base types -->

         <!-- String types -->
         <xsl:when test="$value instance of xs:normalizedString"
            use-when="type-available('xs:normalizedString')">
            <xsl:sequence select="local:report-atomic-value-as-constructor($value)" />
         </xsl:when>
         <xsl:when test="$value instance of xs:string">
            <xsl:sequence select="x:quote-with-apos($value)" />
         </xsl:when>

         <!-- Derived numeric types -->
         <xsl:when test="$value instance of xs:nonPositiveInteger"
            use-when="type-available('xs:nonPositiveInteger')">
            <xsl:sequence select="local:report-atomic-value-as-constructor($value)" />
         </xsl:when>
         <xsl:when test="$value instance of xs:long" use-when="type-available('xs:long')">
            <xsl:sequence select="local:report-atomic-value-as-constructor($value)" />
         </xsl:when>
         <xsl:when test="$value instance of xs:nonNegativeInteger"
            use-when="type-available('xs:nonNegativeInteger')">
            <xsl:sequence select="local:report-atomic-value-as-constructor($value)" />
         </xsl:when>

         <!-- Numeric types which can be expressed as numeric literals:
            http://www.w3.org/TR/xpath20/#id-literals -->
         <xsl:when test="$value instance of xs:integer">
            <xsl:sequence select="string($value)" />
         </xsl:when>
         <xsl:when test="$value instance of xs:decimal">
            <xsl:sequence select="x:decimal-string($value)" />
         </xsl:when>
         <xsl:when test="$value instance of xs:double">
            <xsl:sequence
               select="
                  if (string($value) = ('NaN', 'INF', '-INF')) then
                     local:report-atomic-value-as-constructor($value)
                  else
                     local:serialize-adaptive($value)" />
         </xsl:when>

         <xsl:when test="$value instance of xs:QName">
            <xsl:sequence select="x:QName-expression($value)" />
         </xsl:when>

         <xsl:otherwise>
            <xsl:sequence select="local:report-atomic-value-as-constructor($value)" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="local:report-atomic-value-as-constructor" as="xs:string">
      <xsl:param name="value" as="xs:anyAtomicType" />

      <!-- Constructor usually has the same name as type -->
      <xsl:variable name="constructor-name" as="xs:string" select="rep:atom-type($value)" />

      <!-- Cast as either xs:integer or xs:string -->
      <xsl:variable name="casted-value" as="xs:anyAtomicType">
         <xsl:choose>
            <xsl:when test="$value instance of xs:integer">
               <!-- Force casting down to integer, by first converting to string -->
               <xsl:sequence select="string($value) cast as xs:integer" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="string($value)" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <!-- Constructor parameter:
         Either numeric literal of integer or string literal -->
      <xsl:variable name="costructor-param" as="xs:string"
         select="rep:report-atomic-value($casted-value)" />

      <xsl:sequence select="$constructor-name || '(' || $costructor-param || ')'" />
   </xsl:function>

   <!--
      This function should be local:. But ../../test/report-sequence.xspec requires this to be
      exposed.
   -->
   <xsl:function name="rep:atom-type" as="xs:string">
      <xsl:param name="value" as="xs:anyAtomicType" />

      <xsl:variable name="local-name" as="xs:string">
         <xsl:choose>
            <!-- Grouped as the spec does: http://www.w3.org/TR/xslt20/#built-in-types
               Groups are in the reversed order so that the derived types are before the primitive types,
               otherwise xs:integer is recognised as xs:decimal, xs:yearMonthDuration as xs:duration, and so on. -->

            <!-- A schema-aware XSLT processor additionally supports: -->

            <!--    * All other built-in types defined in [XML Schema Part 2] -->
            <!-- xs:IDREFS: list -->
            <!-- xs:ENTITIES: list -->
            <xsl:when test="$value instance of xs:ID" use-when="type-available('xs:ID')">ID</xsl:when>
            <xsl:when test="$value instance of xs:IDREF" use-when="type-available('xs:IDREF')">IDREF</xsl:when>
            <xsl:when test="$value instance of xs:ENTITY" use-when="type-available('xs:ENTITY')">ENTITY</xsl:when>
            <xsl:when test="$value instance of xs:NCName" use-when="type-available('xs:NCName')">NCName</xsl:when>
            <!-- xs:NMTOKENS: list -->
            <xsl:when test="$value instance of xs:language" use-when="type-available('xs:language')">language</xsl:when>
            <xsl:when test="$value instance of xs:Name" use-when="type-available('xs:Name')">Name</xsl:when>
            <xsl:when test="$value instance of xs:NMTOKEN" use-when="type-available('xs:NMTOKEN')">NMTOKEN</xsl:when>
            <xsl:when test="$value instance of xs:token" use-when="type-available('xs:token')">token</xsl:when>
            <xsl:when test="$value instance of xs:normalizedString" use-when="type-available('xs:normalizedString')">normalizedString</xsl:when>
            <xsl:when test="$value instance of xs:negativeInteger" use-when="type-available('xs:negativeInteger')">negativeInteger</xsl:when>
            <xsl:when test="$value instance of xs:nonPositiveInteger" use-when="type-available('xs:nonPositiveInteger')">nonPositiveInteger</xsl:when>
            <xsl:when test="$value instance of xs:byte" use-when="type-available('xs:byte')">byte</xsl:when>
            <xsl:when test="$value instance of xs:short" use-when="type-available('xs:short')">short</xsl:when>
            <xsl:when test="$value instance of xs:int" use-when="type-available('xs:int')">int</xsl:when>
            <xsl:when test="$value instance of xs:long" use-when="type-available('xs:long')">long</xsl:when>
            <xsl:when test="$value instance of xs:unsignedByte" use-when="type-available('xs:unsignedByte')">unsignedByte</xsl:when>
            <xsl:when test="$value instance of xs:unsignedShort" use-when="type-available('xs:unsignedShort')">unsignedShort</xsl:when>
            <xsl:when test="$value instance of xs:unsignedInt" use-when="type-available('xs:unsignedInt')">unsignedInt</xsl:when>
            <xsl:when test="$value instance of xs:unsignedLong" use-when="type-available('xs:unsignedLong')">unsignedLong</xsl:when>
            <xsl:when test="$value instance of xs:positiveInteger" use-when="type-available('xs:positiveInteger')">positiveInteger</xsl:when>
            <xsl:when test="$value instance of xs:nonNegativeInteger" use-when="type-available('xs:nonNegativeInteger')">nonNegativeInteger</xsl:when>
            <!-- xs:NOTATION: Abstract -->

            <!-- Every XSLT 2.0 processor includes the following named type definitions in the in-scope schema components: -->

            <!--    * The following types defined in [XPath 2.0] -->
            <xsl:when test="$value instance of xs:yearMonthDuration">yearMonthDuration</xsl:when>
            <xsl:when test="$value instance of xs:dayTimeDuration">dayTimeDuration</xsl:when>
            <!-- xs:anyAtomicType: Abstract -->
            <!-- xs:untyped: Not atomic -->
            <xsl:when test="$value instance of xs:untypedAtomic">untypedAtomic</xsl:when>

            <!--    * The types xs:anyType and xs:anySimpleType. -->
            <!-- Not atomic -->

            <!--    * The derived atomic type xs:integer defined in [XML Schema Part 2]. -->
            <xsl:when test="$value instance of xs:integer">integer</xsl:when>

            <!--    * All the primitive atomic types defined in [XML Schema Part 2], with the exception of xs:NOTATION. -->
            <xsl:when test="$value instance of xs:string">string</xsl:when>
            <xsl:when test="$value instance of xs:boolean">boolean</xsl:when>
            <xsl:when test="$value instance of xs:decimal">decimal</xsl:when>
            <xsl:when test="$value instance of xs:double">double</xsl:when>
            <xsl:when test="$value instance of xs:float">float</xsl:when>
            <xsl:when test="$value instance of xs:date">date</xsl:when>
            <xsl:when test="$value instance of xs:time">time</xsl:when>
            <xsl:when test="$value instance of xs:dateTime">dateTime</xsl:when>
            <xsl:when test="$value instance of xs:duration">duration</xsl:when>
            <xsl:when test="$value instance of xs:QName">QName</xsl:when>
            <xsl:when test="$value instance of xs:anyURI">anyURI</xsl:when>
            <xsl:when test="$value instance of xs:gDay">gDay</xsl:when>
            <xsl:when test="$value instance of xs:gMonthDay">gMonthDay</xsl:when>
            <xsl:when test="$value instance of xs:gMonth">gMonth</xsl:when>
            <xsl:when test="$value instance of xs:gYearMonth">gYearMonth</xsl:when>
            <xsl:when test="$value instance of xs:gYear">gYear</xsl:when>
            <xsl:when test="$value instance of xs:base64Binary">base64Binary</xsl:when>
            <xsl:when test="$value instance of xs:hexBinary">hexBinary</xsl:when>

            <xsl:otherwise>anyAtomicType</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:sequence select="x:known-UQName('xs:' || $local-name)" />
   </xsl:function>

   <xsl:function name="local:serialize-adaptive" as="xs:string">
      <xsl:param name="item" as="item()" />

      <xsl:sequence
         select="
            serialize(
               $item,
               map {
                  'indent': true(),
                  'method': 'adaptive'
               }
            )" />
   </xsl:function>

</xsl:stylesheet>