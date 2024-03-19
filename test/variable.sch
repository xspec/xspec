<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<sch:pattern>
		<sch:rule context="mycontext">
			<sch:report id="before_context" test="@role='before_context'" />
			<sch:report id="after_context" test="@role='after_context'" />
		</sch:rule>
	</sch:pattern>

</sch:schema>
