<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is just for checking to see if the XSLT processor is able to compile version 3.0 -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match=".">
		<xsl:try>
			<xsl:sequence select="
					let $map := map {'foo': 'bar'}
					return
						$map?foo" />
			<xsl:catch>
				<xsl:sequence select="[1, 2]" />
			</xsl:catch>
		</xsl:try>
	</xsl:template>
</xsl:stylesheet>
