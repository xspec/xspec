<xsl:transform version="1.0"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:key name="schxslt:abstract-patterns" match="sch:pattern[@abstract = 'true']" use="@id"/>
  <xsl:key name="schxslt:params"            match="sch:pattern/sch:param"           use="generate-id(..)"/>

  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sch:pattern[@abstract = 'true']"/>
  <xsl:template match="sch:rule[@abstract = 'true']"/>

  <xsl:template match="sch:extends[@rule]">
    <xsl:if test="not((ancestor::sch:pattern|ancestor::sch:schema/sch:rules)/sch:rule[@abstract = 'true'][@id = current()/@rule])">
      <xsl:message terminate="yes">
        The current pattern defines no abstract rule named '<xsl:value-of select="@rule"/>'.
      </xsl:message>
    </xsl:if>
    <xsl:copy-of select="(ancestor::sch:pattern|ancestor::sch:schema/sch:rules)/sch:rule[@abstract = 'true'][@id = current()/@rule]/node()"/>
  </xsl:template>

  <xsl:template match="sch:pattern[@is-a]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="schxslt:pattern-instance">
        <xsl:with-param name="instanceId" select="generate-id()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="key('schxslt:abstract-patterns', @is-a)/node()" mode="schxslt:pattern-instance">
        <xsl:with-param name="instanceId" select="generate-id()"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node() | @*" mode="schxslt:pattern-instance">
    <xsl:param name="instanceId"/>
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="schxslt:pattern-instance">
        <xsl:with-param name="instanceId" select="$instanceId"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sch:pattern/@is-a" mode="schxslt:pattern-instance"/>

  <xsl:template match="sch:assert/@test | sch:report/@test | sch:rule/@context | sch:value-of/@select | sch:pattern/@documents | sch:name/@path | sch:let/@value" mode="schxslt:pattern-instance">
    <xsl:param name="instanceId"/>
    <xsl:variable name="params">
      <xsl:for-each select="key('schxslt:params', $instanceId)">
        <xsl:sort select="string-length(@name)" order="descending"/>
        <xsl:value-of select="concat('$', @name, ' ')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:attribute name="{local-name()}">
      <xsl:call-template name="schxslt:replace-params">
        <xsl:with-param name="instanceId" select="$instanceId"/>
        <xsl:with-param name="source" select="."/>
        <xsl:with-param name="params" select="normalize-space($params)"/>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="schxslt:replace-params">
    <xsl:param name="instanceId"/>
    <xsl:param name="source"/>
    <xsl:param name="params"/>

    <xsl:choose>
      <xsl:when test="normalize-space($params) != ''">
        <xsl:variable name="param">
          <xsl:choose>
            <xsl:when test="contains($params, ' ')">
              <xsl:value-of select="substring-before($params, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$params"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="replacement" select="key('schxslt:params', $instanceId)[@name = substring($param, 2)]/@value"/>

        <xsl:variable name="source-replaced">
          <xsl:call-template name="schxslt:replace-single-param">
            <xsl:with-param name="source" select="$source"/>
            <xsl:with-param name="param" select="$param"/>
            <xsl:with-param name="replacement" select="$replacement"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="contains($params, ' ')">
            <xsl:call-template name="schxslt:replace-params">
              <xsl:with-param name="instanceId" select="$instanceId"/>
              <xsl:with-param name="source" select="$source-replaced"/>
              <xsl:with-param name="params" select="substring-after($params, ' ')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$source-replaced"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="schxslt:replace-single-param">
    <xsl:param name="source"/>
    <xsl:param name="param"/>
    <xsl:param name="replacement"/>

    <xsl:choose>
      <xsl:when test="contains($source, $param)">
        <xsl:value-of select="substring-before($source, $param)"/>
        <xsl:value-of select="$replacement"/>
        <xsl:call-template name="schxslt:replace-single-param">
          <xsl:with-param name="source" select="substring-after($source, $param)"/>
          <xsl:with-param name="param" select="$param"/>
          <xsl:with-param name="replacement" select="$replacement"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:transform>
