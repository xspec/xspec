<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		SchXslt 1.6.2 discards xsl:param, while it allows xsl:include. (schxslt/schxslt#154)
		Declare xsl:param indirectly via xsl:include.
	-->
	<xsl:include href="external_scenario-param.sch.included.xsl" />

	<sch:pattern>
		<sch:rule context="context-child">
			<sch:report id="run-time-user-param-is-A" test="$user-param eq 'A'" />
			<sch:report id="run-time-user-param-is-B" test="$user-param eq 'B'" />
			<sch:report id="run-time-user-param-is-C" test="$user-param eq 'C'" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
