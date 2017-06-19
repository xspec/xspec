<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       find-examples.xsl                                        -->
<!--  Author:     Jeni Tennsion                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennsion (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<!-- See find-examples.rnc for a schema for the source for this transformation -->
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://www.jenitennison.com/xslt/xspec"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns="http://www.w3.org/1999/XSL/TransformAlias"
  exclude-result-prefixes="xs saxon">

<xsl:param name="select" as="element(x:find)">
	<xsl:choose>
		<xsl:when test="exists(/x:scan/x:find)">
			<xsl:sequence select="/x:scan/x:find" />
		</xsl:when>
		<xsl:otherwise>
			<x:find>//(*|processing-instruction())</x:find>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:variable name="examples" as="node()*">
	<xsl:for-each select="$collection">
		<xsl:variable name="annotated" as="document-node()">
			<xsl:document>
				<xsl:for-each select="*">
					<xsl:copy>
						<xsl:attribute name="xml:base" select="base-uri(.)" />
						<xsl:copy-of select="@*" />
						<xsl:copy-of select="$select" />
						<xsl:copy-of select="node()" />
					</xsl:copy>
				</xsl:for-each>
			</xsl:document>
		</xsl:variable>
		<xsl:apply-templates select="$annotated" mode="find-examples" />
	</xsl:for-each>
</xsl:variable>

<!-- Note: This is sensitive code; moving it into a <xsl:for-each> messes it
	   up -->
<xsl:template match="/" mode="find-examples">
	<xsl:variable name="expr" as="element(x:find)" 
		select="*/x:find" />
	<xsl:sequence select="saxon:evaluate-node($expr) except $expr" />
</xsl:template>

<xsl:param name="collection-uri" as="xs:anyURI"
	select="resolve-uri(/x:scan/x:collection, base-uri(/x:scan/x:collection))" />
<xsl:param name="collection" as="document-node()+"
  select="collection($collection-uri)[not(x:*)]" />
  
<xsl:param name="global-id-atts" as="xs:string" 
	select="if (exists(/x:scan/x:global-id-atts))
	        then /x:scan/x:global-id-atts
	        else 'id xml:id'" />
	
<xsl:param name="local-id-atts" as="xs:string"
	select="if (exists(/x:scan/x:local-id-atts))
	        then /x:scan/x:local-id-atts
	        else ''" />
	
<xsl:param name="enum-atts" as="xs:string"
	select="if (exists(/x:scan/x:enum-atts))
	        then /x:scan/x:enum-atts
	        else ''" />
	
<xsl:param name="max-examples" as="xs:integer"
	select="if (exists(/x:scan/x:max-examples))
	        then xs:integer(/x:scan/x:max-examples)
	        else 10" />
	
<xsl:param name="ns-map" as="xs:string">
	<xsl:choose>
		<xsl:when test="exists(/x:scan)">
			<xsl:value-of>
				<xsl:for-each select="/x:scan/namespace::*[name()]">
					<xsl:sequence select="concat(name(), '={', ., '}')" />
				</xsl:for-each>
			</xsl:value-of>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>xml={http://www.w3.org/XML/1998/namespace};dc={http://purl.org/dc/elements/1.1/}</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>
	
<xsl:variable name="global-ids" as="xs:string*" select="tokenize($global-id-atts, '\s')" />
<xsl:variable name="local-ids" as="xs:string*" select="tokenize($local-id-atts, '\s')" />
<xsl:variable name="enums" as="xs:string*" select="tokenize($enum-atts, '\s')" />
	
<xsl:variable name="ns-map-regex" as="xs:string">
  (\i\c*) <!-- 1: prefix -->
  =\{
  ([^}]+) <!-- 2: URL -->
  \};?
</xsl:variable>

<xsl:variable name="provided-nsmap" as="element(ns)*">
  <xsl:analyze-string select="$ns-map" regex="{$ns-map-regex}" flags="x">
    <xsl:matching-substring>
      <ns prefix="{regex-group(1)}" xmlns="">
        <xsl:sequence select="regex-group(2)" />
      </ns>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:variable>

<xsl:variable name="nsmap" as="element(ns)*">
  <xsl:copy-of select="$provided-nsmap" />
  <xsl:for-each-group  group-by="."
    select="$collection//namespace::*[not(name() = $provided-nsmap/@prefix or . = $provided-nsmap)]">
    <xsl:variable name="prefix" as="xs:string">
      <xsl:choose>
        <xsl:when test="exists(current-group()[name() != ''])">
          <xsl:value-of select="name(current-group()[name() != ''][1])" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="replace(., '^.+?([\i-[:]][\c-[:]]*)/?$', '$1')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not(matches($prefix, '^[\i-[:]][\c-[:]]*$'))">
      <xsl:message terminate="yes">
        <xsl:text>ERROR: Couldn't identify prefix for namespace "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>".&#10;</xsl:text>
        <xsl:text>  See for instance "</xsl:text>
        <xsl:value-of select="document-uri(/)"/>
        <xsl:text>".&#10;</xsl:text>
        <xsl:text>  Declare it with a prefix in the scanning XML document.</xsl:text>
      </xsl:message>
    </xsl:if>
    <ns prefix="{$prefix}" xmlns="">
      <xsl:value-of select="." />
    </ns>
  </xsl:for-each-group>
</xsl:variable>

<xsl:template match="/" name="main">
  <x:description>
    <xsl:for-each select="$nsmap">
      <xsl:namespace name="{@prefix}">
        <xsl:value-of select="." />
      </xsl:namespace>
    </xsl:for-each>
    <xsl:for-each-group select="$examples[self::*]" group-by="node-name(.)">
      <xsl:sort select="x:expanded-QName(current-grouping-key())" />
    	<xsl:variable name="name" as="xs:string" select="x:node-name(.)" />
      <x:scenario label="when processing a {$name} element">
        <xsl:for-each-group select="current-group()"
          group-by="x:content-model(.)">
          <xsl:sort select="current-grouping-key()" />
        	<xsl:variable name="test-id" as="xs:string" select="concat($name, '.', position())" />
          <xsl:choose>
            <xsl:when test="current-grouping-key() = '(text)'">
              <xsl:variable name="all-vals" as="xs:string+" select="distinct-values(current-group())" />
            	<xsl:message>all-vals: <xsl:value-of select="count($all-vals)" /></xsl:message>
              <xsl:choose>
                <xsl:when test="count($all-vals) > $max-examples">
                  <x:scenario label="with the content model (text)">
                    <xsl:apply-templates select="current-group()[position() &lt;= $max-examples]" />
                  </x:scenario>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each-group select="current-group()"
                    group-by=".">
                    <xsl:sort select="." />
                  	<x:scenario label="with the value '{current-grouping-key()}'">
                      <xsl:apply-templates select="current-group()[position() &lt;= $max-examples]">
                      	<xsl:with-param name="enum-value" select="true()" />
                      </xsl:apply-templates>
                    </x:scenario>
                  </xsl:for-each-group>
                </xsl:otherwise>
              </xsl:choose>              
            </xsl:when>
            <xsl:otherwise>
            	<x:scenario label="with the content model {current-grouping-key()}">
                <xsl:apply-templates select="current-group()[position() &lt;= $max-examples]" />
              </x:scenario>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </x:scenario>
    </xsl:for-each-group>
  	<xsl:for-each-group select="$examples[self::processing-instruction()]" group-by="name()">
			<xsl:sort select="name()" />
  		<x:scenario label="when processing a {name()} PI">
  			<xsl:for-each-group select="current-group()" group-by="x:pi-content-model(.)">
  				<xsl:sort select="current-grouping-key()" />
  				<x:scenario label="with content like {current-grouping-key()}">
  					<xsl:apply-templates select="current-group()[position() &lt;= $max-examples]" />
  				</x:scenario>
  			</xsl:for-each-group>
  		</x:scenario>
  	</xsl:for-each-group>
  </x:description>
</xsl:template>

<xsl:template match="*">
	<xsl:param name="enum-value" as="xs:boolean" select="false()" />
  <xsl:choose>
    <xsl:when test="position() = 1">
      <x:context select="{x:xpath(.)}"
        href="{base-uri(.)}" />
      <x:expect label="it should ...">
        <xsl:apply-templates select="." mode="x:shallow-copy">
        	<xsl:with-param name="full-text" tunnel="yes" select="true()" />
        </xsl:apply-templates>
      </x:expect>
    </xsl:when>
    <xsl:otherwise>
      <xsl:comment>
        <xsl:text>&lt;x:context select="</xsl:text>
        <xsl:value-of select="x:xpath(.)" />
        <xsl:text>" href="</xsl:text>
        <xsl:value-of select="base-uri(.)" />
        <xsl:text>" /></xsl:text>
      </xsl:comment>
    	<xsl:text>&#xA;&#x9;&#x9;&#x9;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="processing-instruction()">
	<xsl:choose>
		<xsl:when test="position() = 1">
			<x:context select="{x:xpath(.)}" href="{base-uri(.)}" />
			<x:expect label="it should ...">
				<xsl:copy-of select="." />
			</x:expect>
		</xsl:when>
		<xsl:otherwise>
			<xsl:comment>
				<xsl:text>&lt;x:context select="</xsl:text>
				<xsl:value-of select="x:xpath(.)" />
				<xsl:text>" href="</xsl:text>
				<xsl:value-of select="base-uri(.)" />
				<xsl:text>" /></xsl:text>
			</xsl:comment>
			<xsl:text>&#xA;&#x9;&#x9;&#x9;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="x:shallow-copy" priority="2">
  <xsl:param name="level" select="0" />
	<xsl:param name="full-text" select="false()" tunnel="yes" />
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:choose>
      <xsl:when test="text() and *">
        <xsl:choose>
          <xsl:when test="$level = 0 or $full-text">
            <xsl:copy-of select="node()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>...</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="*">
        <xsl:choose>
          <xsl:when test="$level = 0">
            <xsl:apply-templates select="node()" mode="x:shallow-copy">
              <xsl:with-param name="level" select="1" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>...</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$full-text or string-length(.) > 15">
            <xsl:text>...</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="node()" mode="x:shallow-copy">
              <xsl:with-param name="level" select="1" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()" mode="x:shallow-copy">
  <xsl:copy-of select="." />
</xsl:template>

<xsl:function name="x:content-model" as="xs:string">
  <xsl:param name="element" as="element()" />
  <xsl:apply-templates select="$element" mode="x:content-model" />
</xsl:function>
  
<xsl:template match="*[text() and *]" mode="x:content-model" as="xs:string" 
  priority="5">
  <xsl:value-of>
    <xsl:text>mixed{</xsl:text>
    <xsl:next-match />
    <xsl:text>}</xsl:text>
  </xsl:value-of>
</xsl:template>
  
<xsl:variable name="content-model-keywords" as="xs:string+"
	select="('text', 'empty', 'mixed')" />  
  
<xsl:template match="*[*]" mode="x:content-model" as="xs:string"
  priority="4">
  <xsl:value-of>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="." mode="x:attribute-model" />
    <xsl:if test="@*">,</xsl:if>
    <xsl:for-each-group select="*" group-adjacent="node-name(.)">
    	<xsl:variable name="name" as="xs:string" select="x:node-name(.)" />
      <xsl:value-of select="if ($name = $content-model-keywords) then concat('\', $name) else $name" />
      <xsl:if test="count(current-group()) > 1">+</xsl:if>
      <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each-group>
    <xsl:text>)</xsl:text>
  </xsl:value-of>
</xsl:template>

<xsl:template match="*[not(* or text())]" mode="x:content-model" as="xs:string"
  priority="5">
  <xsl:choose>
    <xsl:when test="@*">
      <xsl:value-of>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="." mode="x:attribute-model" />
        <xsl:text>)</xsl:text>
      </xsl:value-of>
    </xsl:when>
    <xsl:otherwise>(empty)</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="x:content-model" as="xs:string"
  priority="0">
  <xsl:value-of>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="." mode="x:attribute-model" />
    <xsl:if test="@*">,</xsl:if>
    <xsl:text>text)</xsl:text>
  </xsl:value-of>
</xsl:template>

<xsl:template match="*" mode="x:attribute-model" as="xs:string">
  <xsl:value-of>
    <xsl:for-each select="@*">
      <xsl:sort select="x:expanded-QName(node-name(.))" />
      <xsl:text>@</xsl:text>
      <xsl:value-of select="x:node-name(.)" />
      <xsl:choose>
        <xsl:when test="x:node-name(.) = $enums">
          <xsl:sequence select="concat('{''', ., '''}')" />
        </xsl:when>
        <xsl:when test="x:node-name(.) = $global-ids">
          <xsl:sequence select="'{xs:ID}'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="value-model" select="x:value-model(.)" />
          <xsl:if test="$value-model != 'text'">
            <xsl:text>{</xsl:text>
            <xsl:value-of select="$value-model" />
            <xsl:text>}</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>
  </xsl:value-of>
</xsl:template>

<xsl:function name="x:value-model" as="xs:string">
  <xsl:param name="text" as="xs:string" />
  <xsl:choose>
    <xsl:when test="$text = ''">
      <xsl:sequence select="''''''" />
    </xsl:when>
    <!-- looks like a year -->
    <xsl:when test="matches($text, '^(19|20)[0-9]{2}$')">
      <xsl:sequence select="'xs:gYear'" />
    </xsl:when>
    <!-- looks like a date -->
    <xsl:when test="matches($text, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')" >
      <xsl:sequence select="'xs:date'" />
    </xsl:when>
    <!-- looks like a dateTime -->
    <xsl:when test="matches($text, '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?$')" >
      <xsl:sequence select="'xs:dateTime'" />
    </xsl:when>
    <!-- looks like an integer -->
    <xsl:when test="matches($text, '^[0-9]+$')">
      <xsl:sequence select="'xs:integer'" />
    </xsl:when>
    <!-- looks like a decimal -->
    <xsl:when test="matches($text, '^[0-9]*\.[0-9]+$')">
      <xsl:sequence select="'xs:decimal'" />
    </xsl:when>
    <!-- looks like a token -->
    <xsl:when test="matches($text, '^\i\c*$')">
      <xsl:choose>
        <xsl:when test="matches($text, '^\i\c*:\i\c*$')">
          <xsl:sequence select="'xs:QName'" />
        </xsl:when>
        <xsl:when test="matches($text, '^[\i-[:]][\c-[:]]*$')">
          <xsl:sequence select="'xs:NCName'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'xs:Name'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!-- looks like a NMTOKEN -->
    <xsl:when test="matches($text, '^\c+$')">
      <xsl:sequence select="'xs:NMTOKEN'" />
    </xsl:when>
    <xsl:when test="contains($text, ' ')">
      <xsl:variable name="value-types" as="xs:string+">
        <xsl:for-each select="tokenize($text, '\s+')">
          <xsl:sequence select="x:value-model(.)" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="count(distinct-values($value-types)) = 1">
          <xsl:sequence select="concat($value-types[1], '+')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'text'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="'text'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:variable name="pseudo-attribute-regex">
	(\i\c*)     <!-- 1: pseudo-attribute name -->
	=
	(           <!-- 2: quoted value -->
	('([^']*)') <!-- 3: single quoted value --><!-- 4: value -->
	("([^"]*)") <!-- 5: double quoted value --><!-- 6: value -->
	)
</xsl:variable>

<xsl:function name="x:pi-content-model" as="xs:string">
	<xsl:param name="pi" as="processing-instruction()" />
	<xsl:choose>
		<xsl:when test="matches($pi, $pseudo-attribute-regex, 'x')">
			<xsl:variable name="atts" as="attribute()*">
				<xsl:analyze-string select="$pi" regex="$psudo-attribute-regex" flags="x">
					<xsl:matching-substring>
						<xsl:attribute name="{regex-group(1)}" 
							select="if (regex-group(3)) then regex-group(4) else regex-group(5)" />
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:message>WARNING: found a PI that holds text as well as pseudo-attributes</xsl:message>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:variable>
			<xsl:value-of>
				<xsl:text>(</xsl:text>
				<xsl:for-each select="$atts">
					<xsl:sort select="name()" />
					<xsl:variable name="value-model" select="x:value-model(.)" />
					<xsl:text>@</xsl:text>
					<xsl:value-of select="name()" />
					<xsl:if test="$value-model != 'text'">
						<xsl:text>{</xsl:text>
						<xsl:value-of select="$value-model" />
						<xsl:text>}</xsl:text>
					</xsl:if>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
				<xsl:text>)</xsl:text>
			</xsl:value-of>
		</xsl:when>
		<xsl:when test="normalize-space($pi)">
			<xsl:sequence select="concat('(', x:value-model($pi), ')')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'(empty)'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="x:xpath" as="xs:string">
  <xsl:param name="node" as="node()" />
	<xsl:apply-templates select="$node" mode="x:xpath" />
</xsl:function>

<xsl:template match="processing-instruction()" mode="x:xpath" as="xs:string">
	<xsl:variable name="name" select="name()" />
	<xsl:variable name="predicate" as="xs:string"
		select="if (count(../processing-instruction()[name() = $name]) > 1)
		        then concat('[', count(preceding-sibling::processing-instruction()[name() = $name]) + 1, ']')
		        else ''" />
	<xsl:variable name="node-test" as="xs:string"
		select="concat('processing-instruction(', name(), ')', $predicate)" />
	<xsl:sequence select="concat(if (parent::*) then x:xpath(..) else '',
		                           '/', $node-test)" />
</xsl:template>

<xsl:template match="*" mode="x:xpath" as="xs:string">
	<xsl:variable name="name" as="xs:string" select="x:node-name(.)" />
	<xsl:choose>
		<xsl:when test="not(./parent::*)">
			<xsl:sequence select="concat('/', $name)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="global-id" as="attribute()?"
				select="@*[x:node-name(.) = $global-ids][1]" />
			<xsl:choose>
				<xsl:when test="exists($global-id)">
					<xsl:sequence select="concat('//', $name, '[@', name($global-id), '=''', $global-id, ''']')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="base-path" as="xs:string"
						select="concat(x:xpath(..), '/', $name)" />
					<xsl:variable name="local-id" as="attribute()?"
						select="@*[x:node-name(.) = $local-ids][1]" />
					<xsl:choose>
						<xsl:when test="exists($local-id)">
							<xsl:sequence select="concat($base-path, '[@', name($local-id), '=''', $local-id, ''']')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="count(../*[x:node-name(.) = $name]) > 1">
									<xsl:sequence select="concat($base-path, '[', count(preceding-sibling::*[x:node-name(.) = $name]) + 1, ']')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="$base-path" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>          
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="x:expanded-QName" as="xs:string">
  <xsl:param name="qname" as="xs:QName" />
  <xsl:sequence select="concat('{', namespace-uri-from-QName($qname), '}', local-name-from-QName($qname))" />
</xsl:function>

<xsl:function name="x:node-name" as="xs:string">
  <xsl:param name="node" as="node()" />
  <xsl:choose>
    <xsl:when test="namespace-uri($node)">
      <xsl:variable name="prefix" select="x:prefix-for-ns(namespace-uri($node))" />
      <xsl:sequence select="concat($prefix, ':', local-name($node))" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="local-name($node)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="x:prefix-for-ns" as="xs:string">
  <xsl:param name="ns" as="xs:string" />
  <xsl:sequence select="($nsmap[. = $ns]/@prefix)[1]" />
</xsl:function>
	
<xsl:strip-space elements="*" />
<xsl:output indent="yes" encoding="ASCII" />

<xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>
	
</xsl:stylesheet>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2008, 2010 Jeni Tennsion                                -->
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
