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
    <sch:pattern>
        <sch:rule context="section" id="ru1" role="error">
            <sch:assert test="title">section should have a title</sch:assert>
            <sch:assert test="p[2]" role="warn">section should contain at least 2 paragraphs</sch:assert>
            <sch:assert test="img" id="ru2">section should contain an image</sch:assert>
        </sch:rule>
        <sch:rule context="article" id="ru3" role="warn">
            <sch:assert test="div">article should contain div</sch:assert>
            <sch:report test="div[2]">article has more than 1 div</sch:report>
        </sch:rule>
    </sch:pattern>
</sch:schema>
