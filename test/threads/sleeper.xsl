<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" extension-element-prefixes="saxon" version="3.0"
	xmlns:Thread="java:java.lang.Thread" xmlns:saxon="http://saxon.sf.net/"
	xmlns:sleeper="x-urn:test:threads:sleeper" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the current thread ID after sleeping for the given milliseconds -->
	<xsl:function as="xs:integer" name="sleeper:sleep">
		<xsl:param as="xs:integer" name="ms" />

		<xsl:variable as="xs:integer" name="tid" select="Thread:currentThread() => Thread:getId()" />

		<xsl:message saxon:time="yes">
			<xsl:text expand-text="yes">Thread #{$tid} starts sleep</xsl:text>
		</xsl:message>

		<saxon:do action="Thread:sleep($ms)" />

		<xsl:message saxon:time="yes">
			<xsl:text expand-text="yes">Thread #{$tid} ends sleep</xsl:text>
		</xsl:message>

		<xsl:sequence select="$tid" />
	</xsl:function>

</xsl:stylesheet>
