<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="text()">
			<sch:report id="above-mentioned" role="info" test="matches(., 'above-mentioned')"
				>Forbidden word: above-mentioned</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
