<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       saxon-xquery-harness.xproc                               -->
<!--  Author:     Florent Georges                                          -->
<!--  Date:       2011-08-30                                               -->
<!--  URI:        http://xspec.googlecode.com/                             -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2011 Florent Georges (see end of file.)              -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.jenitennison.com/xslt/xspec" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://www.jenitennison.com/xslt/xspec/saxon/harness/xquery.xproc" name="saxon-xquery-harness" type="t:saxon-xquery-harness" version="1.0">
    <p:documentation>
        <p>This pipeline executes an XSpec test suite with the Saxon embedded in Calabash.</p>
        <p><b>Primary input:</b> A XSpec test suite document.</p>
        <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
        <p>The dir where you unzipped the XSpec archive on your filesystem is passed
            in the option 'xspec-home'.</p>
    </p:documentation>

    <p:serialization port="result" indent="true" method="xhtml" encoding="UTF-8" include-content-type="true"/>

    <p:option name="xspec-home" required="true"/>

    <!-- TODO: Use the absolute URIs through the EXPath Packaging System. -->
    <p:variable name="compiler" select="resolve-uri('src/compiler/generate-query-tests.xsl', $xspec-home)"/>
    <p:variable name="formatter" select="resolve-uri('src/reporter/format-xspec-report.xsl', $xspec-home)"/>
    <p:variable name="utils-lib" select="resolve-uri('src/compiler/generate-query-utils.xql', $xspec-home)"/>

    <p:string-replace match="xsl:import/@href" name="compiler">
        <p:with-option name="replace" select="concat('''', $compiler, '''')"/>
        <p:input port="source">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:import href="..."/>
                    <xsl:template match="/">
                        <c:query>
                            <xsl:call-template name="t:generate-tests"/>
                        </c:query>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:string-replace>

    <p:xslt name="compile">
        <p:input port="source">
            <p:pipe step="saxon-xquery-harness" port="source"/>
        </p:input>
        <p:input port="stylesheet">
            <p:pipe step="compiler" port="result"/>
        </p:input>
        <p:with-param name="utils-library-at" select="$utils-lib"/>
    </p:xslt>

    <p:escape-markup name="escape"/>

    <p:xquery name="run">
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="query">
            <p:pipe step="escape" port="result"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xquery>

    <p:choose>
        <p:when test="exists(/t:report)">
            <p:load name="formatter">
                <p:with-option name="href" select="$formatter"/>
            </p:load>
            <p:xslt name="format-report">
                <p:input port="source">
                    <p:pipe step="run" port="result"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:pipe step="formatter" port="result"/>
                </p:input>
            </p:xslt>
        </p:when>
        <p:otherwise>
            <p:error code="t:ERR001">
                <p:input port="source">
                    <p:pipe step="run" port="result"/>
                </p:input>
            </p:error>
        </p:otherwise>
    </p:choose>
</p:pipeline>
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2008, 2010 Jeni Tennison                                -->
<!--                                                                       -->
<!-- The contents of this file are subject to the MIT License (see the URI -->
<!-- http://www.opensource.org/licenses/mit-license.php for details).      -->
<!--                                                                       -->
<!-- Permission is hereby granted, free of charge, to any person obtaining -->
<!-- a copy of this software and associated documentation files (the       -->
<!-- "Software"), to deal in the Software without restriction, including   -->
<!-- without limitation the rights to use, copy, modify, merge, publish,   -->
<!-- distribute, sublicense, and/or sell copies of the Software, and to    -->
<!-- permit persons to whom the Software is furnished to do so, subject to -->
<!-- the following conditions:                                             -->
<!--                                                                       -->
<!-- The above copyright notice and this permission notice shall be        -->
<!-- included in all copies or substantial portions of the Software.       -->
<!--                                                                       -->
<!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       -->
<!-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    -->
<!-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.-->
<!-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  -->
<!-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  -->
<!-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     -->
<!-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
