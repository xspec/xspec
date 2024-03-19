<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Nothing is wrong in this stylesheet. "java -jar saxon.jar -it:test-me -s:source-document.xml
		-xsl:stylesheet_original.xsl" works just fine.

		But XSpec cannot test it with the default running mode, which is run-as="import".
		This stylesheet depends on the global context item. With run-as="import", XSpec does not
		provide the global context item while running the stylesheet being tested. i.e. `.` is
		absent when global variables are evaluated when this stylesheet is tested by XSpec.

		Making this stylesheet testable requires some tweaks. See stylesheet_testable.xsl.
	-->

	<xsl:global-context-item as="document-node(element(foo))" use="required" />

	<!-- This global variable depends on the global context item. -->
	<xsl:variable as="element(bar)" name="my-global-var" select="/foo/bar" />

	<xsl:template as="element(bar)" name="test-me">
		<xsl:context-item use="absent" />
		<xsl:sequence select="$my-global-var" />
	</xsl:template>

</xsl:stylesheet>
