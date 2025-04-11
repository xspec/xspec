<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:equtil="urn:x-xspec:compiler:base:util:compiler-eqname-utils"
   xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="3.0">

   <xsl:function name="x:lexical-to-UQName-in-sequence-type" as="xs:string?">
      <xsl:param name="context" as="element()"/>
      <xsl:variable name="as-attribute-value" as="xs:string?" select="$context/@as"/>
      <!-- regex for UQName based on
         https://github.com/xspec/xspec/blob/fb7f63d8190a5ccfea5c6a21b2ee142164a7c92c/src/schemas/xspec.rnc#L329
       -->
      <xsl:variable as="xs:string" name="regex-for-UQName">
         <xsl:value-of xml:space="preserve">
               Q\{
                  ([^\{\}]*)                                     <!-- URI -->
               \}
               <xsl:value-of select="$equtil:capture-NCName"/>  <!-- local name -->
         </xsl:value-of>
      </xsl:variable>
      <xsl:value-of>
         <xsl:analyze-string flags="x" regex="{$regex-for-UQName}" select="$as-attribute-value">
            <xsl:matching-substring>
               <!-- First, preserve UQNames already present
                  to avoid confusion if a URI contains a colon -->
               <xsl:sequence select="."/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
               <!-- In non-matches, convert lexical QNames to UQNames -->
               <xsl:analyze-string regex="\s*({$equtil:capture-NCName}:{$equtil:capture-NCName})\s*"
                  select=".">
                  <xsl:matching-substring>
                     <xsl:variable name="lexical-qname" select="regex-group(1)" as="xs:string"/>
                     <xsl:sequence
                        select="x:UQName-from-EQName-ignoring-default-ns($lexical-qname, $context)"
                     />
                  </xsl:matching-substring>
                  <xsl:non-matching-substring>
                     <!-- Preserve content that is not a lexical QName -->
                     <xsl:sequence select="."/>
                  </xsl:non-matching-substring>
               </xsl:analyze-string>
            </xsl:non-matching-substring>
         </xsl:analyze-string>
      </xsl:value-of>
   </xsl:function>

</xsl:stylesheet>
