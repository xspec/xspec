<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:analyze-string Test Case
  -->
  <xsl:template match="xsl-analyze-string">
    <root>
      <!-- regex matches string so non-matching-substring not executed -->
      <xsl:analyze-string select="'abc 123'" regex="abc 123">
        <xsl:matching-substring>
          <node type="matching-substring">
            <xsl:value-of select="regex-group(0)" />
          </node>
        </xsl:matching-substring>
        <xsl:non-matching-substring>                                           <!-- Expected miss -->
          <node type="non-matching-substring">                                 <!-- Expected miss -->
            <xsl:text>No match</xsl:text>                                      <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:non-matching-substring>                                          <!-- Expected miss -->
      </xsl:analyze-string>
      <!-- regex doesn't match string so matching-substring not executed -->
      <xsl:analyze-string select="'def 456 def 456'" regex="abc 123">
        <xsl:matching-substring>                                               <!-- Expected miss -->
          <node type="matching-substring">                                     <!-- Expected miss -->
            <xsl:value-of select="regex-group(0)" />                           <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:matching-substring>                                              <!-- Expected miss -->
        <xsl:non-matching-substring>
          <node type="non-matching-substring">
            <xsl:sequence select="string('No match')"/>
          </node>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </root>
  </xsl:template>
</xsl:stylesheet>