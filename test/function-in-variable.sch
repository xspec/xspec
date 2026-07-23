<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		SchXslt discards xsl:variable as of v1.9.5.
		It allows xsl:include before patterns (schxslt/schxslt#154).
		Declare xsl:variable indirectly via xsl:include.
	-->
	<xsl:include href="function-in-variable.xsl" />

	<sch:pattern id="dummy-pattern">
		<sch:rule context="element()" id="dummy-rule" />
	</sch:pattern>

</sch:schema>
