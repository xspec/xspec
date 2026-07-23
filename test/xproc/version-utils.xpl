<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.jenitennison.com/xslt/xspec"
    version="3.1">

    <!-- Represent a version number for XML Calabash as a scalar integer in a way that
        facilitates comparing two version numbers. -->
    <p:declare-step type="x:version-int">
        <p:input port="source">
            <p:inline>3.0.25</p:inline>
        </p:input>
        <p:output port="result"/>
        <p:xslt>
            <p:with-input port="stylesheet">
                <xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
                    xmlns:x="http://www.jenitennison.com/xslt/xspec"
                    xmlns:xs="http://www.w3.org/2001/XMLSchema"
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                    <xsl:include href="../../src/common/version-utils.xsl"/>
                    <xsl:template match="." as="xs:integer">
                        <xsl:sequence select="string(.)
                            ! concat('0.',.) (: x:extract version expects 2 or 4 digits, not 3 :)
                            => x:extract-version()
                            => x:pack-version()"/>
                    </xsl:template>
                </xsl:stylesheet>
            </p:with-input>
        </p:xslt>
    </p:declare-step>
</p:library>
