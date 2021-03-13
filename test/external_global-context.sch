<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="external_global-context.xsl" />

	<sch:ns prefix="test" uri="x-urn:test:external_global-context" />

	<sch:pattern>
		<sch:rule context="foo">
			<sch:report id="global-context-while-validating-foo-is-root-document-node-of-foo"
				test="$test:global-context is (root() treat as document-node(element(foo)))" />
		</sch:rule>

		<sch:rule context="bar">
			<sch:report id="global-context-while-validating-bar-is-root-document-node-of-bar"
				test="$test:global-context is (root() treat as document-node(element(bar)))" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
