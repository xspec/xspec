<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-tests-utils.xsl                                 -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="2.0"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                extension-element-prefixes="test">

<pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-tests-utils.xsl</pkg:import-uri>

<!-- TODO: ... -->
<xsl:param name="debug" as="xs:boolean" select="true()"/>

<!-- Generate an human-readable path to a node within its document. -->
<xsl:function name="x:node-path" as="xs:string">
   <xsl:param name="n" as="node()"/>
   <!-- TODO: In case of a root document node, the path begins with '//'... -->
   <xsl:sequence select="string-join($n/ancestor-or-self::node()/x:node-step(.), '/')"/>
</xsl:function>

<xsl:function name="x:node-step" as="xs:string">
   <xsl:param name="n" as="node()"/>
   <xsl:choose>
      <xsl:when test="$n instance of document-node()">
         <xsl:sequence select="'/'"/>
      </xsl:when>
      <xsl:when test="$n instance of element()">
         <xsl:variable name="precedings" select="
             $n/preceding-sibling::*[name(.) eq name($n)]"/>
         <xsl:sequence select="concat(name($n), x:node-position($precedings))"/>
      </xsl:when>
      <xsl:when test="$n instance of attribute()">
         <xsl:sequence select="concat('@', name($n))"/>
      </xsl:when>
      <xsl:when test="$n instance of text()">
         <xsl:variable name="precedings" select="
             $n/preceding-sibling::text()"/>
         <xsl:sequence select="concat('text()', x:node-position($precedings))"/>
      </xsl:when>
      <xsl:when test="$n instance of comment()">
         <xsl:variable name="precedings" select="
             $n/preceding-sibling::comment()"/>
         <xsl:sequence select="concat('comment()', x:node-position($precedings))"/>
      </xsl:when>
      <xsl:when test="$n instance of processing-instruction()">
         <xsl:variable name="precedings" select="
             $n/preceding-sibling::processing-instruction[name(.) eq name($n)]"/>
         <xsl:sequence select="concat('pi(', name($n), ')', x:node-position($precedings))"/>
      </xsl:when>
      <!-- if not, that's a namespace node -->
      <xsl:otherwise>
         <xsl:sequence select="concat('ns({', name($n), '}', $n, ')')"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:function>

<xsl:function name="x:node-position" as="xs:string?">
   <xsl:param name="precedings" as="node()*"/>
   <xsl:if test="exists($precedings)">
      <xsl:sequence select="concat('[', count($precedings) + 1, ']')"/>
   </xsl:if>
</xsl:function>

<!-- $flags
  w : Ignores descendant whitespace-only text nodes except the ones in <test:ws>
  1 : Simulates XSLT version 1.0 -->
<xsl:function name="test:deep-equal" as="xs:boolean">
  <xsl:param name="seq1" as="item()*"/>
  <xsl:param name="seq2" as="item()*"/>
  <xsl:param name="flags" as="xs:string" />

  <!-- Using a $param in @use-when does not work.  TODO: What to do? At run time? -->
  <!--xsl:if test="$seq1 instance of node()" use-when="$debug">
     <xsl:message select="'DEEP-EQUAL: SEQ1:', x:node-path($seq1)"/>
  </xsl:if>
  <xsl:if test="$seq2 instance of node()" use-when="$debug">
     <xsl:message select="'DEEP-EQUAL: SEQ2:', x:node-path($seq2)"/>
  </xsl:if-->
  <xsl:variable name="result" as="xs:boolean">
     <xsl:choose>
        <xsl:when test="contains($flags, '1')">
           <xsl:variable name="flags" as="xs:string" select="translate($flags, '1', '')" />
           <xsl:choose>
              <xsl:when test="$seq1 instance of xs:string and
                              $seq2 instance of text()+">
                 <xsl:sequence select="test:deep-equal($seq1, string-join($seq2, ''), $flags)"/>
              </xsl:when>
              <xsl:when test="$seq1 instance of xs:double and
                              $seq2 instance of text()+">
                 <xsl:sequence select="test:deep-equal($seq1, xs:double(string-join($seq2, '')), $flags)"/>
              </xsl:when>
              <xsl:when test="$seq1 instance of xs:decimal and
                              $seq2 instance of text()+">
                 <xsl:sequence select="test:deep-equal($seq1, xs:decimal(string-join($seq2, '')), $flags)"/>
              </xsl:when>
              <xsl:when test="$seq1 instance of xs:integer and
                              $seq2 instance of text()+">
                 <xsl:sequence select="test:deep-equal($seq1, xs:integer(string-join($seq2, '')), $flags)"/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:sequence select="test:deep-equal($seq1, $seq2, $flags)"/>
              </xsl:otherwise>
           </xsl:choose>
        </xsl:when>
        <xsl:when test="empty($seq1) or empty($seq2)">
           <xsl:sequence select="empty($seq1) and empty($seq2)"/>
        </xsl:when>
        <xsl:when test="count($seq1) = count($seq2)">
           <xsl:sequence select="every $i in (1 to count($seq1)) 
                                 satisfies test:item-deep-equal($seq1[$i], $seq2[$i], $flags)"/>
        </xsl:when>
        <xsl:when test="$seq1 instance of text() and
                        $seq2 instance of text()+">
           <xsl:variable name="seq2" as="text()">
              <xsl:value-of select="$seq2" separator=""/>
           </xsl:variable>
           <xsl:sequence select="test:deep-equal($seq1, $seq2, $flags)"/>
        </xsl:when>
        <xsl:when test="test:wrappable-sequence($seq1) and test:wrappable-sequence($seq2)">
           <xsl:variable name="seq1doc" as="document-node()" select="test:wrap-nodes($seq1)" />
           <xsl:variable name="seq2doc" as="document-node()" select="test:wrap-nodes($seq2)" />
           <xsl:choose>
              <xsl:when test="count($seq1doc/node()) != count($seq1) or count($seq2doc/node()) != count($seq2)">
                 <xsl:sequence select="test:deep-equal($seq1doc/node(), $seq2doc/node(), $flags)"/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:sequence select="false()"/>
              </xsl:otherwise>
           </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
           <xsl:sequence select="false()"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <!-- Using a $param in @use-when does not work.  TODO: What to do? At run time? -->
  <!--xsl:message select="'DEEP-EQUAL: RESULT:', $result" use-when="$debug"/-->
  <xsl:sequence select="$result"/>
</xsl:function>

<xsl:function name="test:item-deep-equal" as="xs:boolean">
  <xsl:param name="item1" as="item()" />
  <xsl:param name="item2" as="item()" />
  <xsl:param name="flags" as="xs:string" />

  <xsl:choose>
    <xsl:when test="$item1 instance of node() and
                    $item2 instance of node()">
      <xsl:sequence select="test:node-deep-equal($item1, $item2, $flags)" />
    </xsl:when>
    <xsl:when test="not($item1 instance of node()) and
                    not($item2 instance of node())">
      <xsl:sequence select="deep-equal($item1, $item2)" />      
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>  

<xsl:function name="test:node-deep-equal" as="xs:boolean">
  <xsl:param name="node1" as="node()" />
  <xsl:param name="node2" as="node()" />
  <xsl:param name="flags" as="xs:string" />

  <xsl:choose>
    <xsl:when test="$node1 instance of document-node() and
                    $node2 instance of document-node()">
      <xsl:variable name="children1" as="node()*" 
        select="test:sorted-children($node1, $flags)" />
      <xsl:variable name="children2" as="node()*" 
        select="test:sorted-children($node2, $flags)" />
      <xsl:sequence select="test:deep-equal($children1,
                                            $children2,
                                            $flags)" />
    </xsl:when>
    <xsl:when test="$node1 instance of element() and
                    $node2 instance of element()">
      <xsl:choose>
        <xsl:when test="node-name($node1) eq node-name($node2)">
          <xsl:variable name="atts1" as="attribute()*">
            <xsl:perform-sort select="$node1/@*">
              <xsl:sort select="namespace-uri(.)" />
              <xsl:sort select="local-name(.)" />
            </xsl:perform-sort>
          </xsl:variable>
          <xsl:variable name="atts2" as="attribute()*">
            <xsl:perform-sort select="$node2/@*">
              <xsl:sort select="namespace-uri(.)" />
              <xsl:sort select="local-name(.)" />
            </xsl:perform-sort>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="test:deep-equal($atts1, $atts2, $flags)">
              <xsl:choose>
                <xsl:when test="$node1/text() = '...' and count($node1/node()) = 1">
                  <xsl:sequence select="true()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="children1" as="node()*" 
                    select="test:sorted-children($node1, $flags)" />
                  <xsl:variable name="children2" as="node()*" 
                    select="test:sorted-children($node2, $flags)" />
                  <xsl:sequence select="test:deep-equal($children1,
                                                        $children2,
                                                        $flags)" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="false()" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$node1 instance of text() and
                    $node1 = '...'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$node1 instance of text() and
                    $node2 instance of text()">
      <!--
      <xsl:choose>
        <xsl:when test="not(normalize-space($node1)) and 
                        not(normalize-space($node2))">
          <xsl:sequence select="true()" />
        </xsl:when>
        <xsl:otherwise>
      -->
          <xsl:sequence select="string($node1) eq string($node2)" />
        <!--
        </xsl:otherwise>
      </xsl:choose>
      -->
    </xsl:when>
    <xsl:when test="($node1 instance of attribute() and
                     $node2 instance of attribute()) or
                    ($node1 instance of processing-instruction() and
                     $node2 instance of processing-instruction()) or
                    (x:instance-of-namespace($node1) and
                     x:instance-of-namespace($node2))">
      <xsl:sequence select="deep-equal(node-name($node1), node-name($node2)) and
                            (string($node1) eq string($node2) or string($node1) = '...')" />      

    </xsl:when>
    <xsl:when test="$node1 instance of comment() and
                    $node2 instance of comment()">
      <xsl:sequence select="string($node1) eq string($node2) or string($node1) = '...'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>  
</xsl:function>
  
<xsl:function name="test:sorted-children" as="node()*">
  <xsl:param name="node" as="node()" />
  <xsl:param name="flags" as="xs:string" />

  <xsl:sequence 
    select="$node/child::node() 
            except ($node/text()[not(normalize-space())][contains($flags, 'w')][not($node/self::test:ws)],
                    $node/test:message)" />
</xsl:function>
  
<xsl:template name="test:report-sequence" as="element()">
  <xsl:context-item use="absent"
    use-when="element-available('xsl:context-item')" />

  <xsl:param name="sequence" as="item()*" required="yes" />
  <xsl:param name="wrapper-name" as="xs:string" required="yes" />
  <xsl:param name="wrapper-ns" as="xs:string" select="'http://www.jenitennison.com/xslt/xspec'" />
  <xsl:param name="test" as="attribute(test)?" />

  <xsl:variable name="attribute-nodes" as="attribute()*"     select="$sequence[. instance of attribute()]" />
  <xsl:variable name="document-nodes"  as="document-node()*" select="$sequence[. instance of document-node()]" />
  <xsl:variable name="namespace-nodes" as="node()*"          select="$sequence[x:instance-of-namespace(.)]" />
  <xsl:variable name="text-nodes"      as="text()*"          select="$sequence[. instance of text()]" />

  <xsl:variable name="report-element" as="element()">
    <xsl:element name="{$wrapper-name}" namespace="{$wrapper-ns}">
      <xsl:sequence select="$test" />

      <xsl:choose>
        <!-- Empty -->
        <xsl:when test="empty($sequence)">
          <xsl:attribute name="select" select="'()'" />
        </xsl:when>

        <!-- One or more atomic values -->
        <xsl:when test="$sequence instance of xs:anyAtomicType+">
          <xsl:variable as="xs:string+" name="atomic-value-reports"
            select="for $value in $sequence return test:report-atomic-value($value)" />
          <xsl:attribute name="select" select="string-join($atomic-value-reports, ', ')" />
        </xsl:when>

        <!-- One or more nodes of the same type which can be a child of document node -->
        <xsl:when test="
          ($sequence instance of comment()+)
          or ($sequence instance of element()+)
          or ($sequence instance of processing-instruction()+)
          or ($sequence instance of text()+)">
          <xsl:attribute name="select" select="concat('/', x:node-type($sequence[1]), '()')" />
          <xsl:apply-templates select="$sequence" mode="test:report-node" />
        </xsl:when>

        <!-- Single document node -->
        <xsl:when test="$sequence instance of document-node()">
          <!-- People do not always notice '/' in the report HTML. So express it more verbosely.
            Also the expression must match the one in ../reporter/format-xspec-report.xsl. -->
          <xsl:attribute name="select" select="'/self::document-node()'" />
          <xsl:apply-templates select="$sequence" mode="test:report-node" />
        </xsl:when>

        <!-- One or more nodes which can be stored in an element safely and without losing each position.
          Those nodes include document nodes and text nodes. By storing them in an element, they will
          be unwrapped and/or merged with adjacent nodes. When it happens, the report does not
          represent the sequence precisely. That's ok, because
            * Otherwise the report will be cluttered with pseudo elements.
            * XSpec in general including its test:deep-equal() inclines to merge them. -->
        <xsl:when test="($sequence instance of node()+) and not($attribute-nodes or $namespace-nodes)">
          <xsl:attribute name="select" select="'/node()'" />
          <xsl:apply-templates select="$sequence" mode="test:report-node" />
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
                <xsl:variable name="expressions" as="xs:string+" select="
                  '@*'[$attribute-nodes],
                  'namespace::*'[$namespace-nodes],
                  'node()'[$sequence except ($attribute-nodes | $namespace-nodes)]" />
                <xsl:variable name="multi-expr" as="xs:boolean" select="count($expressions) ge 2" />

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

          <xsl:sequence select="
            for $item in $sequence
            return test:report-pseudo-item($item, $wrapper-ns)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:variable>

  <!-- Output the report element -->
  <xsl:choose>
    <!-- If too many nodes, save the report element as an external doc -->
    <xsl:when test="count($report-element/descendant-or-self::node()) ge 1000">
      <!-- Ensure that a unique file name is generated by creating a copy of the result (expath/xspec#67). -->
      <xsl:variable name="sequence-copy">
        <xsl:copy-of select="$sequence" />
      </xsl:variable>

      <!-- URI of the external file -->
      <xsl:variable name="href" as="xs:string" select="concat('result-', generate-id($sequence-copy[1]), '.xml')" />

      <!-- Save the report element as the external file.
        You can't unwrap the report element, because not all nodes can be located in the document root. -->
      <xsl:result-document href="{$href}" format="x:report">
        <xsl:sequence select="$report-element" />
      </xsl:result-document>

      <!-- Alter the report element, discarding its stale @select -->
      <xsl:for-each select="$report-element">
        <xsl:copy>
          <xsl:sequence select="attribute() except @select" />
          <xsl:attribute name="href" select="$href" />
        </xsl:copy>
      </xsl:for-each>
    </xsl:when>

    <!-- Not too many nodes. Just output the report element as is. -->
    <xsl:otherwise>
      <xsl:sequence select="$report-element" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:function name="test:report-pseudo-item" as="element()">
  <xsl:param name="item" as="item()" />
  <xsl:param name="wrapper-ns" as="xs:string" />

  <xsl:variable name="local-name-prefix" as="xs:string" select="'pseudo-'" />

  <xsl:choose>
    <xsl:when test="$item instance of xs:anyAtomicType">
      <xsl:element name="{$local-name-prefix}atomic-value" namespace="{$wrapper-ns}">
        <xsl:value-of select="test:report-atomic-value($item)" />
      </xsl:element>
    </xsl:when>

    <xsl:when test="$item instance of node()">
      <xsl:element name="{$local-name-prefix}{x:node-type($item)}" namespace="{$wrapper-ns}">
        <xsl:choose>
          <!-- Can't apply templates to namespace nodes -->
          <xsl:when test="x:instance-of-namespace($item)">
            <xsl:sequence select="$item" />
          </xsl:when>

          <xsl:otherwise>
            <xsl:apply-templates select="$item" mode="test:report-node" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:when>

    <!-- "instance of function(*)" requires Saxon-PE or higher -->
    <xsl:when test="($item instance of array(*)) or ($item instance of map(*))"
      use-when="function-available('serialize', 2)">
      <xsl:element name="{$local-name-prefix}function" namespace="{$wrapper-ns}">
        <xsl:value-of select="serialize($item, map { 'method': 'adaptive' })" />
      </xsl:element>
    </xsl:when>

    <xsl:otherwise>
      <xsl:element name="{$local-name-prefix}other" namespace="{$wrapper-ns}" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  mode="test:report-node"
    Copies the nodes while wrapping whitespace-only text nodes in <test:ws>
-->
<xsl:template match="document-node() | attribute() | node()" as="node()" mode="test:report-node">
  <xsl:copy>
    <xsl:apply-templates select="attribute() | node()" mode="#current" />
  </xsl:copy>
</xsl:template>

<xsl:template match="text()[not(normalize-space())]" as="element(test:ws)" mode="test:report-node">
  <xsl:element name="test:ws">
    <xsl:sequence select="." />
  </xsl:element>
</xsl:template>

<xsl:function name="test:report-atomic-value" as="xs:string">
  <xsl:param name="value" as="xs:anyAtomicType" />
  <xsl:choose>
    <xsl:when test="$value instance of xs:string">
      <xsl:sequence select="concat('''',
                                   replace($value, '''', ''''''),
                                   '''')" />
    </xsl:when>
 
    <!-- Numeric literals: http://www.w3.org/TR/xpath20/#id-literals -->
    <!-- Check integer before decimal, because of derivation -->
    <xsl:when test="$value instance of xs:integer">
      <xsl:sequence select="string($value)" />
    </xsl:when>
    <xsl:when test="$value instance of xs:decimal">
      <xsl:sequence select="x:decimal-string($value)" />
    </xsl:when>
    <!-- xs:double
             Just defer it to xsl:otherwise. Justifications below.
             - Expression is a bit complicated: http://www.w3.org/TR/xpath-functions/#casting-to-string
             - Not used as frequently as integer
             - xsl:otherwise will return valid expression. It's just some more verbose than numeric literal. -->

    <xsl:when test="$value instance of xs:QName">
      <xsl:sequence
        select="concat('QName(''', namespace-uri-from-QName($value), 
                              ''', ''', if (prefix-from-QName($value)) 
                                        then concat(prefix-from-QName($value), ':') 
                                        else '',
                              local-name-from-QName($value), ''')')" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="type" select="test:atom-type($value)" />
      <xsl:sequence select="concat($type, '(',
                                   test:report-atomic-value(string($value)), ')')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>  
  
<xsl:function name="test:atom-type" as="xs:string">
  <xsl:param name="value" as="xs:anyAtomicType" />
  <xsl:choose>
    <!-- Grouped as the spec does.
         Groups are in the reversed order so that the derived types are before the primitive types,
         otherwise xs:integer is recognised as xs:decimal, xs:yearMonthDuration as xs:duration, and so on. -->

    <!-- http://www.w3.org/TR/xslt20/#built-in-types
            Every XSLT 2.0 processor includes the following named type definitions in the in-scope schema components: -->

    <!--    * The following types defined in [XPath 2.0] -->
    <xsl:when test="$value instance of xs:yearMonthDuration">xs:yearMonthDuration</xsl:when>
    <xsl:when test="$value instance of xs:dayTimeDuration">xs:dayTimeDuration</xsl:when>
    <!-- xs:anyAtomicType: Abstract -->
    <!-- xs:untyped: Not atomic -->
    <xsl:when test="$value instance of xs:untypedAtomic">xs:untypedAtomic</xsl:when>

    <!--    * The types xs:anyType and xs:anySimpleType. -->
    <!-- Not atomic -->

    <!--    * The derived atomic type xs:integer defined in [XML Schema Part 2]. -->
    <xsl:when test="$value instance of xs:integer">xs:integer</xsl:when>

    <!--    * All the primitive atomic types defined in [XML Schema Part 2], with the exception of xs:NOTATION. -->
    <xsl:when test="$value instance of xs:string">xs:string</xsl:when>
    <xsl:when test="$value instance of xs:boolean">xs:boolean</xsl:when>
    <xsl:when test="$value instance of xs:decimal">xs:decimal</xsl:when>
    <xsl:when test="$value instance of xs:double">xs:double</xsl:when>
    <xsl:when test="$value instance of xs:float">xs:float</xsl:when>
    <xsl:when test="$value instance of xs:date">xs:date</xsl:when>
    <xsl:when test="$value instance of xs:time">xs:time</xsl:when>
    <xsl:when test="$value instance of xs:dateTime">xs:dateTime</xsl:when>
    <xsl:when test="$value instance of xs:duration">xs:duration</xsl:when>
    <xsl:when test="$value instance of xs:QName">xs:QName</xsl:when>
    <xsl:when test="$value instance of xs:anyURI">xs:anyURI</xsl:when>
    <xsl:when test="$value instance of xs:gDay">xs:gDay</xsl:when>
    <xsl:when test="$value instance of xs:gMonthDay">xs:gMonthDay</xsl:when>
    <xsl:when test="$value instance of xs:gMonth">xs:gMonth</xsl:when>
    <xsl:when test="$value instance of xs:gYearMonth">xs:gYearMonth</xsl:when>
    <xsl:when test="$value instance of xs:gYear">xs:gYear</xsl:when>
    <xsl:when test="$value instance of xs:base64Binary">xs:base64Binary</xsl:when>
    <xsl:when test="$value instance of xs:hexBinary">xs:hexBinary</xsl:when>

    <xsl:otherwise>xs:anyAtomicType</xsl:otherwise>
  </xsl:choose>  
</xsl:function>

<xsl:function name="msxsl:node-set" as="item()*">
  <xsl:param name="rtf" as="item()*" />
  <xsl:sequence select="$rtf" />
</xsl:function>

<!-- Returns true if every item in sequence can be wrapped in document node.
  Empty sequence is considered to be able to be wrapped. -->
<xsl:function name="test:wrappable-sequence" as="xs:boolean">
  <xsl:param name="sequence" as="item()*" />

  <xsl:sequence select="every $item in $sequence satisfies test:wrappable-node($item)" />
</xsl:function>

<!-- Returns true if item is node and can be wrapped in document node -->
<xsl:function name="test:wrappable-node" as="xs:boolean">
  <xsl:param name="item" as="item()" />

  <!-- Document node cannot wrap attribute node or namespace node:
       http://www.w3.org/TR/xslt20/#err-XTDE0420 -->
  <xsl:sequence select="$item instance of node()
    and not($item instance of attribute()
            or x:instance-of-namespace($item))" />
</xsl:function>

<!-- Wraps nodes in document node with their type annotations kept -->
<xsl:function name="test:wrap-nodes" as="document-node()">
  <xsl:param name="nodes" as="node()*" />

  <!-- $wrap aims to create an implicit document node as described
       in http://www.w3.org/TR/xslt20/#temporary-trees
       So its xsl:variable must not have @as or @select.
       Do not use xsl:document or xsl:copy-of: xspec/xspec#47 -->
  <xsl:variable name="wrap">
    <xsl:sequence select="$nodes" />
  </xsl:variable> 
  <xsl:sequence select="$wrap" />
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
