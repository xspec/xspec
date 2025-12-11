<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:thd="http://www.jenitennison.com/xslt/xspec/helper/document-nodes"
    version="3.0">

    <!-- The helper functions in this module are designed to make it easier to represent
        sequences of document nodes embedded in x:input, x:expect, and so on, without having the
        document nodes get merged into one. -->

    <!-- thd:rewrap-as-doc-node produces a document node for each node in $nodes,
        using the child nodes and discarding the outermost element wrapper.
        Example: (<wrap><a/><b/><wrap>, <wrap><c/><wrap>) yields a document node
        containing <a/><b/> and a document node containing <c/>.
    -->
    <xsl:function name="thd:rewrap-as-doc-node" as="document-node()*">
        <xsl:param name="elements" as="element()*"/>
        <xsl:sequence select="$elements ! thd:wrapped-child-nodes-or-empty-document-node(.)"/>
    </xsl:function>

    <!-- thd:wrap-each individually wraps each node in $nodes in a document node.
        Example: (<a/>, <b/>, <c/>) yields a document node containing <a/>,
        one containing <b/>, and one containing <c/>.
    -->
    <xsl:function name="thd:wrap-each" as="document-node()*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:for-each select="$nodes">
            <xsl:sequence select="thd:wrap-all(.)"/>
        </xsl:for-each>
    </xsl:function>

    <!-- thd:wrap-all wraps all nodes in $nodes in a single document node.
        Example: (<a/>, <b/>, <c/>) yields a document node containing <a/><b/><c/>.
    -->
    <!-- The body of thd:wrap-all is a copy of wrap:wrap-nodes in src/common/wrap/xsl.
        The reason for making a copy is that wrap.xsl is not user-facing. If necessary,
        this function can adapt to user needs without affecting wrap.xsl. -->
    <xsl:function name="thd:wrap-all" as="document-node()">
        <xsl:param name="nodes" as="node()*"/>

        <!-- $wrap aims to create an implicit document node as described
         in https://www.w3.org/TR/xslt-30/#temporary-trees.
         So its xsl:variable must not have @as or @select.
         Do not use xsl:document or xsl:copy-of: xspec/xspec#47 -->
        <xsl:variable name="wrap">
            <xsl:sequence select="$nodes"/>
        </xsl:variable>
        <xsl:sequence select="$wrap"/>
    </xsl:function>

    <!-- thd:wrapped-child-nodes-or-empty-document-node keeps child nodes but replaces
        an element as outer wrapper with a document node as outer wrapper.
        Example 1: <wrap><a/>b<wrap> yields a document node containing <a/> and the text node 'b'
        Example 2: <wrap/> yields a document node with no child nodes
    -->
    <xsl:function name="thd:wrapped-child-nodes-or-empty-document-node" as="document-node()*">
        <xsl:param name="element" as="element()"/>
        <xsl:if test="$element/@xml:base">
            <xsl:message expand-text="yes"
                >WARNING: Rewrapping content of element '{name($element)
                }' ignores xml:base='{ $element/@xml:base }'.</xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="exists($element/child::node())">
                <xsl:sequence select="thd:wrap-all($element/child::node())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:document/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
