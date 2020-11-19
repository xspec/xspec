<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable as="item()" name="global-context" select="." />

	<sch:pattern>
		<sch:rule context="foo">
			<sch:report id="global-context-of-foo-is-root-document-node"
				test="$global-context is (root() treat as document-node(element(foo)))" />
		</sch:rule>

		<sch:rule context="bar">
			<sch:report id="global-context-of-bar-is-root-document-node"
				test="$global-context is (root() treat as document-node(element(bar)))" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
