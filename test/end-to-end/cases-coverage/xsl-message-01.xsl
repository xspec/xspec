<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:message Coverage Test Case
  -->
  <xsl:template match="xsl-message">
    <root>
      <!-- Using select attribute -->
      <node type="message">
        <xsl:text>100</xsl:text>
        <xsl:message select="string('Message: 100')" />
      </node>
      <!-- Add content in xsl:text -->
      <node type="message">
        <xsl:text>200</xsl:text>
        <xsl:message>
          <xsl:text>Message in xsl:text: 200</xsl:text>
        </xsl:message>
      </node>
      <!-- Add content in text node -->
      <node type="message">
        <xsl:text>300</xsl:text>
        <xsl:message>Message in text node: 300</xsl:message>
      </node>
      <!-- Terminate upon request -->
      <xsl:if test="@terminate eq 'select'">
        <xsl:message select="string('Terminating Message: 100')" terminate="yes"/>
        <xsl:message select="string('After terminating message')"/>            <!-- Expected miss -->
      </xsl:if>
      <xsl:if test="@terminate eq 'sequence constructor with xsl:text'">
        <xsl:message terminate="yes">
          <xsl:text>Terminating Message: 200</xsl:text>
        </xsl:message>
        <xsl:message>                                                          <!-- Expected miss -->
          <xsl:text>After terminating message</xsl:text>                       <!-- Expected miss -->
        </xsl:message>                                                         <!-- Expected miss -->
      </xsl:if>
      <xsl:if test="@terminate eq 'sequence constructor with text node'">
        <xsl:message terminate="yes">Terminating Message: 300</xsl:message>
        <xsl:message>After terminating message</xsl:message>                   <!-- Expected miss -->
      </xsl:if>
    </root>
  </xsl:template>
</xsl:stylesheet>