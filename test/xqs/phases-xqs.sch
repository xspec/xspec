<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xquery31">
    <sch:phase id="P1">
        <sch:active pattern="pattern1"/>
    </sch:phase>
    <sch:pattern id="pattern1">
        <sch:rule context="//section">
            <sch:assert test="title" id="check-title">section should have a title</sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="pattern2">
        <sch:rule context="//section">
            <sch:assert test="subtitle" id="check-subtitle">section should have a subtitle</sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
