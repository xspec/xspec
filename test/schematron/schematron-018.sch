<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern>
        <sch:rule context="para" id="r1">
            <sch:assert test="true()"/>
        </sch:rule>
        <sch:rule context="section" id="r2">
            <sch:assert test="true()"/>
        </sch:rule>
        <sch:rule context="title[position() eq 1]" id="r3">
            <sch:assert test="true()"/>
        </sch:rule>
        <sch:rule context="title[position() gt 1]" id="r4">
            <sch:assert test="true()"/>
        </sch:rule>
    </sch:pattern>
</sch:schema>