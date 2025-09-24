<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xspec="http://www.jenitennison.com/xslt/xspec"
    xmlns:xt="x-urn:test:xproc:check-options"
    version="3.0">
    <p:import href="../src/xproc3/run-xquery.xpl"/>
    <p:import href="../src/xproc3/run-xslt.xpl"/>

    <p:declare-step type="xt:test-html-report-theme">
        <p:output port="result"/>
        <xspec:run-xquery p:message="&#10;--- Testing html-report-theme ---">
            <p:with-input href="../tutorial/xquery-tutorial.xspec"/>
            <p:with-option name="xspec-home" select="resolve-uri('../')"/>
            <p:with-option name="html-report-theme" select="'whiteblack'"/>
        </xspec:run-xquery>
        <p:xslt name="verify-html-report-theme">
            <p:with-input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:h="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">
                        <xsl:template match="/">
                            <xsl:if
                                test="empty(/h:html/h:head/h:link[@rel='stylesheet'][ends-with(@href,'/test-report-colors-whiteblack.css')])">
                                <message>html-report-theme: Did not find test-report-colors-whiteblack.css</message>
                            </xsl:if>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:with-input>
        </p:xslt>
    </p:declare-step>

    <p:declare-step type="xt:test-force-focus">
        <p:output port="result"/>
        <p:option name="force-focus-value" as="xs:string" select="'#none'"/>
        <p:option name="expected-pending-value" as="xs:string" select="'0'"/>
        <xspec:run-xslt name="exercise-force-focus-none"
            p:message="&#10;--- Testing force-focus with value {$force-focus-value} ---">
            <p:with-input href="end-to-end/cases/focus-without-pending.xspec"/>
            <p:with-option name="xspec-home" select="resolve-uri('../')"/>
            <p:with-option name="force-focus" select="$force-focus-value"/>
        </xspec:run-xslt>
        <p:xslt name="verify-force-focus-none">
            <p:with-input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:h="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all">
                        <xsl:param name="expected-pending-value"/>
                        <xsl:template match="/">
                            <xsl:if test="empty(descendant::h:thead/h:tr/h:th[. = 'pending:&#160;' || $expected-pending-value])">
                                <message>force-focus #none: Did not find 'pending: {$expected-pending-value}'</message>
                            </xsl:if>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:with-input>
            <p:with-option name="parameters" select="map{'expected-pending-value': $expected-pending-value}"/>
        </p:xslt>
    </p:declare-step>
</p:library>