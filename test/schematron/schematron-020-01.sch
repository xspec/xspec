<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern id="include1-pattern1">
        <sch:rule context="para" id="include1-rule1">
            <sch:assert test="false()" id="include1-assert1"/>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="include1-pattern2">
        <sch:rule context="para" id="include1-rule2">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="include1-pattern3">
        <sch:rule context="para">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    <!-- *********************************** -->
    <sch:pattern id="include1-pattern4">
        <sch:rule context="para" id="include1-rule4">
            <sch:assert test="false()" id="include1-assert4"/>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="include1-pattern5">
        <sch:rule context="para" id="include1-rule5">
            <sch:assert test="false()"/>
        </sch:rule>
    </sch:pattern>
    <!-- *********************************** -->
    <sch:pattern id="include1-pattern6">
        <sch:rule context="para" id="include1-rule6">
            <sch:assert test="false()" id="include1-assert6"/>
        </sch:rule>
    </sch:pattern>
</sch:schema>