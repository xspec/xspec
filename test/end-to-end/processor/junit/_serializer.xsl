<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps serialize the JUnit report.
	-->

	<!--
		Set of serialization parameters
			The parameters must be in sync with XSPEC_HOME/src/reporter/junit-report.xsl.
	-->
	<xsl:output indent="yes" name="serializer:output" />
</xsl:stylesheet>
