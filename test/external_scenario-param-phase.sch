<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:schxslt="http://dmaus.name/ns/2023/schxslt"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		SchXslt2 declares schxslt:phase using global xsl:variable in its compiled schema,
		so this schema cannot itself declare the same global.
	-->

	<sch:ns uri="http://dmaus.name/ns/2023/schxslt" prefix="schxslt"/>

	<sch:phase id="A">
		<sch:active pattern="pattern-A" />
	</sch:phase>

	<sch:pattern id="pattern-A">
		<sch:rule context="context-child">
			<sch:report id="compile-time-phase-param-is-A" test="true()" />
			<sch:report id="run-time-phase-param-is-A" test="$schxslt:phase eq 'A'" />
			<sch:report id="run-time-phase-param-is-B" test="$schxslt:phase eq 'B'" />
			<sch:report id="run-time-phase-param-is-C" test="$schxslt:phase eq 'C'" />
		</sch:rule>
	</sch:pattern>

	<sch:pattern id="pattern-Z">
		<sch:rule context="context-child">
			<sch:report id="cannot-reach-inactive-pattern" test="true()" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
