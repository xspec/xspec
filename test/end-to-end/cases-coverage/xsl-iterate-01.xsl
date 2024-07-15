<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:iterate Coverage Test Case (includes xsl:next-iteration xsl:on-completion xsl:break)
  -->
  <xsl:template match="xsl-iterate">
    <root>
      <!-- Simple xsl:iterate with no xsl:next-iteration, xsl:on-competion or xsl:break -->
      <xsl:iterate select="node">
        <node type="iterate">
          <xsl:value-of select="." />
        </node>
      </xsl:iterate>
      <!-- Simple xsl:iterate with just xsl:on-completion -->
      <xsl:iterate select="node">
        <xsl:on-completion>
          <node type="iterate/on-completion">
            <xsl:text>Complete</xsl:text>
          </node>
        </xsl:on-completion>
        <node type="iterate/on-completion">
          <xsl:value-of select="." />
        </node>
      </xsl:iterate>
      <!-- Simple xsl:iterate with just xsl:next-iteration -->
      <xsl:iterate select="node">
        <xsl:param name="param01" select="1" />
        <xsl:variable name="newValue" select="$param01 * 2" />
        <node type="iterate/next-iteration">
          <xsl:value-of select=". * $newValue" />
        </node>
        <xsl:next-iteration>
          <xsl:with-param name="param01" select="$newValue" />
        </xsl:next-iteration>
      </xsl:iterate>
      <!-- Simple xsl:iterate with xsl:break executed -->
      <xsl:iterate select="node">
        <node type="iterate/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 150">
          <xsl:break />
        </xsl:if>
      </xsl:iterate>
      <!-- Simple xsl:iterate with xsl:break not executed -->
      <xsl:iterate select="node">
        <node type="iterate/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 2500">
          <xsl:break />                                                        <!-- Expected miss -->
        </xsl:if>
      </xsl:iterate>
      <!-- xsl:iterate with xsl:next-iteration and xsl:on-completion -->
      <xsl:iterate select="node">
        <xsl:param name="param01" select="1" />
        <xsl:on-completion>
          <node type="iterate/next-iteration/on-completion">
            <xsl:text>Complete</xsl:text>
          </node>
        </xsl:on-completion>
        <xsl:variable name="newValue" select="$param01 * 2" />
        <node type="iterate/next-iteration/on-completion">
          <xsl:value-of select=". * $newValue" />
        </node>
        <xsl:next-iteration>
          <xsl:with-param name="param01" select="$newValue" />
        </xsl:next-iteration>
      </xsl:iterate>
      <!-- xsl:iterate with xsl:break executed and xsl:on-completion not executed -->
      <xsl:iterate select="node">
        <xsl:on-completion>                                                    <!-- Expected miss -->
          <node type="iterate/on-completion/break">                            <!-- Expected miss -->
            <xsl:text>Complete</xsl:text>                                      <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:on-completion>                                                   <!-- Expected miss -->
        <node type="iterate/on-completion/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 150">
          <xsl:break />
        </xsl:if>
      </xsl:iterate>
      <!-- xsl:iterate with xsl:on-completion executed and xsl:break not executed -->
      <xsl:iterate select="node">
        <xsl:on-completion>
          <node type="iterate/on-completion/break">
            <xsl:text>Complete</xsl:text>
          </node>
        </xsl:on-completion>
        <node type="iterate/on-completion/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 2500">
          <xsl:break />                                                        <!-- Expected miss -->
        </xsl:if>
      </xsl:iterate>
      <!-- xsl:iterate with xsl:break executed (xsl:break has select attribute) -->
      <xsl:iterate select="node">
        <node type="iterate/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 150">
          <xsl:break select="'break executed'" />
        </xsl:if>
      </xsl:iterate>
      <!-- xsl:iterate with xsl:break executed (xsl:break has sequence constructor) -->
      <xsl:iterate select="node">
        <node type="iterate/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 150">
          <xsl:break>
            <node type="iterate/break">
              <xsl:value-of select="." />
            </node>
          </xsl:break>
        </xsl:if>
      </xsl:iterate>
      <!-- xsl:iterate with xsl:break not executed (xsl:break has sequence constructor) -->
      <xsl:iterate select="node">
        <node type="iterate/break">
          <xsl:value-of select="." />
        </node>
        <xsl:if test=". &gt; 2400">
          <xsl:break>                                                          <!-- Expected miss -->
            <node type="iterate/break">                                        <!-- Expected miss -->
              <xsl:value-of select="." />                                      <!-- Expected miss -->
            </node>                                                            <!-- Expected miss -->
          </xsl:break>                                                         <!-- Expected miss -->
        </xsl:if>
      </xsl:iterate>

      <!-- Test cases for unknown status of xsl:on-completion -->
      <!-- xsl:iterate with xsl:on-completion not executed but unknown status -->
      <node type="iterate/on-completion unexecuted unknown">
        <xsl:iterate select="node">
          <xsl:on-completion>                                                    <!-- Expected unknown -->
            <xsl:where-populated>                                                <!-- Expected unknown -->
            </xsl:where-populated>                                               <!-- Expected unknown -->
          </xsl:on-completion>                                                   <!-- Expected unknown -->
          <xsl:if test=". &gt; 150">
            <xsl:break />
          </xsl:if>
        </xsl:iterate>
      </node>
      <!-- xsl:iterate with xsl:on-completion not executed but unknown status -->
      <node type="iterate/on-completion unexecuted unknown">
        <xsl:iterate select="node">
          <xsl:on-completion></xsl:on-completion>                              <!-- Expected unknown -->
          <xsl:if test=". &gt; 150">
            <xsl:break />
          </xsl:if>
        </xsl:iterate>
      </node>
      <!-- xsl:iterate with xsl:on-completion executed but unknown status -->
      <node type="iterate/on-completion executed unknown">
        <xsl:iterate select="node">
          <xsl:on-completion>                                                  <!-- Expected unknown -->
            <xsl:where-populated>                                              <!-- Expected unknown -->
            </xsl:where-populated>                                             <!-- Expected unknown -->
          </xsl:on-completion>                                                 <!-- Expected unknown -->
          <xsl:value-of select="concat(., ', ')" />
        </xsl:iterate>
      </node>
      <!-- xsl:iterate with xsl:on-completion executed but unknown status -->
      <node type="iterate/on-completion executed unknown">
        <xsl:iterate select="node">
          <xsl:on-completion></xsl:on-completion>                              <!-- Expected unknown -->
          <xsl:value-of select="concat(., ', ')" />
        </xsl:iterate>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>