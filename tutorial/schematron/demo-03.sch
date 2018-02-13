<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern>
        
        <sch:rule context="title">
            <sch:assert test="following-sibling::p" id="a0001">
                title should be followed by a paragraph
            </sch:assert>
            <sch:assert test="string() ne upper-case(string())" role="warn" id="a0002">
                title should not be all upper case
            </sch:assert>
        </sch:rule>
        
        <sch:rule context="p">
            <sch:report test="string-length() lt 10" id="a0003" role="warn">
                paragraph is less than 10 characters long
            </sch:report>
        </sch:rule>
        
        <sch:rule context="document" role="info" id="a0004">
            <sch:report test="section" role="info">
                the document has at least one section
            </sch:report>
        </sch:rule>
        
    </sch:pattern>
    
</sch:schema>