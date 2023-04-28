<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- The purpose of this file is to override the process-assert
        and process-report templates in iso_svrl_for_xslt2.xsl
        to avoid using test="{$test}" on an element. That syntax
        does not work when $test contains curly braces as in
        https://github.com/xspec/xspec/issues/1618
-->

    <xsl:include href="../src/schematron/preprocessor.xsl" />

    <xsl:import _href="{$x:schematron-preprocessor?stylesheets?3}" />

    <!--
Open Source Initiative OSI - The MIT License:Licensing
[OSI Approved License]

This source code was previously available under the zlib/libpng license. 
Attribution is polite.

The MIT License

Copyright (c) 2004-2010 Rick Jellife and Academia Sinica Computing Centre, Taiwan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-->

    <xsl:template name="process-assert">
        <xsl:param name="test"/>
        <xsl:param name="diagnostics" />
        <xsl:param name="properties" />
        <xsl:param name="id" />
        <xsl:param name="flag" />
        <!-- "Linkable" parameters -->
        <xsl:param name="role"/>
        <xsl:param name="subject"/>
        <!-- "Rich" parameters -->
        <xsl:param name="fpi" />
        <xsl:param name="icon" />
        <xsl:param name="lang" />
        <xsl:param name="see" />
        <xsl:param name="space" />
        <svrl:failed-assert>
            <!-- xspec override for Issue 1618: Use xsl:attribute for test instead of test="{$test}" in case $test contains curly braces -->
            <axsl:attribute name="test">
                <xsl:value-of select=" $test " />
            </axsl:attribute>
            <xsl:if test="string-length( $id ) &gt; 0">
                <axsl:attribute name="id">
                    <xsl:value-of select=" $id " />
                </axsl:attribute>
            </xsl:if>
            <xsl:if test=" string-length( $flag ) &gt; 0">
                <axsl:attribute name="flag">
                    <xsl:value-of select=" $flag " />
                </axsl:attribute>
            </xsl:if>
            <!-- Process rich attributes.  -->
            <xsl:call-template name="richParms">
                <xsl:with-param name="fpi" select="$fpi"/>
                <xsl:with-param name="icon" select="$icon"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="see" select="$see" />
                <xsl:with-param name="space" select="$space" />
            </xsl:call-template>
            <xsl:call-template name='linkableParms'>
                <xsl:with-param name="role" select="$role" />
                <xsl:with-param name="subject" select="$subject"/>
            </xsl:call-template>
            <xsl:if test=" $generate-paths = 'true' or $generate-paths= 'yes' ">
                <!-- true/false is the new way -->
                <axsl:attribute name="location">
                    <axsl:apply-templates select="." mode="schematron-select-full-path"/>
                </axsl:attribute>
            </xsl:if>
            
            <svrl:text>
                <xsl:apply-templates mode="text" />
                
            </svrl:text>
            <xsl:if test="$diagnose = 'yes' or $diagnose= 'true' ">
                <!-- true/false is the new way -->
                <xsl:call-template name="diagnosticsSplit">
                    <xsl:with-param name="str" select="$diagnostics"/>
                </xsl:call-template>
            </xsl:if>
            
            
            <xsl:if test="$property= 'yes' or $property= 'true' ">
                <!-- true/false is the new way -->
                <xsl:call-template name="propertiesSplit">
                    <xsl:with-param name="str" select="$properties"/>
                </xsl:call-template>
            </xsl:if>
            
        </svrl:failed-assert>
        
        
        <xsl:if test=" $terminate = 'yes' or $terminate = 'true' ">
            <axsl:message terminate="yes">TERMINATING</axsl:message>
        </xsl:if>
        <xsl:if test=" $terminate = 'assert' ">
            <axsl:message terminate="yes">TERMINATING</axsl:message>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="process-report">
        <xsl:param name="id"/>
        <xsl:param name="test"/>
        <xsl:param name="diagnostics"/>
        <xsl:param name="flag" />
        <xsl:param name="properties"/>
        <!-- "Linkable" parameters -->
        <xsl:param name="role"/>
        <xsl:param name="subject"/>
        <!-- "Rich" parameters -->
        <xsl:param name="fpi" />
        <xsl:param name="icon" />
        <xsl:param name="lang" />
        <xsl:param name="see" />
        <xsl:param name="space" />
        <svrl:successful-report >
            <!-- xspec override for Issue 1618: Use xsl:attribute for test instead of test="{$test}" in case $test contains curly braces -->
            <axsl:attribute name="test">
                <xsl:value-of select=" $test " />
            </axsl:attribute>
            <xsl:if test=" string-length( $id ) &gt; 0">
                <axsl:attribute name="id">
                    <xsl:value-of select=" $id " />
                </axsl:attribute>
            </xsl:if>
            <xsl:if test=" string-length( $flag ) &gt; 0">
                <axsl:attribute name="flag">
                    <xsl:value-of select=" $flag " />
                </axsl:attribute>
            </xsl:if>
            
            <!-- Process rich attributes.  -->
            <xsl:call-template name="richParms">
                <xsl:with-param name="fpi" select="$fpi"/>
                <xsl:with-param name="icon" select="$icon"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="see" select="$see" />
                <xsl:with-param name="space" select="$space" />
            </xsl:call-template>
            <xsl:call-template name='linkableParms'>
                <xsl:with-param name="role" select="$role" />
                <xsl:with-param name="subject" select="$subject"/>
            </xsl:call-template>
            <xsl:if test=" $generate-paths = 'yes' or $generate-paths = 'true' ">
                <!-- true/false is the new way -->
                <axsl:attribute name="location">
                    <axsl:apply-templates select="." mode="schematron-select-full-path"/>
                </axsl:attribute>
            </xsl:if>
            
            <svrl:text>
                <xsl:apply-templates mode="text" />
                
            </svrl:text>
            <xsl:if test="$diagnose = 'yes' or $diagnose='true' ">
                <!-- true/false is the new way -->
                <xsl:call-template name="diagnosticsSplit">
                    <xsl:with-param name="str" select="$diagnostics"/>
                </xsl:call-template>
            </xsl:if>
            
            
            <xsl:if test="$property = 'yes' or $property='true' ">
                <!-- true/false is the new way -->
                <xsl:call-template name="propertiesSplit">
                    <xsl:with-param name="str" select="$properties"/>
                </xsl:call-template>
            </xsl:if>
            
            
        </svrl:successful-report>
        
        
        <xsl:if test=" $terminate = 'yes' or $terminate = 'true' ">
            <axsl:message terminate="yes"  >TERMINATING</axsl:message>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>