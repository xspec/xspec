<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <sch:ns prefix="e" uri="example" />

    <xsl:function name="e:add" as="xs:integer">
        <xsl:param name="a" as="xs:integer"/>
        <xsl:param name="b" as="xs:integer"/>
        <xsl:sequence select="$a + $b"/>
    </xsl:function>

    <!-- SchXslt 1.6.2 seems to require at least one sch:pattern to exist -->
    <sch:pattern id="Dummy-pattern-for-SchXslt___DO-NOT-USE-ME">
        <!-- SchXslt 967c828 seems to require at least one sch:rule to exist -->
        <sch:rule context="Dummy-rule-for-SchXslt___DO-NOT-USE-ME" />
    </sch:pattern>

</sch:schema>