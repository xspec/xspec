<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">

	<sch:pattern>
		<sch:rule context="text()">
			<sch:report id="report-foo" test=". eq 'foo'">Found foo</sch:report>
			<sch:report id="report-bar" test=". eq 'bar'">Found bar</sch:report>
			<sch:report id="report-baz" test=". eq 'baz'">Found baz</sch:report>
		</sch:rule>
	</sch:pattern>

</sch:schema>
