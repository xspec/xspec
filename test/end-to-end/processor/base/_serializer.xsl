<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps serialize the document.
	-->

	<!--
		Set of serialization parameters
			The processor must override this and sync it with the serialization parameters
			of the target reporter.
	-->
	<xsl:output name="serializer:output" />
</xsl:stylesheet>
