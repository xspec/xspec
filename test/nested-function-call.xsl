<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:nested-function-call="x-urn:test:nested-function-call"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="document-node(element(table))" name="nested-function-call:createTable">
		<xsl:param as="xs:integer" name="cols" />
		<xsl:param as="element(value)+" name="nodes" />

		<xsl:document>
			<table>
				<colgroup>
					<xsl:for-each select="1 to $cols">
						<col />
					</xsl:for-each>
				</colgroup>
				<tbody>
					<tr>
						<xsl:for-each select="subsequence($nodes, 1, $cols)">
							<td>
								<xsl:value-of select="." />
							</td>
						</xsl:for-each>
					</tr>
				</tbody>
			</table>
		</xsl:document>
	</xsl:function>

</xsl:stylesheet>
