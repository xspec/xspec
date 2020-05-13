<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet normalizes the test result XML.
	-->

	<xsl:import href="../base/normalize.xsl" />

	<xsl:include href="_deserializer.xsl" />
	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_serializer.xsl" />
</xsl:stylesheet>
