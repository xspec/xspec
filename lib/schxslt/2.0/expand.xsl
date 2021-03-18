<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:error="https://doi.org/10.5281/zenodo.1495494#error"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="sch:schema">
    <xsl:call-template name="schxslt:expand">
      <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="schxslt:expand">
    <xsl:param name="schema" as="element(sch:schema)" required="yes"/>
    <xsl:apply-templates select="$schema" mode="schxslt:expand">
      <xsl:with-param name="abstract-patterns" as="element(sch:pattern)*" tunnel="yes" select="$schema/sch:pattern[@abstract = 'true']"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Copy all other elements -->
  <xsl:template match="node() | @*" mode="schxslt:expand">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="schxslt:expand"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove abstract patterns from output -->
  <xsl:template match="sch:pattern[@abstract = 'true']"  mode="schxslt:expand"/>

  <!-- Remove abstract rules from output -->
  <xsl:template match="sch:rule[@abstract = 'true']"     mode="schxslt:expand"/>

  <!-- Instantiate an abstract rule -->
  <xsl:template match="sch:extends[@rule]" mode="schxslt:expand">
    <xsl:sequence select="ancestor::sch:schema/(sch:pattern | sch:rules)/sch:rule[@abstract = 'true'][@id = current()/@rule]/node()"/>
  </xsl:template>

  <!-- Instantiate an abstract pattern -->
  <xsl:template match="sch:pattern[@is-a]" mode="schxslt:expand">
    <xsl:param name="abstract-patterns" tunnel="yes" as="element(sch:pattern)*"/>
    <xsl:variable name="is-a" select="$abstract-patterns[@id = current()/@is-a]"/>
    <xsl:copy>
      <xsl:sequence select="@* except @is-a"/>
      <xsl:apply-templates select="(if (not(@documents)) then $is-a/@documents else (), $is-a/node())" mode="schxslt:expand">
        <xsl:with-param name="schxslt:params" select="sch:param" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- Replace placeholders in abstract pattern instance -->
  <xsl:template match="sch:assert/@test | sch:report/@test | sch:rule/@context | sch:value-of/@select | sch:pattern/@documents | sch:name/@path | sch:let/@value" mode="schxslt:expand">
    <xsl:param name="schxslt:params" as="element(sch:param)*" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="schxslt:replace-params(., $schxslt:params)"/>
  </xsl:template>

  <!-- Replace placeholders in property value -->
  <xsl:function name="schxslt:replace-params" as="xs:string?">
    <xsl:param name="src" as="xs:string"/>
    <xsl:param name="params" as="element(sch:param)*"/>
    <xsl:choose>
      <xsl:when test="empty($params)">
        <xsl:value-of select="$src"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="value" select="replace(replace($params[1]/@value, '\\', '\\\\'), '\$', '\\\$')"/>
        <xsl:variable name="src" select="replace($src, concat('(\W*)\$', $params[1]/@name, '(\W*)'), concat('$1', $value, '$2'))"/>
        <xsl:value-of select="schxslt:replace-params($src, $params[position() > 1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:transform>
