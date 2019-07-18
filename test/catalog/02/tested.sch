<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="test">
			<sch:report id="report-1" test="true()">This report should be fired whenever its rule is
				fired</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
