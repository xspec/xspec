<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern id="pattern1">
        <sch:rule context="para" id="rule1">
            <sch:assert test="false()" id="assert1"/>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="pattern2">
        <sch:rule context="para" id="rule2">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="pattern3">
        <sch:rule context="para">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    <sch:include href="schematron-020-01.sch#include1-pattern1"/>
    <sch:include href="schematron-020-01.sch#include1-pattern2"/>
    <sch:include href="schematron-020-01.sch#include1-pattern3"/>
    <sch:pattern id="pattern4">
        <sch:include href="schematron-020-01.sch#include1-rule4"/>
    </sch:pattern>
    <sch:pattern id="pattern5">
        <sch:include href="schematron-020-01.sch#include1-rule5"/>
    </sch:pattern>
    <sch:pattern id="pattern6">
        <sch:rule context="para">
            <sch:include href="schematron-020-01.sch#include1-assert6"/>
        </sch:rule>
    </sch:pattern>
</sch:schema>