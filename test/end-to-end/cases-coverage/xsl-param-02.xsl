<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myns="file://myNamespace">
  <!--
      xsl:param Coverage Test Case for child of xsl:template
  -->
  <xsl:template match="xsl-param">
    <root>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate01">
        <xsl:with-param name="templateParam01">500</xsl:with-param>
      </xsl:call-template>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate02">
        <xsl:with-param name="templateParam02">600</xsl:with-param>
      </xsl:call-template>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate03">
        <xsl:with-param name="templateParam03-no-el1">700</xsl:with-param>
        <xsl:with-param name="templateParam03-no-el2">700</xsl:with-param>
        <xsl:with-param name="templateParam03-elems1">700</xsl:with-param>
        <xsl:with-param name="templateParam03-elems2">700</xsl:with-param>
        <xsl:with-param name="templateParam03-elems3">700</xsl:with-param>
        <xsl:with-param name="templateParam03-cond1">700</xsl:with-param>
        <xsl:with-param name="templateParam03-cond2">700</xsl:with-param>
      </xsl:call-template>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate04">
        <xsl:with-param name="templateParam04">800</xsl:with-param>
        <xsl:with-param name="templateParam04-cond1">800</xsl:with-param>
      </xsl:call-template>
      <!-- Call Template using default xsl:param values -->
      <xsl:call-template name="paramTemplate05" />
      <xsl:call-template name="paramTemplate06" />
      <xsl:call-template name="paramTemplate07" />
      <xsl:call-template name="paramTemplate08" />
      <xsl:call-template name="paramTemplate09" />
      <xsl:call-template name="paramTemplate10" />
    </root>
  </xsl:template>
  <!-- Templates where xsl:param value is provided by caller -->
  <!-- Template param with no default - value provided by caller -->
  <xsl:template name="paramTemplate01">
    <xsl:param name="templateParam01" />
    <node type="param - template">
      <xsl:value-of select="$templateParam01" />
    </node>
  </xsl:template>
  <!-- Template param with select attribute - value provided by caller -->
  <xsl:template name="paramTemplate02">
    <xsl:param name="templateParam02" select="999" />
    <node type="param - template">
      <xsl:value-of select="$templateParam02" />
    </node>
  </xsl:template>
  <!-- Template param with inline sequence constructor - value provided by caller -->
  <xsl:template name="paramTemplate03">
    <xsl:param name="templateParam03-no-el1">999<!--abc-->999</xsl:param>   <!-- Expected miss for 999 -->
    <xsl:param name="templateParam03-no-el2"><!--abc-->999<!--abc-->999</xsl:param> <!-- Expected miss for 999 -->
    <xsl:param name="templateParam03-no-el3" as="node()+">999<!--abc-->999</xsl:param>   <!-- Expected miss for 999 -->
    <xsl:param name="templateParam03-no-el4" as="node()+"><!--abc-->999<!--abc-->999</xsl:param> <!-- Expected miss for 999 -->
    <xsl:param name="templateParam03-elems1"><a/>999<a/>999</xsl:param>     <!-- Expected miss for <a/> and 999 -->
    <xsl:param name="templateParam03-elems2">999<a/>999<a/></xsl:param>     <!-- Expected miss for <a/> and 999 -->
    <xsl:param name="templateParam03-elems3"><a/></xsl:param>               <!-- Expected miss for <a/> -->
    <xsl:param name="templateParam03-cond1">999<xsl:if test="1">999</xsl:if></xsl:param> <!-- Expected miss for 999 and xsl:if -->
    <xsl:param name="templateParam03-cond2">999<xsl:if test="0">999</xsl:if></xsl:param> <!-- Expected miss for 999 and xsl:if -->
    <node type="param - template">
      <xsl:value-of select="$templateParam03-no-el1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-no-el2" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-no-el3" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-no-el4" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-elems1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-elems2" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-elems3" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-cond1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam03-cond2" />
    </node>
  </xsl:template>
  <!-- Template param with multi-line sequence constructor - value provided by caller -->
  <xsl:template name="paramTemplate04">
    <xsl:param name="templateParam04">
      <xsl:text>9</xsl:text>                                                   <!-- Expected miss -->
      <xsl:text>9</xsl:text>                                                   <!-- Expected miss -->
      <xsl:text>9</xsl:text>                                                   <!-- Expected miss -->
    </xsl:param>
    <xsl:param name="templateParam04-cond1">
      <a/>                                                                     <!-- Expected miss -->
      <xsl:choose>                                                             <!-- Expected miss -->
        <xsl:when test="exists(irrelevant)">                                   <!-- Expected miss -->
          <xsl:value-of>999</xsl:value-of>                                     <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:otherwise>                                                        <!-- Expected miss -->
          <xsl:text>998</xsl:text>                                             <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>                                                            <!-- Expected miss -->
    </xsl:param>
    <node type="param - template">
      <xsl:value-of select="$templateParam04" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam04-cond1" />
    </node>
  </xsl:template>
  <!-- Templates where xsl:param default value is used -->
  <!-- Template param with no default - no value provided by caller, relying on default value -->
  <xsl:template name="paramTemplate05">
    <xsl:param name="templateParamEmptyString01" />
    <xsl:param name="templateParamEmptySequence01" as="text()?" />
    <node type="param - template">
      <xsl:value-of select="count($templateParamEmptyString01)" />
    </node>
    <node type="param - template">
      <xsl:value-of select="count($templateParamEmptySequence01)" />
    </node>
  </xsl:template>
  <!-- Template param with select attribute - no value provided by caller, relying on default value -->
  <xsl:template name="paramTemplate06">
    <xsl:param name="templateParamSelect01" select="900" />
    <node type="param - template">
      <xsl:value-of select="$templateParamSelect01" />
    </node>
  </xsl:template>
  <!-- Template param with inline sequence constructor - no value provided by caller,
    relying on default value -->
  <xsl:template name="paramTemplate07">
    <xsl:param name="templateParam07-no-el1">1000<!--abc-->1000<!--abc--></xsl:param>
    <xsl:param name="templateParam07-no-el2"><!--abc-->1000<!--abc-->1000</xsl:param>
    <xsl:param name="templateParam07-elems1"><a>a</a>1000<a>a</a>1000</xsl:param>
    <xsl:param name="templateParam07-elems2">1000<a>a</a>1000<a>a</a></xsl:param>
    <xsl:param name="templateParam07-elems3"><a>a</a></xsl:param>
    <xsl:param name="templateParam07-cond1">1000<xsl:if test="1">1000</xsl:if></xsl:param>
    <xsl:param name="templateParam07-cond2">1000<xsl:if test="0">1000</xsl:if></xsl:param> <!-- Expected miss for xsl:if and child -->

    <node type="param - template">
      <xsl:value-of select="$templateParam07-no-el1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam07-no-el2" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam07-elems1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam07-elems2" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam07-elems3" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam07-cond1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam07-cond2" />
    </node>
  </xsl:template>
  <!-- Template param with inline sequence constructor - no value provided by caller,
    relying on default value, and xsl:param uses @as -->
  <xsl:template name="paramTemplate08">
    <xsl:param name="templateParam08-no-el1"
      as="node()+">1100<!--abc-->1100<!--abc--></xsl:param>
    <xsl:param name="templateParam08-no-el2"
      as="node()+"><!--abc-->1100<!--abc-->1100</xsl:param>
    <xsl:param name="templateParam08-elems1"
      as="node()+"><a>a</a>1100<a>a</a>1100</xsl:param>
    <xsl:param name="templateParam08-elems2"
      as="node()+">1100<a>a</a>1100<a>a</a></xsl:param>
    <xsl:param name="templateParam08-elems3"
      as="node()+"><a>a</a></xsl:param>
    <xsl:param name="templateParam08-cond1"
      as="node()+">1100<xsl:if test="1">1100</xsl:if></xsl:param>
    <xsl:param name="templateParam08-cond2"
      as="node()+">1100<xsl:if test="0">1100</xsl:if></xsl:param> <!-- Expected miss for xsl:if and child -->

    <node type="param - template">
      <xsl:value-of select="$templateParam08-no-el1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam08-no-el2" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam08-elems1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam08-elems2" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam08-elems3" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam08-cond1" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam08-cond2" />
    </node>
  </xsl:template>
  <!-- Template param with multi-line sequence constructor - no value provided by caller,
    relying on default value. Absence of @as in xsl:param leads to document node. -->
  <xsl:template name="paramTemplate09">
    <xsl:param name="templateParam09">
      <xsl:text>1</xsl:text>
      <xsl:text>2</xsl:text>
      <xsl:text>0</xsl:text>
      <xsl:text>0</xsl:text>
    </xsl:param>
    <xsl:param name="templateParam09-cond1">
      <a>a</a>
      <xsl:choose>
        <xsl:when test="empty(irrelevant)">
          <xsl:text>1200</xsl:text>
        </xsl:when>
        <xsl:otherwise>                                                        <!-- Expected miss -->
          <xsl:text>missed</xsl:text>                                          <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>
    </xsl:param>
    <node type="param - template">
      <xsl:value-of select="$templateParam09" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam09-cond1" />
    </node>
  </xsl:template>
  <!-- Template param with multi-line sequence constructor - no value provided by caller,
    relying on default value, and xsl:param uses @as -->
  <xsl:template name="paramTemplate10">
    <xsl:param name="templateParam10" as="text()+">
      <xsl:text>1</xsl:text>
      <xsl:text>3</xsl:text>
      <xsl:text>0</xsl:text>
      <xsl:text>0</xsl:text>
    </xsl:param>
    <xsl:param name="templateParam10-cond1" as="node()+">
      <a>a</a>
      <xsl:choose>
        <xsl:when test="empty(irrelevant)">
          <xsl:text>1300</xsl:text>
        </xsl:when>
        <xsl:otherwise>                                                        <!-- Expected miss -->
          <xsl:text>missed</xsl:text>                                          <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>
    </xsl:param>
    <node type="param - template">
      <xsl:value-of select="$templateParam10" />
    </node>
    <node type="param - template">
      <xsl:value-of select="$templateParam10-cond1" />
    </node>
  </xsl:template>
</xsl:stylesheet>