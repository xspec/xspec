<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:sort Coverage Test Case
  -->
  <xsl:mode name="sortMode" />
  <xsl:template match="xsl-sort">
    <root>
      <!-- xsl:for-each child, using select attribute -->
      <xsl:for-each select="*">
        <xsl:sort select="." />
        <node type="sort - for-each">
          <xsl:value-of select="." />
        </node>
      </xsl:for-each>
      <!-- xsl:for-each child, using sequence constructor -->
      <xsl:for-each select="*">
        <xsl:sort>
          <xsl:value-of select="." />
        </xsl:sort>
        <node type="sort - for-each">
          <xsl:value-of select="." />
        </node>
      </xsl:for-each>
      <!-- xsl:for-each-group child, using select attribute -->
      <xsl:for-each-group select="*" group-by="@type">
        <xsl:sort select="." />
        <node type="sort - for-each-group">
          <xsl:value-of select="sum(current-group()/.)" />
        </node>
      </xsl:for-each-group>
      <!-- xsl:for-each-group child, using sequence constructor -->
      <xsl:for-each-group select="*" group-by="@type">
        <xsl:sort>
          <xsl:value-of select="." />
        </xsl:sort>
        <node type="sort - for-each-group">
          <xsl:value-of select="sum(current-group()/.)" />
        </node>
      </xsl:for-each-group>
      <!-- apply-templates child, using select attribute -->
      <xsl:apply-templates mode="sortMode">
        <xsl:sort select="." />
      </xsl:apply-templates>
      <!-- apply-templates using sequence constructor -->
      <xsl:apply-templates mode="sortMode">
        <xsl:sort>
          <xsl:value-of select="." />
        </xsl:sort>
      </xsl:apply-templates>
      <!-- perform-sort child -->
      <xsl:variable name="sortedSet">
        <xsl:perform-sort select="node">
          <xsl:sort />
        </xsl:perform-sort>
      </xsl:variable>
      <xsl:for-each select="$sortedSet/*">
        <node type="sort - perform-sort">
          <xsl:value-of select="." />
        </node>
      </xsl:for-each>
    </root>
  </xsl:template>

  <xsl:template match="node" mode="sortMode">
    <node type="sort - apply-templates">
      <xsl:value-of select="." />
    </node>
  </xsl:template>
</xsl:stylesheet>