<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet serves as a master file on Oxygen.

		This stylesheet is not necessary for testing purposes. The test target
		(../src/common/report-sequence.xsl) and the other dependency modules are included implicitly
		by the XSpec compiler.
	-->

	<xsl:include href="../src/common/report-sequence.xsl" />
	<xsl:include href="../src/common/uqname-utils.xsl" />
	<xsl:include href="../src/common/xml-report-serialization-parameters.xsl" />
	<xsl:include href="../src/common/xspec-utils.xsl" />

</xsl:stylesheet>
