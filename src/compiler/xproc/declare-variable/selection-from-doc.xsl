<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="#all" version="3.0">

   <xsl:function name="x:selection-from-doc" as="xs:string">
      <xsl:param name="element" as="element()"/>
      <!-- When testing XProc, if you embed nodes for an expected result and aren't filtering
         the actual result via @test, then you should receive a document node for each embedded
         child node. That is better than receiving just the embedded nodes, because if an
         XProc step returns a node at all, it's always a document node. -->
      <xsl:variable name="wrap-embedded-nodes" expand-text="yes" as="xs:string">. !
         {x:known-UQName('wrap:wrap-each')}(child::node())</xsl:variable>
      <xsl:sequence select="
            (
            $element/@select,
            '.'[$element/@href],
            $wrap-embedded-nodes[$element/self::x:expect[@port][not(@test)]],
            'node()'
            )[1]"/>
   </xsl:function>

</xsl:stylesheet>