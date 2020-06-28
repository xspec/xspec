<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:items="x-urn:test:xspec-items"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!--
        This stylesheet defines some common items as variables so that they can be used in tests
    -->

    <!--
        All kinds of nodes
    -->

    <!-- Sequence of all kinds of nodes -->
    <xsl:variable as="node()+" name="items:all-nodes"
        select="$items:wrappable-nodes, $items:non-wrappable-nodes" />

    <!-- Sequence of nodes that can be wrapped in document node -->
    <xsl:variable as="node()+" name="items:wrappable-nodes"
        select="$items:comment, $items:document, $items:element, $items:processing-instruction, $items:text" />

    <!-- Sequence of nodes that cannot be wrapped in document node -->
    <xsl:variable as="node()+" name="items:non-wrappable-nodes"
        select="$items:attribute, $items:namespace" />

    <!-- Each node -->
    <xsl:variable as="attribute(attribute-name)" name="items:attribute">
        <xsl:attribute name="attribute-name">attribute-text</xsl:attribute>
    </xsl:variable>

    <xsl:variable as="comment()" name="items:comment">
        <xsl:comment>comment-text</xsl:comment>
    </xsl:variable>

    <xsl:variable as="document-node()" name="items:document">
        <xsl:document>document-text</xsl:document>
    </xsl:variable>

    <xsl:variable as="element(element-name)" name="items:element">
        <xsl:element name="element-name">
            <!-- Insert non wrappable nodes just in case -->
            <xsl:sequence select="$items:non-wrappable-nodes" />
            <xsl:text>element-text</xsl:text>
        </xsl:element>
    </xsl:variable>

    <xsl:variable as="namespace-node()" name="items:namespace">
        <xsl:namespace name="namespace-name">namespace-text</xsl:namespace>
    </xsl:variable>

    <xsl:variable as="processing-instruction(processing-instruction-name)"
        name="items:processing-instruction">
        <xsl:processing-instruction name="processing-instruction-name">processing-instruction-text</xsl:processing-instruction>
    </xsl:variable>

    <xsl:variable as="text()" name="items:text">
        <xsl:text>text</xsl:text>
    </xsl:variable>

    <!--
        Other namespace nodes
    -->
    <xsl:variable as="namespace-node()" name="items:another-namespace">
        <xsl:namespace name="another-namespace-name">another-namespace-text</xsl:namespace>
    </xsl:variable>

    <xsl:variable as="namespace-node()" name="items:default-namespace">
        <xsl:namespace name="">default-namespace-text</xsl:namespace>
    </xsl:variable>

    <!--
        Atomic values
    -->
    <xsl:variable as="xs:integer" name="items:integer" select="xs:integer(1)" />
</xsl:stylesheet>
