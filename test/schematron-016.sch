<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">

    <sch:pattern>
        <sch:rule context="do-assert">
            <sch:assert test="false()" id="t1"><sch:name/></sch:assert>
        </sch:rule>
        <sch:rule context="do-report">
            <sch:report test="true()" id="t2"><sch:name/></sch:report>
        </sch:rule>
    </sch:pattern>

</sch:schema>
