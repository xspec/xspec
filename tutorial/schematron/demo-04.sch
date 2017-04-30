<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:ns uri="http://example.com/ns1" prefix="ex1"/>
    <sch:ns uri="http://example.com/ns2" prefix="ex2"/>
    <sch:ns uri="http://example.com/ns3" prefix="ex3"/>
    
    <sch:pattern>
        <sch:rule context="ex1:article">
            <sch:assert test="ex2:title">article should have a title</sch:assert>
        </sch:rule>
        <sch:rule context="ex3:sec">
            <sch:assert test="ex2:para">sec should have at least one para</sch:assert>
        </sch:rule>
        <sch:rule context="figure">
            <sch:assert test="caption">figure should have a caption</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>