<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern>
    
        <sch:rule context="/">
            <sch:assert test="document" role="FATAL" id="a0001">
                root element must be document
            </sch:assert>
        </sch:rule>
        
        <sch:rule context="title">
            <sch:assert test="following-sibling::p" role="ERROR" id="a0002">
                title must be followed by a paragraph
            </sch:assert>
            <sch:assert test="string() ne upper-case(string())" role="WARN" id="a0003">
                title should not be all upper case
            </sch:assert>
        </sch:rule>
        
        <sch:rule context="p">
            <sch:report test="string-length() lt 10" role="WARN" id="a0004">
                paragraph is less than 10 characters long
            </sch:report>
        </sch:rule>
        
    </sch:pattern>
    
</sch:schema>