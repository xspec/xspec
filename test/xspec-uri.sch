<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:ns uri="http://www.jenitennison.com/xslt/xspec" prefix="x"/>

	<sch:pattern>
		<sch:let name="end-of-test-path" value="'/test/xspec-uri_schematron.xspec'" />
		<sch:let name="xspec-description-id" value="'xspec-uri_schematron'" />

		<sch:rule context="context-child">
			<sch:report id="context-child-attr-ok" test="ends-with(@attr, $end-of-test-path)" />
			<sch:report id="context-child-text-ok" test="ends-with(text(), $end-of-test-path)" />
		</sch:rule>

		<sch:rule context="x:description">
			<sch:report id="context-select-ok"
				test="string(@xml:id) eq $xspec-description-id"
				>Identified xspec-uri_schematron.xspec by its /x:description/@xml:id</sch:report>
		</sch:rule>

	</sch:pattern>
</sch:schema>
