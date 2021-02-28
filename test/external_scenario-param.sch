<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param name="phase" />

	<sch:phase id="A">
		<sch:active pattern="pattern-A" />
	</sch:phase>

	<sch:pattern id="pattern-A">
		<sch:rule context="context-child">
			<sch:report id="compile-time-phase-param-is-A" test="true()" />
			<sch:report id="run-time-phase-param-is-A" test="$phase eq 'A'" />
			<sch:report id="run-time-phase-param-is-B" test="$phase eq 'B'" />
			<sch:report id="run-time-phase-param-is-C" test="$phase eq 'C'" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
