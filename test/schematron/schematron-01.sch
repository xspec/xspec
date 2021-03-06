<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern>
        <sch:rule context="article">
            <sch:assert test="title" id="a001">
                article should have a title
            </sch:assert>
        </sch:rule>
        <sch:rule context="section">
            <sch:assert test="title" id="a002">
                section should have a title
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>