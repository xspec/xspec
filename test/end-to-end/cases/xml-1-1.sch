<?xml version="1.1" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="test">
			<sch:report id="U0007" test="string() eq '&#x07;'" />
			<sch:report id="U0008" test="string() eq '&#x08;'" />
		</sch:rule>
	</sch:pattern>
</sch:schema>
