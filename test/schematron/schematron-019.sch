<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <sch:ns uri="example" prefix="e"/>
    
    <xsl:function name="e:add" as="xs:integer">
        <xsl:param name="a" as="xs:integer"/>
        <xsl:param name="b" as="xs:integer"/>
        <xsl:value-of select="$a + $b"/>
    </xsl:function>
    
</sch:schema>