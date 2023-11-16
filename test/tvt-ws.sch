<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">

	<sch:pattern>
		<sch:rule context="context-child">

			<!-- Writing the curly braces directly in sch:report/@test seems to break the "skeleton"
				Schematron implementation. That's why the strings are used via sch:let. -->
			<sch:let name="tvt-enabled" value="'}false{'" />

			<sch:report id="no-insignificant-ws"
				test="string() eq $tvt-enabled">Result of evaluating TVT does not preserve insignificant whitespace</sch:report>

		</sch:rule>
	</sch:pattern>

</sch:schema>
