<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!--
        This stylesheet defines some common items as variables so that they can be used in tests
    -->

    <!--
        All kinds of nodes
    -->

    <!-- Sequence of all kinds of nodes -->
    <xsl:variable as="node()+" name="all-nodes" select="$wrappable-nodes, $non-wrappable-nodes" />

    <!-- Sequence of nodes that can be wrapped in document node -->
    <xsl:variable as="node()+" name="wrappable-nodes" select="$comment, $document, $element, $processing-instruction, $text" />

    <!-- Sequence of nodes that cannot be wrapped in document node -->
    <xsl:variable as="node()+" name="non-wrappable-nodes" select="$attribute, $namespace" />

    <!-- Each node -->
    <xsl:variable as="attribute()" name="attribute">
        <xsl:attribute name="attribute-name">attribute-text</xsl:attribute>
    </xsl:variable>

    <xsl:variable as="comment()" name="comment">
        <xsl:comment>comment-text</xsl:comment>
    </xsl:variable>

    <xsl:variable as="document-node()" name="document">
        <xsl:document>document-text</xsl:document>
    </xsl:variable>

    <xsl:variable as="element()" name="element">
        <xsl:element name="element-name">
            <!-- Insert non wrappable nodes just in case -->
            <xsl:sequence select="$non-wrappable-nodes" />
            <xsl:text>element-text</xsl:text>
        </xsl:element>
    </xsl:variable>

    <xsl:variable as="node()" name="namespace">
        <xsl:namespace name="namespace-name">namespace-text</xsl:namespace>
    </xsl:variable>

    <xsl:variable as="processing-instruction()" name="processing-instruction">
        <xsl:processing-instruction name="processing-instruction-name">processing-instruction-text</xsl:processing-instruction>
    </xsl:variable>

    <xsl:variable as="text()" name="text">
        <xsl:text>text</xsl:text>
    </xsl:variable>

    <!--
        Other namespace nodes
    -->
    <xsl:variable as="node()" name="another-namespace">
        <xsl:namespace name="another-namespace-name">another-namespace-text</xsl:namespace>
    </xsl:variable>

    <xsl:variable as="node()" name="default-namespace">
        <xsl:namespace name="">default-namespace-text</xsl:namespace>
    </xsl:variable>

    <!--
        Atomic values
    -->
    <xsl:variable as="xs:integer" name="integer" select="xs:integer(1)" />
</xsl:stylesheet>
