<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    queryBinding="xquery31">
    
    <sch:ns uri="local" prefix="local"/>

    <function xmlns="http://www.w3.org/2012/xquery">
        declare function local:add(
            $a as xs:integer,
            $b as xs:integer
        ) as xs:integer {
            $a + $b
        };
    </function>

    <sch:phase id="PhaseA">
        <sch:active pattern="Pattern1"/>
        <sch:active pattern="Pattern3"/>
        <sch:active pattern="Pattern4"/>
    </sch:phase>
    
    <sch:phase id="PhaseB">
        <sch:active pattern="Pattern2"/>
        <sch:active pattern="Pattern3"/>
        <sch:active pattern="Pattern4"/>
    </sch:phase>
    
    <sch:pattern id="Pattern1">
        <sch:rule context="//sec">
            <sch:assert test="@sec-type" id="t1-1" role="warn">
                sec element should have a sec-type attribute.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="Pattern2">
        <sch:rule context="//sec">
            <sch:assert test="@sec-type" id="t2-1" role="error">
                sec element should have a sec-type attribute.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="Pattern3">
        <sch:rule context="//sec">
            <sch:assert test="title" id="t3-1">
                section should have a title
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="Pattern4">
        <sch:rule context="//sec">
            <sch:report test="count(p) = local:add(0, 1)" id="t4-1" role="warn">
                Short section has only one paragraph.
            </sch:report>
        </sch:rule>
    </sch:pattern>

</sch:schema>