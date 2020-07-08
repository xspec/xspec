<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="foo">
			<sch:report id="bar-exists" test="bar">Found bar</sch:report>
			<sch:report id="baz-exists" test="baz">Found baz</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
