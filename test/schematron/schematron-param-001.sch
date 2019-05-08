<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:ns prefix="schematron-param-001" uri="schematron-param-001.xspec" />

	<sch:phase id="P1">
		<sch:active pattern="pattern-p1" />
	</sch:phase>

	<sch:pattern id="pattern-p1">
		<sch:rule context="*">
			<sch:report id="report-p1" test="true()">P1 phase is activated</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
