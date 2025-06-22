<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:err="http://www.w3.org/2005/xqt-errors">
  <!--
      xsl:try Coverage Test Case (includes xsl:catch)
  -->
  <xsl:template match="xsl-try">
    <root>
      <!-- Using xsl:try select attribute - xsl:catch not executed-->
      <node type="try">
        <xsl:try select="string(100)">
          <xsl:catch select="'inside xsl:catch'" />                            <!-- Expected unknown -->
        </xsl:try>
      </node>
      <!-- Using xsl:try sequence constructor - xsl:catch not executed -->
      <node type="try">
        <xsl:try>
          <xsl:text>200</xsl:text>
          <xsl:catch />                                                        <!-- Expected unknown -->
        </xsl:try>
      </node>
      <!-- Using xsl:try select attribute - xsl:catch select attribute executed-->
      <node type="try/catch">
        <xsl:try select="error()">
          <xsl:catch select="string(300)" />                                   <!-- Expected unknown -->
        </xsl:try>
      </node>
      <!-- Using xsl:try select attribute - xsl:catch executed but no-op-->
      <node type="try/catch">
        <xsl:try select="error()">
          <xsl:catch />                                                        <!-- Expected unknown -->
        </xsl:try>
      </node>
      <!-- Using xsl:try sequence constructor - second xsl:catch sequence constructor executed-->
      <node type="try/catch">
        <xsl:try>
          <xsl:value-of select="error()" />
          <xsl:catch errors="err:FOAR0001"> <!-- divide by zero error -->      <!-- Expected miss -->
            <xsl:text>999</xsl:text>                                           <!-- Expected miss -->
          </xsl:catch>                                                         <!-- Expected miss -->
          <xsl:catch errors="err:FOER0000"> <!-- error() function error -->
            <xsl:text>400</xsl:text>
          </xsl:catch>
          <xsl:catch>                                                          <!-- Expected miss -->
            <xsl:text>999</xsl:text>                                           <!-- Expected miss -->
          </xsl:catch>                                                         <!-- Expected miss -->
        </xsl:try>
      </node>
      <!-- Nested try/catch scenario with error re-thrown -->
      <node type="try/catch">
        <xsl:try>
          <xsl:value-of select="string(999)" />
          <node type="try/catch">
            <xsl:try>
              <xsl:value-of select="string(999)" />
              <xsl:value-of select="error()" />
              <xsl:value-of select="string(999)" />                            <!-- Expected miss -->
              <xsl:catch errors="err:FOER0000"> <!-- error() function error -->
                <xsl:text>999</xsl:text>
                <xsl:value-of select="error()" /> <!-- re-throw the error -->
              </xsl:catch>
            </xsl:try>
          </node>
          <xsl:value-of select="error()" />                                    <!-- Expected miss -->
          <xsl:value-of select="string(999)" />                                <!-- Expected miss -->
          <xsl:catch errors="err:FOER0000"> <!-- error() function error -->
            <xsl:text>500</xsl:text>
          </xsl:catch>
          <xsl:catch>                                                          <!-- Expected miss -->
            <xsl:text>999</xsl:text>                                           <!-- Expected miss -->
          </xsl:catch>                                                         <!-- Expected miss -->
        </xsl:try>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>