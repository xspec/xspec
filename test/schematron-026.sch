<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="sec">
			<sch:let name="id" value="'sec-title-text-UPPER-CASE'" />
			<sch:assert test="@id eq $id"><sch:name /> must have @id <sch:value-of select="$id"
				 /></sch:assert>
			<sch:report test="@id eq $id"><sch:name /> has @id <sch:value-of select="$id"
				 /></sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
