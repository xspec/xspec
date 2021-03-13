<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<sch:ns prefix="schematron-025" uri="x-urn:test:schematron-025" />

	<!-- Using a foreign (non Schematron) element, include a resource specified by a relative URI -->
	<xsl:include href="schematron-025.xsl" />

	<sch:pattern>
		<sch:rule context="element()">
			<sch:report id="report-bad-text" test="schematron-025:has-bad-text(.)">Found 'bad'
				text</sch:report>
		</sch:rule>
	</sch:pattern>

</sch:schema>
