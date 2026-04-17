<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt3"
    schematronEdition="2025">

    <sch:pattern>
        <sch:rule context="article">
            <sch:report test="exists(section)" id="r001">Article has at least one
                section</sch:report>
        </sch:rule>
        <sch:rule context="article/section">
            <sch:report test="true()" id="r002">Section is a child of article</sch:report>
        </sch:rule>
    </sch:pattern>

</sch:schema>
