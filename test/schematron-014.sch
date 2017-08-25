<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:ns uri="http://example.com/ns1" prefix="ex1"/>
    <sch:ns uri="http://example.com/ns2" prefix="ex2"/>
    
    <sch:pattern>
        <sch:rule context="ex1:sec">
            <sch:assert test="ex2:para" id="e001">sec should contain para</sch:assert>
        </sch:rule>
        <sch:rule context="ex2:para">
            <sch:report test="ex2:para" id="e002">para should not contain another para</sch:report>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>