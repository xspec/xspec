<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
    xmlns:local="x-urn:xspec:test:end-to-end:processor:normalizer:local"
    xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
    xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- output serialization parameters should be in line with XSPEC_HOME/src/reporter/junit-report.xsl -->
    <xsl:output name="junit"/>
    
    <xsl:template match="/testsuites/@name" mode="local:normalize">
        <xsl:attribute name="{local-name()}" select="util:filename-and-extension(.)"/>
    </xsl:template>
    
</xsl:stylesheet>