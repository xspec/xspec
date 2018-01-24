<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern id="pattern1" abstract="true">
        <sch:rule context="$element" id="rule1">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="pattern2" is-a="pattern1">
        <sch:param name="element" value="div"/>
    </sch:pattern>
    
    <sch:pattern id="pattern3" is-a="pattern1">
        <sch:param name="element" value="para"/>
    </sch:pattern>
    
    <sch:pattern id="pattern4" abstract="true">
        <sch:rule context="$element">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="pattern5" is-a="pattern4">
        <sch:param name="element" value="figure"/>
    </sch:pattern>
    
</sch:schema>