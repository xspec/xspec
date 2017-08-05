<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern>
        <sch:let name="list" value="doc('data/standards.xml')/list/item/text()"/>
        <sch:rule context="standard">
            <sch:assert test="text() = $list" id="t1">"<sch:value-of select="text()"/> is not in the list of standards.</sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>