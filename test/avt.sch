<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:let name="expected-value-avt" value="'}false{'" />
		<sch:let name="expected-value-intact" value="'}}{false()}{{'" />

		<sch:rule context="context-child">
			<sch:report id="context-child-attr-ok" test="@attr eq $expected-value-avt" />
			<sch:report id="context-child-text-ok" test="text() eq $expected-value-intact" />
		</sch:rule>

		<sch:rule context="href-doc-child">
			<sch:report id="href-doc-child-attr-ok" test="@attr eq $expected-value-intact" />
			<sch:report id="href-doc-child-text-ok" test="text() eq $expected-value-intact" />
		</sch:rule>
	</sch:pattern>
</sch:schema>
