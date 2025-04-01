<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
   name="http://example.com/csv-parser"
   package-version="1.0.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:csv="http://example.com/csv"
   exclude-result-prefixes="xs csv"
   declared-modes="yes"
   version="3.0">
    <!--
        xsl:package Coverage Test Case (includes xsl:expose)
        Package is https://www.w3.org/TR/xslt-30/#packages-csv-library-example
        Modifications: xsl:expose elements and extra comments added.
    -->

    <xsl:expose component="mode" visibility="public"
                names="csv:parse-line csv:parse-field csv:post-process" />     <!-- Expected ignored -->
    <xsl:expose component="variable" visibility="public"
                names="csv:line-separator csv:field-separator csv:quote" />    <!-- Expected ignored -->
    <xsl:expose component="variable" visibility="private"
                names="csv:validated-quote" />                                 <!-- Expected ignored -->
    <xsl:expose component="attribute-set" visibility="public"
                names="csv:field-attributes" />                                <!-- Expected ignored -->
    <xsl:expose component="function" visibility="final"
                names="csv:parse#1" />                                         <!-- Expected ignored -->
    <xsl:expose component="function" visibility="public"
                names="csv:preprocess-line#1 csv:preprocess-field#1" />        <!-- Expected ignored -->

    <!--* Mode declarations ... *-->
    <xsl:mode name="csv:parse-line" visibility="public"/>

    <xsl:mode name="csv:parse-field"
            on-no-match="shallow-copy"
            visibility="public"/>

    <xsl:mode name="csv:post-process"
            on-no-match="shallow-copy"
            visibility="public"/>

    <!--* Variable declarations ... *-->
    <xsl:variable name="csv:line-separator"
                as="xs:string"
                select="'\r\n?|\n\r?'"
                visibility="public"/>


    <xsl:variable name="csv:field-separator"
                as="xs:string"
                select="','"
                visibility="public"/>


    <xsl:variable name="csv:quote"
                as="xs:string"
                select="'&quot;'"
                visibility="public"/>


    <xsl:variable name="csv:validated-quote" visibility="private"
    as="xs:string" select="
        if (string-length($csv:quote) ne 1)
        then error(xs:QName('csv:ERR001'),
                    'Incorrect length for $csv:quote, should be 1')
        else $csv:quote"/>

    <!--* Attribute-set declaration ... *-->
    <xsl:attribute-set name="csv:field-attributes"
                    visibility="public">
        <xsl:attribute name="quoted"
                    select="if (starts-with(., $csv:validated-quote))
                            then 'yes'
                            else 'no'"/>
    </xsl:attribute-set>

    <!--* Function declarations ... *-->
    <xsl:function name="csv:parse" visibility="final">                         <!-- Expected miss -->
        <xsl:param name="input" as="xs:string"/>                               <!-- Expected miss -->
        <xsl:variable name="result" as="element()">                            <!-- Expected miss -->
            <csv>                                                              <!-- Expected miss -->
                <xsl:apply-templates
                    select="(tokenize($input, $csv:line-separator)
                            ! csv:preprocess-line(.))"
                    mode="csv:parse-line"/>                                    <!-- Expected miss -->
            </csv>                                                             <!-- Expected miss -->
        </xsl:variable>                                                        <!-- Expected miss -->
        <xsl:apply-templates select="$result"
                            mode="csv:post-process"/>                          <!-- Expected miss -->
    </xsl:function>                                                            <!-- Expected miss -->


    <xsl:function name="csv:preprocess-line"
                    as="xs:string?"
                    visibility="public">                                       <!-- Expected miss -->
        <xsl:param name="line" as="xs:string"/>                                <!-- Expected miss -->
        <xsl:sequence select="normalize-space($line)"/>                        <!-- Expected miss -->
    </xsl:function>                                                            <!-- Expected miss -->


    <xsl:function name="csv:preprocess-field"
                as="xs:string">
        <xsl:param name="field"
                as="xs:string"/>
        <xsl:sequence select="$field"/>
    </xsl:function>

    <!--* Templates ... *-->
    <xsl:template match="." mode="csv:parse-line">
        <row>
            <xsl:apply-templates
                select="tokenize(., $csv:field-separator)"
                mode="csv:parse-field"/>
        </row>
    </xsl:template>

    <xsl:template match="."
                mode="csv:parse-field"
                expand-text="yes">
        <xsl:variable name="string-body-pattern"
                    as="xs:string"
                    select="'([^' || $csv:validated-quote || ']*)'"/>
        <xsl:variable name="quoted-value"
                    as="xs:string"
                    select="$csv:validated-quote
                            || $string-body-pattern
                            || $csv:validated-quote"/>
        <xsl:variable name="unquoted-value"
                    as="xs:string"
                    select="'(.+)'"/>

        <field xsl:use-attribute-sets="csv:field-attributes">{
            csv:preprocess-field(
            replace(.,
                    $quoted-value || '|' || $unquoted-value,
                    '$1$2'))
        }</field>
    </xsl:template>

</xsl:package>
<!--
  LICENSE NOTICE

  [Copyright](https://www.w3.org/Consortium/Legal/ipr-notice#Copyright) © 2017 [W3C](https://www.w3.org/)® ([MIT](https://www.csail.mit.edu/), [ERCIM](https://www.ercim.eu/), [Keio](https://www.keio.ac.jp/), [Beihang](http://ev.buaa.edu.cn/)), All Rights Reserved.
  W3C [liability](https://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer), [trademark](https://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks), [document use](https://www.w3.org/Consortium/Legal/copyright-documents), and [software licensing](http://www.w3.org/Consortium/Legal/copyright-software) rules apply.

  This software or document includes material copied from or derived from "XSL Transformations (XSLT) Version 3.0", W3C Recommendation 8 June 2017. https://www.w3.org/TR/xslt-30/
  https://www.w3.org/copyright/software-license-2023/

  Text of W3C Document License: ../../../../third-party-licenses/W3C-document-license-2023.txt
  Text of W3C Software License: ../../../../third-party-licenses/W3C-software-license-2023.txt
-->