<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process" defaultPhase="check-id">
    
    <sch:ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
    
    <sch:p>
        This Schematron Quick Fix is intended to help with adding id and role attributes to assert and report elements in a Schematron.
        
        To use this quick fix create a validation scenario in oXygen that uses this Schematron. 
        The validation scenario configuration might look something like this:
        
        <![CDATA[
            file to validate    File type           Validation engine   Auto    Schema                 Phase
            ${currentFileURL}   Schematron Document Default engine      Yes
            ${currentFileURL}   XML Document        Default engine      Yes     /path/to/quickfix.sch  #ALL
        ]]>
        
        Apply the validation scenario to validate any Schematron. 
        
        Using the check-id phase,
        each assert or report element that is missing an id attribute will be flagged.
        Click on each flagged element and use the quick fix to insert an id attribute. 
        The generated ID will be based on a running number and will use the nearest ancestor ID if there is one.
        
        Using the check-role phase,
        each assert or report element that is missing a role attribute will be flagged.
        Click on each flagged element and use the quick fix to insert a role attribute to
        make the result of the test be an 'error', 'warn', or 'info'.
    </sch:p>
    
    <sch:phase id="check-id">
        <sch:active pattern="sqf-add-id"/>
    </sch:phase>
    
    <sch:phase id="check-role">
        <sch:active pattern="sqf-add-role"/>
    </sch:phase>

    <sch:pattern id="sqf-add-id">
        <sch:rule context="sch:assert | sch:report">
            <sch:assert test="@id" sqf:fix="add-id" id="sch0001" role="warn"><sch:name/> should have an id attribute.</sch:assert>
            <sch:let name="nearest-id" value="ancestor-or-self::*[@id][1]/@id"/>
            <sch:let name="id-prefix" value="'sch'"/>
            <sqf:fix id="add-id">
                <sqf:description>
                    <sqf:title>Add id attribute</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="id" select="
                    if (not($nearest-id)) then concat($id-prefix, format-number(count(//sch:assert[@id][not(ancestor::*[@id])] | //sch:report[@id][not(ancestor::*[@id])]) + 1, '0000'))
                    else concat($nearest-id, '-', format-number(count(ancestor::*[@id = $nearest-id]//(sch:assert[@id] | sch:report[@id])) + 1, '00'))
                    "/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="sqf-add-role">
        <sch:rule context="sch:assert | sch:report">
            <sch:assert test="@role" sqf:fix="sqf-add-role-error sqf-add-role-warn sqf-add-role-info" role="warn" id="sch0002"><sch:name/> should have a role attribute.</sch:assert>
            <sqf:fix id="sqf-add-role-error">
                <sqf:description>
                    <sqf:title>Add role 'error'</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="role" select="'error'"/>
            </sqf:fix>
            <sqf:fix id="sqf-add-role-warn">
                <sqf:description>
                    <sqf:title>Add role 'warn'</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="role" select="'warn'"/>
            </sqf:fix>
            <sqf:fix id="sqf-add-role-info">
                <sqf:description>
                    <sqf:title>Add role 'info'</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="role" select="'info'"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>