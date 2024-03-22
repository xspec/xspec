<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       coverage-report.xsl                                      -->
<!--  Author:     Jeni Tennison                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:fmt="urn:x-xspec:reporter:format-utils"
                xmlns:local="urn:x-xspec:reporter:coverage-report:local"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <xsl:include href="../common/common-utils.xsl" />
   <xsl:include href="../common/deep-equal.xsl" />
   <xsl:include href="../common/namespace-vars.xsl" />
   <xsl:include href="../common/uqname-utils.xsl" />
   <xsl:include href="../common/wrap.xsl" />
   <xsl:include href="format-utils.xsl" />

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/coverage-report.xsl</pkg:import-uri>

   <xsl:global-context-item as="document-node(element(trace))" use="required" />

   <xsl:param name="inline-css" as="xs:string" select="false() cast as xs:string" />

   <xsl:param name="report-css-uri" as="xs:string?" />

   <!-- @use-character-maps for inline CSS -->
   <xsl:output method="xhtml" use-character-maps="fmt:disable-escaping" />

   <xsl:variable name="trace" as="document-node()" select="/" />

   <xsl:variable name="xspec-uri" as="xs:anyURI" select="$trace/trace/@xspec" />
   <xsl:variable name="xspec-doc" as="document-node(element(x:description))"
      select="doc($xspec-uri)" />

   <xsl:variable name="stylesheet-uri" as="xs:anyURI"
      select="$xspec-doc/x:description/resolve-uri(@stylesheet, base-uri())" />

   <xsl:variable name="stylesheet-trees" as="document-node()+"
      select="$stylesheet-uri => doc() => local:collect-stylesheets()" />

   <xsl:key name="modules" match="module" use="@uri" />
   <xsl:key name="traceables" match="traceable" use="@traceableId" />
   <xsl:key name="hits" match="hit" use="local:hits-key-value(@moduleId, @lineNumber, @columnNumber)" />

   <!--
      mode="#default"
   -->
   <xsl:mode on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="document-node(element(trace))" as="element(xhtml:html)">
      <xsl:apply-templates select="." mode="coverage-report" />
   </xsl:template>

   <!--
      mode="coverage-report"
   -->
   <xsl:mode name="coverage-report" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="document-node(element(trace))" as="element(xhtml:html)"
      mode="coverage-report">
      <html>
         <head>
            <title>
               <xsl:text expand-text="yes">Test Coverage Report for {fmt:format-uri($stylesheet-uri)}</xsl:text>
            </title>
            <xsl:call-template name="fmt:load-css">
               <xsl:with-param name="inline" select="$inline-css cast as xs:boolean" />
               <xsl:with-param name="uri" select="$report-css-uri" />
            </xsl:call-template>
         </head>
         <body>
            <h1>Test Coverage Report</h1>
            <p>
               <xsl:text>Stylesheet:  </xsl:text>
               <a href="{$stylesheet-uri}">
                  <xsl:value-of select="fmt:format-uri($stylesheet-uri)" />
               </a>
            </p>
            <xsl:apply-templates select="$stylesheet-trees/xsl:*" mode="#current" />
         </body>
      </html>
   </xsl:template>

   <xsl:template match="xsl:stylesheet | xsl:transform" as="element()+" mode="coverage-report">
      <xsl:variable name="stylesheet-uri" as="xs:anyURI"
         select="base-uri()" />
      <xsl:variable name="stylesheet-string" as="xs:string"
         select="unparsed-text($stylesheet-uri)" />
      <xsl:variable name="stylesheet-lines" as="xs:string+"
         select="local:split-lines($stylesheet-string)" />
      <xsl:variable name="number-of-lines" as="xs:integer"
         select="count($stylesheet-lines)" />
      <xsl:variable name="number-width" as="xs:integer"
         select="string-length(xs:string($number-of-lines))" />
      <xsl:variable name="number-format" as="xs:string"
         select="string-join(for $i in 1 to $number-width return '0')" />
      <xsl:variable name="module-id" as="xs:integer?">
         <xsl:variable name="uri" as="xs:string"
            select="if (starts-with($stylesheet-uri, '/'))
                    then ('file:' || $stylesheet-uri)
                    else $stylesheet-uri" />
         <xsl:sequence select="key('modules', $uri, $trace)/@moduleId" />
      </xsl:variable>
      <h2>
         <xsl:text expand-text="yes">module: {fmt:format-uri($stylesheet-uri)}; {$number-of-lines} lines</xsl:text>
      </h2>
      <xsl:choose>
         <xsl:when test="empty($module-id)">
            <p><span class="missed">not used</span></p>
         </xsl:when>
         <xsl:otherwise>
            <pre>
               <xsl:value-of select="format-number(1, $number-format)" />
               <xsl:text>: </xsl:text>
               <xsl:call-template name="output-lines">
                  <xsl:with-param name="stylesheet-lines" select="$stylesheet-lines" />
                  <xsl:with-param name="number-format" select="$number-format" />
                  <xsl:with-param name="module-id" select="$module-id" />
               </xsl:call-template>
            </pre>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:variable name="attribute-regex" as="xs:string">
      <xsl:value-of xml:space="preserve">
         \s+
         (?:[^>\s]+)      <!-- ?: the name of the attribute -->
         \s*
         =
         \s*
         (?:              <!-- ?: the value of the attribute (with quotes) -->
            "(?:[^"]*)"   <!-- ?: the value without quotes -->
            |
            '(?:[^']*)'   <!-- ?: also the value without quotes -->
         )
      </xsl:value-of>
   </xsl:variable>

   <xsl:variable name="groups" as="map(xs:string, xs:integer)" select="map{
      'construct' : 1,
      'text' : 2,
      'comment' : 3,
      'pi' : 4,
      'cdata' : 5,
      'close-tag' : 6,
      'close-tag-name' : 7,
      'open-tag' : 8,
      'open-tag-name' : 9,
      'empty-tag' : 10}"
   />

   <xsl:variable name="construct-regex" as="xs:string">
      <xsl:value-of xml:space="preserve">
         (                                   <!-- 1: the construct -->
            ([^&lt;]+)                       <!-- 2: some text -->
            |
            (&lt;!--                         <!-- 3: a comment -->
               (?:[^-]|-[^-])*               <!-- ?: the content of the comment -->
             -->)
            |
            (&lt;\?                          <!-- 4: a PI -->
               (?:[^?]|\?[^>])*              <!-- ?: the content of the PI -->
             \?>)
            |
            (&lt;!\[CDATA\[                  <!-- 5: a CDATA section -->
               (?:[^\]]|\][^\]]|\]\][^>])*   <!-- ?: the content of the CDATA section -->
             \]\]>)
            |
            (&lt;/                           <!-- 6: a close tag -->
               ([^>]+)                       <!-- 7: the name of the element being closed -->
             >)
            |
            (&lt;                            <!-- 8: an open tag -->
               ([^>/\s]+)                    <!-- 9: the name of the element being opened -->
               (?:                           <!-- ?: the attributes of the element -->
                  (?:                        <!-- ?: wrapper for the attribute regex -->
                     <xsl:value-of select="$attribute-regex" />
                  )*
               )
               \s*
               (/?)                          <!-- 10: empty element tag flag -->
               >
            )
         )
      </xsl:value-of>
   </xsl:variable>

   <xsl:template name="output-lines" as="node()+">
      <!-- Context item is xsl:stylesheet or xsl:transform -->
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="stylesheet-lines" as="xs:string+" required="yes" />
      <xsl:param name="number-format" as="xs:string" required="yes" />
      <xsl:param name="module-id" as="xs:integer" required="yes" />

      <xsl:variable name="outermost-element" as="element()" select="." />

      <xsl:variable name="filtered-stylesheet-string" as="xs:string" select="
            $stylesheet-lines
            => local:filter-leading-string-in-lines($outermost-element)
            => string-join('&#x0A;')" />

      <!-- Analyze the entire stylesheet string. For each matching substring, create a map that
         records the kind of match. -->
      <xsl:variable name="regex-groups" as="map(xs:integer, xs:string)+">
         <xsl:analyze-string select="$filtered-stylesheet-string" regex="{$construct-regex}" flags="sx">
            <xsl:matching-substring>
               <xsl:map>
                  <xsl:for-each select="1 to map:size($groups)">
                     <xsl:map-entry key="." select="regex-group(.)" />
                  </xsl:for-each>
               </xsl:map>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
               <xsl:message terminate="yes">
                  <xsl:text expand-text="yes">ERROR: unmatched string: {.}</xsl:text>
               </xsl:message>
            </xsl:non-matching-substring>
         </xsl:analyze-string>
      </xsl:variable>

      <!-- Iterate over the matching substrings, while keeping track of the corresponding line
         number and node. -->
      <xsl:iterate select="$regex-groups">
         <xsl:param name="line-number" as="xs:integer" select="0" />
         <xsl:param name="node" as="node()" select="$outermost-element" />

         <xsl:variable name="regex-group" as="map(xs:integer, xs:string)" select="." />

         <xsl:variable name="construct" as="xs:string" select="$regex-group($groups('construct'))" />
         <xsl:variable name="construct-lines" as="xs:string+"
            select="local:split-lines($construct)" />
         <xsl:variable name="endTag" as="xs:boolean" select="$regex-group($groups('close-tag')) ne ''" />
         <xsl:variable name="emptyTag" as="xs:boolean" select="$regex-group($groups('empty-tag')) ne ''" />
         <xsl:variable name="startTag" as="xs:boolean" select="not($emptyTag) and $regex-group($groups('open-tag'))" />
         <xsl:variable name="matches" as="xs:boolean"
            select="($node instance of text() and
                     ($regex-group($groups('text')) or $regex-group($groups('cdata')))) or
                    ($node instance of element() and
                     ($startTag or $endTag or $emptyTag) and
                     name($node) = ($regex-group($groups('close-tag-name')), $regex-group($groups('open-tag-name')))) or
                    ($node instance of comment() and
                     $regex-group($groups('comment'))) or
                    ($node instance of processing-instruction() and
                     $regex-group($groups('pi')))" />
         <xsl:variable name="coverage" as="xs:string"
            select="if ($matches) then local:coverage($node, $module-id) else 'ignored'" />
         <xsl:for-each select="$construct-lines">
            <xsl:if test="position() != 1">
               <xsl:text expand-text="yes">&#x0A;{format-number($line-number + position(), $number-format)}: </xsl:text>
            </xsl:if>
            <xsl:where-populated>
               <span class="{$coverage}">
                  <xsl:choose>
                     <xsl:when test="
                           ($line-number eq 0)
                           and ($node is $outermost-element)
                           and $regex-group($groups('text'))">
                        <xsl:variable name="position" as="xs:integer" select="position()" />
                        <xsl:value-of
                           select="substring($stylesheet-lines[$position], 1, string-length())" />
                     </xsl:when>

                     <xsl:otherwise>
                        <xsl:value-of select="." />
                     </xsl:otherwise>
                  </xsl:choose>
               </span>
            </xsl:where-populated>
         </xsl:for-each>

         <xsl:next-iteration>
            <xsl:with-param name="line-number" select="$line-number + count($construct-lines) - 1" />
            <xsl:with-param name="node" as="node()">
               <xsl:choose>
                  <xsl:when test="$matches">
                     <xsl:choose>
                        <xsl:when test="$startTag">
                           <xsl:choose>
                              <xsl:when test="$node/node()">
                                 <xsl:sequence select="$node/node()[1]" />
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:sequence select="$node" />
                              </xsl:otherwise>
                           </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:choose>
                              <xsl:when test="$node/following-sibling::node()">
                                 <xsl:sequence select="$node/following-sibling::node()[1]" />
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:sequence select="$node/parent::node()" />
                              </xsl:otherwise>
                           </xsl:choose>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:sequence select="$node" />
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:next-iteration>
      </xsl:iterate>
   </xsl:template>

   <!--
      mode="coverage"
   -->
   <xsl:mode name="coverage" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="text()[normalize-space() = '' and not(parent::xsl:text)]" as="xs:string"
      mode="coverage">ignored</xsl:template>

   <xsl:template match="processing-instruction() | comment()" as="xs:string"
      mode="coverage">ignored</xsl:template>

   <!-- A hit on these nodes doesn't really count; you have to hit
      their contents to hit them -->
   <xsl:template
      match="
         xsl:for-each
         | xsl:for-each-group
         | xsl:matching-substring
         | xsl:non-matching-substring
         | xsl:otherwise
         | xsl:when"
      as="xs:string"
      mode="coverage">
      <xsl:param name="module-id" tunnel="yes" as="xs:integer" required="yes" />

      <xsl:variable name="hits-on-child-nodes" as="element(hit)*"
         select="node() ! local:hits-on-node(., $module-id)" />
      <xsl:choose>
         <xsl:when test="exists($hits-on-child-nodes)">hit</xsl:when>
         <xsl:otherwise>missed</xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="element() | text()" as="xs:string" mode="coverage">
      <xsl:param name="module-id" tunnel="yes" as="xs:integer" required="yes" />

      <xsl:variable name="hits" as="element(hit)*"
         select="local:hits-on-node(., $module-id)" />
      <xsl:choose>
         <xsl:when test="exists($hits)">hit</xsl:when>
         <xsl:when test="self::text() and normalize-space() = '' and not(parent::xsl:text)">ignored</xsl:when>
         <xsl:when test="self::xsl:variable">
            <xsl:sequence select="local:coverage(following-sibling::*[not(self::xsl:variable)][1], $module-id)" />
         </xsl:when>
         <xsl:when test="ancestor::xsl:variable">
            <xsl:sequence select="local:coverage(ancestor::xsl:variable[1], $module-id)" />
         </xsl:when>
         <xsl:when test="self::xsl:stylesheet or self::xsl:transform">ignored</xsl:when>
         <xsl:when test="self::xsl:function or self::xsl:template">missed</xsl:when>
         <!-- A node within a top-level non-XSLT element -->
         <xsl:when test="empty(ancestor::xsl:*[parent::xsl:stylesheet or parent::xsl:transform])">ignored</xsl:when>
         <xsl:when test="self::xsl:param">
            <xsl:sequence select="local:coverage(parent::*, $module-id)" />
         </xsl:when>
         <xsl:when test="self::xsl:context-item">
            <!-- Saxon does not seem to call enter() for xsl:context-item (xspec/xspec#1410) -->
            <xsl:sequence select="local:coverage(parent::xsl:template, $module-id)" />
         </xsl:when>
         <xsl:otherwise>missed</xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="document-node()" as="xs:string" mode="coverage">ignored</xsl:template>

   <!--
      Local functions
   -->

   <xsl:function name="local:collect-stylesheets" as="document-node()+">
      <xsl:param name="stylesheets" as="document-node()+" />

      <xsl:variable name="imports" as="document-node()*"
         select="document($stylesheets/*/(xsl:import|xsl:include)/@href)" />
      <xsl:choose>
         <xsl:when test="$imports except $stylesheets">
            <xsl:sequence select="local:collect-stylesheets($stylesheets | $imports)" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$stylesheets" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="local:coverage" as="xs:string">
      <xsl:param name="node" as="node()" />
      <xsl:param name="module-id" as="xs:integer" />

      <xsl:variable name="coverage" as="xs:string+">
         <xsl:apply-templates select="$node" mode="coverage">
            <xsl:with-param name="module-id" tunnel="yes" select="$module-id" />
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:if test="count($coverage) > 1">
         <xsl:message terminate="yes">
            <xsl:text>ERROR: more than one coverage identified for:</xsl:text>
            <xsl:sequence select="$node" />
         </xsl:message>
      </xsl:if>
      <xsl:sequence select="$coverage[1]" />
   </xsl:function>

   <xsl:function name="local:hits-on-node" as="element(hit)*">
      <xsl:param name="node" as="node()" />
      <xsl:param name="module-id" as="xs:integer" />

      <xsl:for-each select="$node">
         <xsl:variable name="hits" as="element(hit)*"
            select="local:hits-on-line-column($module-id, x:line-number(.), x:column-number(.))" />
         <xsl:variable name="node-uqname" as="xs:string?" select="x:node-UQName(.)" />
         <xsl:for-each select="$hits">
            <xsl:variable name="hit-traceable-uqname" as="xs:string?"
               select="exactly-one(key('traceables', @traceableId, $trace))/@uqname" />
            <xsl:if test="($node-uqname eq $hit-traceable-uqname) or
                          empty($hit-traceable-uqname)">
               <xsl:sequence select="." />
            </xsl:if>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:function>

   <xsl:function name="local:hits-on-line-column" as="element(hit)*">
      <xsl:param name="module-id" as="xs:integer" />
      <xsl:param name="line-number" as="xs:integer" />
      <xsl:param name="column-number" as="xs:integer" />

      <xsl:variable name="key-value" as="xs:string"
         select="local:hits-key-value($module-id, $line-number, $column-number)" />
      <xsl:sequence select="key('hits', $key-value, $trace)" />
   </xsl:function>

   <xsl:function name="local:hits-key-value" as="xs:string">
      <xsl:param name="module-id" as="xs:integer" />
      <xsl:param name="line-number" as="xs:integer" />
      <xsl:param name="column-number" as="xs:integer" />

      <xsl:sequence select="($module-id, $line-number, $column-number) => string-join(':')" />
   </xsl:function>

   <xsl:function name="local:split-lines" as="xs:string+">
      <xsl:param name="input" as="xs:string" />

      <xsl:choose>
         <xsl:when test="$input">
            <!-- Regular expression is based on
               http://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines -->
            <xsl:sequence select="tokenize($input, '\r\n|\r|\n')" />
         </xsl:when>
         <xsl:otherwise>
            <!-- Return the input string intact if it's a zero-length string -->
            <xsl:sequence select="$input" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <!-- Returns lines before /element(). The last line is a zero-length string, if no characters in
      the last line precede /element(). -->
   <xsl:function name="local:lines-before-outermost-element" as="xs:string+">
      <xsl:param name="lines" as="xs:string+" />
      <xsl:param name="outermost-element" as="element()" />

      <xsl:variable name="outermost-element-line-number" as="xs:integer"
         select="x:line-number($outermost-element)" />
      <xsl:variable name="outermost-element-column-number" as="xs:integer"
         select="x:column-number($outermost-element)" />

      <xsl:variable name="lines-up-to-end-of-outermost-element-open-tag" as="xs:string+">
         <xsl:for-each select="$lines">
            <xsl:choose>
               <xsl:when test="position() lt $outermost-element-line-number">
                  <xsl:sequence select="." />
               </xsl:when>
               <xsl:when test="position() eq $outermost-element-line-number">
                  <xsl:sequence select="substring(., 1, $outermost-element-column-number - 1)" />
               </xsl:when>
               <xsl:otherwise>
                  <!-- Discard -->
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="codepoints-up-to-end-of-outermost-element-open-tag" as="xs:integer+"
         select="
            $lines-up-to-end-of-outermost-element-open-tag
            => string-join('&#x0A;')
            => string-to-codepoints()" />
      <xsl:variable name="index-of-start-of-outermost-element-open-tag" as="xs:integer" select="
            index-of(
               $codepoints-up-to-end-of-outermost-element-open-tag,
               string-to-codepoints('&lt;')
            )
            [last()]" />
      <xsl:variable name="string-before-outermost-element" as="xs:string" select="
            $codepoints-up-to-end-of-outermost-element-open-tag
            [position() lt $index-of-start-of-outermost-element-open-tag]
            => codepoints-to-string()" />
      <xsl:sequence select="local:split-lines($string-before-outermost-element)" />
   </xsl:function>

   <!-- Replaces characters before /element() with whitespace characters -->
   <xsl:function name="local:filter-leading-string-in-lines" as="xs:string+">
      <xsl:param name="lines" as="xs:string+" />
      <xsl:param name="outermost-element" as="element()" />

      <xsl:variable name="lines-before-outermost-element" as="xs:string+"
         select="local:lines-before-outermost-element($lines, $outermost-element)" />

      <xsl:for-each select="$lines">
         <xsl:choose>
            <xsl:when test="position() lt count($lines-before-outermost-element)">
               <xsl:sequence select="replace(. , '.', ' ')" />
            </xsl:when>

            <xsl:when test="position() eq count($lines-before-outermost-element)">
               <xsl:variable name="leading-string-length" as="xs:integer"
                  select="$lines-before-outermost-element[last()] => string-length()" />
               <xsl:value-of>
                  <xsl:sequence select="(1 to $leading-string-length) ! ' '" />
                  <xsl:sequence select="substring(., $leading-string-length + 1)" />
               </xsl:value-of>
            </xsl:when>

            <xsl:otherwise>
               <xsl:sequence select="." />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>

   <!--
      Stub functions for helping development on IDE without loading ../../java/
   -->

   <xsl:function as="xs:integer" name="x:column-number" override-extension-function="no"
      use-when="function-available('saxon:column-number')">
      <xsl:param as="node()" name="node" />

      <xsl:sequence select="saxon:column-number($node)" />
   </xsl:function>

   <xsl:function as="xs:integer" name="x:line-number" override-extension-function="no"
      use-when="function-available('saxon:line-number')">
      <xsl:param as="node()" name="node" />

      <xsl:sequence select="saxon:line-number($node)" />
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
