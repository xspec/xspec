<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern>
        <sch:rule context="div">
            <sch:assert id="a1" role="warn" test="not(section)">A section inside a div is usually superflous</sch:assert>
            <sch:assert id="a2" role="error" test="node()">div should not be empty</sch:assert>
            <sch:report id="r1" role="warn" test="string-length(normalize-space()) gt 10">text is longer than 10 characters</sch:report>
            <sch:report id="r2" role="warn" test="img">An image was found</sch:report>
        </sch:rule>
    </sch:pattern>
</sch:schema>
