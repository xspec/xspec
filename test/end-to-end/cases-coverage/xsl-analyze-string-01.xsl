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
            <xsl:sequence select="string('No match')"/>                        <!-- Expected unknown -->
          </node>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
      
      <!-- Test cases for unknown status of xsl:matching-substring and xsl:non-matching-substring -->
      <!-- regex matches string so non-matching-substring not executed -->
      <node type="matching-substring executed unknown, non-matching-substring unexecuted unknown">
        <xsl:analyze-string select="'abc 123'" regex="abc 123">
          <xsl:matching-substring>                                             <!-- Expected unknown -->
              <xsl:sequence select="regex-group(0)" />                         <!-- Expected unknown -->
          </xsl:matching-substring>                                            <!-- Expected unknown -->
        <xsl:non-matching-substring>                                           <!-- Expected unknown -->
        </xsl:non-matching-substring>                                          <!-- Expected unknown -->
      </xsl:analyze-string>
      </node>
      <!-- regex doesn't match string so matching-substring not executed -->
      <node type="matching-substring unexecuted unknown, non-matching-substring executed unknown">
        <xsl:analyze-string select="'def 456 def 456'" regex="abc 123">
          <xsl:matching-substring>                                             <!-- Expected unknown -->
          </xsl:matching-substring>                                            <!-- Expected unknown -->
          <xsl:non-matching-substring>                                         <!-- Expected unknown -->
            <xsl:sequence select="string('No match')" />                       <!-- Expected unknown -->
          </xsl:non-matching-substring>                                        <!-- Expected unknown -->
        </xsl:analyze-string>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>