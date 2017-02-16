<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       exist-xquery-harness.xproc                               -->
<!--  Author:     Florent Georges                                          -->
<!--  Date:       2011-08-30                                               -->
<!--  URI:        http://xspec.googlecode.com/                             -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2011 Florent Georges (see end of file.)              -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.jenitennison.com/xslt/xspec" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://www.jenitennison.com/xslt/xspec/exist/harness/xquery.xproc" name="exist-harness" type="t:exist-harness" version="1.0">
    <p:documentation>
        <p>This pipeline executes an XSpec test suite on an eXist instance.</p>
        <p><b>Primary input:</b> A XSpec test suite document.</p>
        <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
        <p>The XQuery library module to test must already be on the eXist instance.
            The instance endpoint is passed in the option 'endpoint'.  The runtime
            utils library (also known as generate-query-utils.xql) must also be on
            the instance (its location hint, that is the 'at' clause to use) is
            passed in the option 'utils-lib'.  The dir where you unzipped the XSpec
            archive on your filesystem is passed in the option 'xspec-home'.</p>
    </p:documentation>

    <p:serialization port="result" indent="true" method="xhtml" encoding="UTF-8" include-content-type="true"/>

    <p:option name="xspec-home" required="true"/>
    <p:option name="query-at"/>
    <p:option name="utils-lib" select="'xmldb:exist:///db/xspec/generate-query-utils.xql'"/>
    <p:option name="endpoint" select="'http://localhost:8080/exist/rest/db/'"/>
    <!-- if set, then save the generated query at this URI -->
    <p:option name="compiled-uri"/>
    <!-- if set, then save the generated query at this URI -->
    <p:option name="report-uri"/>

    <!-- TODO: Use the absolute URIs through the EXPath Packaging System. -->
    <p:variable name="compiler" select="resolve-uri('src/compiler/generate-query-tests.xsl', $xspec-home)"/>
    <p:variable name="formatter" select="resolve-uri('src/reporter/format-xspec-report.xsl', $xspec-home)"/>

    <p:string-replace match="xsl:import/@href" name="compiler">
        <p:with-option name="replace" select="concat('''', $compiler, '''')"/>
        <p:input port="source">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:import href="..."/>
                    <xsl:template match="/">
                        <exist:text>
                            <xsl:call-template name="t:generate-tests"/>
                        </exist:text>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:string-replace>

    <p:choose>
        <p:when test="p:value-available('query-at')">
            <p:xslt name="compile">
                <p:input port="source">
                    <p:pipe step="exist-harness" port="source"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:pipe step="compiler" port="result"/>
                </p:input>
                <p:with-param name="query-at" select="$query-at"/>
                <p:with-param name="utils-library-at" select="$utils-lib"/>
            </p:xslt>
        </p:when>
        <p:otherwise>
            <p:xslt name="compile">
                <p:input port="source">
                    <p:pipe step="exist-harness" port="source"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:pipe step="compiler" port="result"/>
                </p:input>
                <p:with-param name="utils-library-at" select="$utils-lib"/>
            </p:xslt>
        </p:otherwise>
    </p:choose>

    <p:escape-markup name="escape"/>

    <p:choose>
        <p:when test="p:value-available('compiled-uri')">
            <p:store method="text">
                <p:with-option name="href" select="$compiled-uri"/>
            </p:store>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="escape" port="result"/>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>

    <p:wrap wrapper="exist:query" match="/*"/>
    <p:wrap wrapper="c:body" match="/*"/>
    <p:add-attribute attribute-name="content-type" attribute-value="application/xml" match="/*"/>
    <p:wrap wrapper="c:request" match="/*"/>
    <p:add-attribute attribute-name="method" attribute-value="POST" match="/*"/>
    <p:add-attribute attribute-name="href" match="/*">
        <p:with-option name="attribute-value" select="$endpoint"/>
    </p:add-attribute>
    <p:http-request name="run"/>
    <p:choose>
        <p:when test="exists(/exist:result/t:report)">
            <p:load name="formatter">
                <p:with-option name="href" select="$formatter"/>
            </p:load>
            <p:unwrap name="unwrap" match="/c:result">
                <p:input port="source">
                    <p:pipe step="run" port="result"/>
                </p:input>
            </p:unwrap>
            <p:xslt name="format-report">
                <p:input port="source">
                    <p:pipe step="unwrap" port="result"/>
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
