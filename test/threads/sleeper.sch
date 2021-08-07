<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="sleeper.xsl" />

	<sch:ns prefix="sleeper" uri="x-urn:test:threads:sleeper" />

	<sch:pattern>
		<!-- This rule sleeps at <sleep> element for milliseconds as specified in @ms. -->
		<sch:rule context="sleep">
			<sch:report id="slept-for-a-period" test="
					(: Evaluate a dynamic value in order to prevent the function call from being
						optimized away :)
					sleeper:sleep(@ms) ge 1" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
