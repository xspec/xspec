<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:thd="http://www.jenitennison.com/xslt/xspec/helper/document-nodes"
    xmlns:thd-step="http://www.jenitennison.com/xslt/xspec/helper/document-nodes/steps"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">

    <!--
        thd:load-via-xproc uses p:load to load a document. Parameters:
            * href:      Path to the document, ready to be resolved with respect to $x:xspec-uri
            * options:   Options to pass to p:load beyond 'href'
            * xspec-uri: URI of the top-level XSpec file being executed

        Note: This function depends on the step function for thd-step:load in the companion file,
        test-helper-load.xpl. To make that step function available in an XSpec test for XProc,
        specify the .xpl file in x:helper/@xproc.
        
        <x:helper xproc="path/to/test-helper-load.xpl" stylesheet="path/to/test-helper-load.xsl"/>
    -->
    <xsl:function name="thd:load-via-xproc" as="item()*">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="xspec-uri" as="xs:anyURI"/>
        <xsl:param name="options" as="map(*)"/>
        <xsl:sequence select="thd-step:load(
            map:put($options, 'href', resolve-uri($href, $xspec-uri))
            )?result"/>
    </xsl:function>

    <xsl:function name="thd:load-via-xproc" as="item()*">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="xspec-uri" as="xs:anyURI"/>
        <xsl:sequence select="thd:load-via-xproc($href, $xspec-uri, map{})"/>
    </xsl:function>

</xsl:stylesheet>
