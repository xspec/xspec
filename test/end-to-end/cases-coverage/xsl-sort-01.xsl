<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:sort Coverage Test Case
  -->
  <xsl:mode name="sortMode" />                                                 <!-- Expected ignored -->
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
      <xsl:apply-templates mode="sortMode">
        <xsl:sort>
          <xsl:choose>
            <xsl:when test="1 eq 2">                                         <!-- Expected unknown -->
              <xsl:value-of select="." />                                    <!-- Expected unknown -->
            </xsl:when>                                                      <!-- Expected unknown -->
            <xsl:otherwise>                                                  <!-- Expected unknown -->
              <xsl:value-of select="." />
            </xsl:otherwise>                                                 <!-- Expected unknown -->
          </xsl:choose>
        </xsl:sort>
      </xsl:apply-templates>
      <xsl:apply-templates mode="sortMode">
        <xsl:sort>
          <xsl:value-of select="." />
          <xsl:copy-of select="()" />
        </xsl:sort>
      </xsl:apply-templates>
      <xsl:apply-templates mode="sortMode">
        <xsl:sort>
          <xsl:value-of>
            <xsl:value-of select="." />
            <xsl:copy-of select="()" />                                        <!-- Expected unknown -->
          </xsl:value-of>
        </xsl:sort>
      </xsl:apply-templates>

      <!-- perform-sort child -->
      <xsl:variable name="sortedSet">                                          <!-- Expected miss (optim inlined) -->
        <xsl:perform-sort select="node">                                       <!-- Expected unknown -->
          <xsl:sort />                                                         <!-- Expected unknown -->
        </xsl:perform-sort>                                                    <!-- Expected unknown -->
      </xsl:variable>                                                          <!-- Expected miss (optim inlined) -->
      <xsl:for-each select="$sortedSet/*">
        <node type="sort - perform-sort">
          <xsl:value-of select="." />
        </node>
      </xsl:for-each>
      <!-- Constructs in which parent of xsl:sort is not hit -->
      <xsl:if test="exists(parent-of-sort-not-hit)">
        <xsl:for-each select="*">                                              <!-- Expected miss -->
          <xsl:sort>                                                           <!-- Expected miss -->
            <xsl:value-of select="." />                                        <!-- Expected miss -->
          </xsl:sort>                                                          <!-- Expected miss -->
          <xsl:value-of select="." />                                          <!-- Expected miss -->
        </xsl:for-each>                                                        <!-- Expected miss -->
        <xsl:for-each-group select="*" group-by="@type">                       <!-- Expected miss -->
          <xsl:sort>                                                           <!-- Expected miss -->
            <xsl:value-of select="." />                                        <!-- Expected miss -->
          </xsl:sort>                                                          <!-- Expected miss -->
          <xsl:value-of select="sum(current-group()/.)" />                     <!-- Expected miss -->
        </xsl:for-each-group>                                                  <!-- Expected miss -->
        <xsl:apply-templates mode="sortMode">                                  <!-- Expected miss -->
          <xsl:sort>                                                           <!-- Expected miss -->
            <xsl:value-of select="." />                                        <!-- Expected miss -->
          </xsl:sort>                                                          <!-- Expected miss -->
        </xsl:apply-templates>                                                 <!-- Expected miss -->
        <xsl:apply-templates mode="sortMode">                                  <!-- Expected miss -->
          <xsl:sort>                                                           <!-- Expected miss -->
            <xsl:choose>                                                       <!-- Expected miss -->
              <xsl:when test="1 eq 2">                                         <!-- Expected unknown -->
                <xsl:value-of select="." />                                    <!-- Expected unknown -->
              </xsl:when>                                                      <!-- Expected unknown -->
              <xsl:otherwise>                                                  <!-- Expected unknown -->
                <xsl:value-of select="." />                                    <!-- Expected unknown -->
              </xsl:otherwise>                                                 <!-- Expected unknown -->
            </xsl:choose>                                                      <!-- Expected miss -->
          </xsl:sort>                                                          <!-- Expected miss -->
        </xsl:apply-templates>                                                 <!-- Expected miss -->
        <xsl:apply-templates mode="sortMode">                                  <!-- Expected miss -->
          <xsl:sort>                                                           <!-- Expected miss -->
            <xsl:value-of select="." />                                        <!-- Expected miss -->
            <xsl:copy-of select="()" />                                        <!-- Expected miss -->
          </xsl:sort>                                                          <!-- Expected miss -->
        </xsl:apply-templates>                                                 <!-- Expected miss -->
        <xsl:apply-templates mode="sortMode">                                  <!-- Expected miss -->
          <xsl:sort>                                                           <!-- Expected miss -->
            <xsl:value-of>                                                     <!-- Expected miss -->
              <xsl:value-of select="." />                                      <!-- Expected unknown -->
              <xsl:copy-of select="()" />                                      <!-- Expected unknown -->
              <xsl:text>100</xsl:text>)"                                       <!-- Expected unknown -->
            </xsl:value-of>                                                    <!-- Expected miss -->
          </xsl:sort>                                                          <!-- Expected miss -->
        </xsl:apply-templates>                                                 <!-- Expected miss -->
        <xsl:perform-sort select="node">                                       <!-- Expected unknown -->
          <xsl:sort />                                                         <!-- Expected unknown -->
        </xsl:perform-sort>                                                    <!-- Expected unknown -->
      </xsl:if>
    </root>
  </xsl:template>

  <xsl:template match="node" mode="sortMode">
    <node type="sort - apply-templates">
      <xsl:value-of select="." />
    </node>
  </xsl:template>
</xsl:stylesheet>