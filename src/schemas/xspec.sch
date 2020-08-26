<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Relies on XSLT utilities -->
	<xsl:include href="../common/namespace-utils.xsl" />
	<xsl:include href="../common/uqname-utils.xsl" />
	<xsl:include href="../common/xspec-utils.xsl" />

	<sch:ns prefix="x" uri="http://www.jenitennison.com/xslt/xspec" />

	<sch:pattern>
		<!-- When a whitespace-only text node is user-content and has no sibling nodes -->
		<sch:rule
			context="
				text()[not(normalize-space())]
				[x:is-user-content(.)]
				[empty(preceding-sibling::node())][empty(following-sibling::node())]">
			<sch:let name="preserve-space-qnames" value="x:parse-preserve-space(/x:description)" />
			<sch:let name="parent-element" value="parent::element()" />
			<sch:let name="parent-name" value="name($parent-element)" />
			<sch:let name="xspec-namespace" value="namespace-uri(/x:description)" />

			<!-- Take the liberty of using this fallback prefix 'x' without considering the inherited
				namespace prefixes, because x:text element won't have descendant elements. -->
			<sch:let name="xspec-prefix"
				value="
					(
					in-scope-prefixes($parent-element)[namespace-uri-for-prefix(., $parent-element) eq $xspec-namespace],
					'x'
					)[1]" />
			<sch:let name="x-text-lexical-QName"
				value="string-join(($xspec-prefix[.], 'text'), ':')" />

			<!-- Then the text node should be non ignorable, otherwise it's most likely a mistake -->
			<sch:assert id="text-node-should-be-non-ignorable" role="warn"
				sqf:fix="sqf-delete sqf-wrap-in-x-text sqf-add-xml-space-preserve sqf-add-preserve-space"
				test="x:is-ws-only-text-node-significant(., $preserve-space-qnames)">Whitespace-only
				text node will be ignored</sch:assert>

			<sqf:fix id="sqf-delete">
				<sqf:description>
					<sqf:title>Delete the ignorable whitespace-only text node</sqf:title>
				</sqf:description>
				<sqf:delete />
			</sqf:fix>

			<sqf:fix id="sqf-wrap-in-x-text">
				<sqf:description>
					<sqf:title>Wrap the whitespace-only text node in <sch:value-of
							select="$x-text-lexical-QName" /> element</sqf:title>
				</sqf:description>
				<sqf:replace>
					<xsl:element name="{$x-text-lexical-QName}" namespace="{$xspec-namespace}">
						<xsl:sequence select="." />
					</xsl:element>
				</sqf:replace>
			</sqf:fix>

			<sqf:fix id="sqf-add-xml-space-preserve">
				<sqf:description>
					<sqf:title>Add @xml:space=preserve to the parent element (<sch:value-of
							select="$parent-name" />)</sqf:title>
				</sqf:description>
				<sqf:add match="$parent-element" node-type="attribute" select="'preserve'"
					target="xml:space" />
			</sqf:fix>

			<sqf:fix id="sqf-add-preserve-space">
				<sqf:description>
					<!-- iso_dsdl_include_xsl doesn't like sch:name[@path][empty(@select)]
						(Schematron/schematron#12). That's why name(). -->
					<sqf:title>Add the parent element name (<sch:value-of select="$parent-name" />)
						to /<sch:value-of select="name(/x:description)"
						 />/@preserve-space</sqf:title>
				</sqf:description>

				<!-- This SQF doesn't take care of namespace differences between the parent
					element and /x:description element. -->
				<sqf:add match="/x:description" node-type="attribute"
					select="string-join(($preserve-space-qnames, $parent-name), ' ')"
					target="preserve-space" />
			</sqf:fix>
		</sch:rule>
	</sch:pattern>
</sch:schema>
