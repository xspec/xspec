<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt3"
    schematronEdition="2025">

    <sch:pattern>
        <sch:let name="sev" value="'info'"/>
        <sch:rule context="error">
            <sch:assert test="false()" id="err" severity="error">error</sch:assert>
        </sch:rule>
        <sch:rule context="warning">
            <sch:assert test="false()" id="warn" severity="warning">warning</sch:assert>
        </sch:rule>
        <sch:rule context="info">
            <sch:assert test="false()" id="info" severity="info">info</sch:assert>
        </sch:rule>
        <sch:rule context="default-severity">
            <sch:assert test="false()" id="default">default severity</sch:assert>
        </sch:rule>
        <sch:rule context="custom-severity">
            <sch:assert test="false()" id="custom" severity="custom">custom severity</sch:assert>
        </sch:rule>
        <sch:rule context="dynamic-severity">
            <sch:assert test="false()" id="dynamic" severity="$sev">severity of 'info' from variable</sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>
