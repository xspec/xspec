<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="context-child">
			<sch:report id="context-child-fired" test="true()" />
		</sch:rule>

		<sch:rule context="context-grandchild">
			<sch:report id="context-grandchild-fired" test="true()" />
		</sch:rule>
	</sch:pattern>
</sch:schema>
