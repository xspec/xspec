<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern id="pattern1">
        <sch:rule id="rule1" abstract="true">
            <sch:assert test="false()" id="assert1"/>
        </sch:rule>
        <sch:rule id="rule2" abstract="true">
            <sch:assert test="false()"/>
        </sch:rule>
        <sch:rule id="rule3" context="body">
            <sch:extends rule="rule1"/>
            <sch:extends rule="rule2"/>
            <sch:assert test="false()" id="assert3"/>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>