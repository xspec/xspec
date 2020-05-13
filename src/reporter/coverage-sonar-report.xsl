<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:test="http://www.jenitennison.com/xslt/unit-test" 
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:import href="coverage-report.xsl"/>

    <xsl:param name="sonar-coverage-report-url" required="no" as="xs:anyURI" select="test:sonar-coverage-report-uri()"/>

    <xsl:template match="/">
        <xsl:apply-templates select="." mode="test:coverage-report"/>
        <xsl:apply-templates select="." mode="sonar-coverage-report-uri"/>
    </xsl:template>

    <xsl:template match="/" mode="sonar-coverage-report-uri">
        <xsl:result-document href="{$sonar-coverage-report-url}" exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="yes">
            <xsl:message select="concat('Report for SonarQube available at ',$sonar-coverage-report-url)"/>
            <coverage version="1">
                <file path="{test:xsl-file-location()}">
                    <xsl:apply-templates select="$stylesheet-trees/xsl:*" mode="sonar-coverage-report-uri"/>
                </file>
            </coverage>
        </xsl:result-document>
    </xsl:template>

    <!-- Overload -->
    <xsl:template match="xsl:stylesheet | xsl:transform" mode="sonar-coverage-report-uri">
        <xsl:variable name="stylesheet-uri" as="xs:anyURI" select="base-uri(.)"/>
        <xsl:variable name="stylesheet-tree" as="document-node()" select=".."/>
        <xsl:variable name="stylesheet-string" as="xs:string" select="unparsed-text($stylesheet-uri)"/>
        <xsl:variable name="stylesheet-lines" as="xs:string+" select="test:split-lines($stylesheet-string)"/>
        <xsl:variable name="number-of-lines" as="xs:integer" select="count($stylesheet-lines)"/>
        <xsl:variable name="number-width" as="xs:integer" select="string-length(xs:string($number-of-lines))"/>
        <xsl:variable name="number-format" as="xs:string" select=" string-join(for $i in 1 to $number-width return '0', '')"/>
        <xsl:variable name="module" as="xs:string?">
        <xsl:variable name="uri" as="xs:string" select=" if (starts-with($stylesheet-uri, '/')) then concat('file:', $stylesheet-uri) else $stylesheet-uri"/>
        <xsl:sequence select="key('modules', $uri, $trace)/@id"/>
        </xsl:variable>
        <xsl:call-template name="output-lines">
            <xsl:with-param name="stylesheet-string" select="$stylesheet-string"/>
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="number-format" tunnel="yes" select="$number-format"/>
            <xsl:with-param name="module" tunnel="yes" select="$module"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Overload -->
    <xsl:template name="output-lines" exclude-result-prefixes="#all">
        <xsl:context-item use="absent" use-when="element-available('xsl:context-item')" />
        <xsl:param name="line-number" as="xs:integer" required="no" select="0" />
        <xsl:param name="stylesheet-string" as="xs:string" required="yes" />
        <xsl:param name="node" as="node()" required="yes" />
        <xsl:param name="number-format" tunnel="yes" as="xs:string" required="yes" />
        <xsl:param name="module" tunnel="yes" as="xs:string" required="yes" />

        <xsl:variable name="analyzed">
            <xsl:analyze-string select="$stylesheet-string" regex="{$construct-regex}" flags="sx">
                <xsl:matching-substring>
                    <xsl:variable name="construct" as="xs:string" select="regex-group(1)" />
                    <xsl:variable name="rest" as="xs:string" select="regex-group(20)" />
                    <xsl:variable name="construct-lines" as="xs:string+" select="test:split-lines($construct)" />
                    <xsl:variable name="endTag" as="xs:boolean" select="regex-group(9) != ''" />
                    <xsl:variable name="emptyTag" as="xs:boolean" select="regex-group(19) != ''" />
                    <xsl:variable name="startTag" as="xs:boolean" select="not($emptyTag) and regex-group(11) != ''" />
                    <xsl:variable name="matches" as="xs:boolean" select="($node instance of text() and (regex-group(2) != '' or regex-group(7) != '')) or ($node instance of element() and ($startTag or $endTag or $emptyTag) and name($node) = (regex-group(10), regex-group(12))) or ($node instance of comment() and regex-group(3) != '') or ($node instance of processing-instruction() and regex-group(5) != '')" />
                    <xsl:variable name="coverage" as="xs:string" select="if ($matches) then test:coverage($node, $module) else 'ignored'" />
                    <xsl:for-each select="$construct-lines">
                        <xsl:if test="$coverage = 'hit'">
                            <lineToCover lineNumber="{$line-number+1}" covered="true"/>
                        </xsl:if>
                        <xsl:if test="$coverage = 'missed'">
                            <lineToCover lineNumber="{$line-number+1}" covered="false"/>
                        </xsl:if>
                    </xsl:for-each>
                    <test:residue matches="{$matches}" startTag="{$startTag}" rest="{$rest}" count="{count($construct-lines)}"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:message terminate="yes"> unmatched string: <xsl:value-of select="." /></xsl:message>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="$analyzed/node()[not(self::test:residue)]"/>
        <xsl:variable name="residue" select="$analyzed/test:residue"/>
        <xsl:if test="$residue/@rest != ''">
            <xsl:call-template name="output-lines">
                <xsl:with-param name="line-number" select="$line-number + xs:integer($residue/@count) - 1" />
                <xsl:with-param name="stylesheet-string" select="string($residue/@rest)" />
                <xsl:with-param name="node" as="node()">
                    <xsl:choose>
                        <xsl:when test="$residue/@matches = 'true'">
                            <xsl:choose>
                                <xsl:when test="$residue/@startTag = 'true'">
                                    <xsl:choose>
                                        <xsl:when test="$node/node()">
                                            <xsl:sequence select="$node/node()[1]" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="$node" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$node/following-sibling::node()">
                                            <xsl:sequence select="$node/following-sibling::node()[1]" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="$node/parent::node()" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$node"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param> 
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Function to configure the default sonar-report-url parameter-->
    <xsl:function name="test:sonar-coverage-report-uri">
                <xsl:variable name="xspecFolderPath" as="xs:anyURI" select="resolve-uri($trace/trace/x/@u)"/>
                <xsl:variable name="subBeforeDot" as="xs:string" select="substring-before($xspecFolderPath,'.')"/>
                <xsl:variable name="slash" as="xs:string" select="tokenize(substring-before($xspecFolderPath,'.'),'/')"/>
        <xsl:variable name="pathDirectory" as="xs:string" select="substring-before($subBeforeDot,$slash[last()])"/>
                <xsl:variable name="sonarReportPath" as="xs:string" select="concat($pathDirectory,'sonar-coverage-report.xml')"/>
                <xsl:value-of select="$sonarReportPath"/>
    </xsl:function>

    <!-- Function to calculate the xsl output, in order to be understood by SonarQube according to the Operating System  -->
    <xsl:function name="test:xsl-file-location">
        <xsl:variable name="absoluteXslPath" as="xs:string" select="substring-after($stylesheet-uri,'file:/')"/>
        <xsl:variable name="xslPathCorrected" as="xs:string" select="replace($absoluteXslPath,'%20',' ')"/>
        <xsl:choose>
            <xsl:when test="contains($xslPathCorrected,':/')">
                <!-- Windows os -->
                <xsl:value-of select="$xslPathCorrected"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('/',$xslPathCorrected)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>