<?xml version="1.0" encoding="UTF-8"?>
<!--
	Based on
		3.13.2 Shadow Attributes
			https://www.w3.org/TR/xslt-30/#shadow-attributes
	Modifications: visibility="public", namespace URI of filter function, order of writing attributes		
-->
<xsl:package name="http://example.org/filter.xsl" package-version="1.0" version="3.0"
	xmlns:f="http://example.org/filter.xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param as="xs:string" name="filter" select="'true()'" static="yes" />

	<xsl:function as="xs:boolean" name="f:filter" visibility="public">
		<xsl:param as="element(employee)" name="e" />

		<xsl:sequence _select="$e/({$filter})" />
	</xsl:function>

</xsl:package>
<!--
  LICENSE NOTICE

  [Copyright](https://www.w3.org/Consortium/Legal/ipr-notice#Copyright) © 2017 [W3C](https://www.w3.org/)® ([MIT](https://www.csail.mit.edu/), [ERCIM](https://www.ercim.eu/), [Keio](https://www.keio.ac.jp/), [Beihang](http://ev.buaa.edu.cn/)), All Rights Reserved.
  W3C [liability](https://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer), [trademark](https://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks), [document use](https://www.w3.org/Consortium/Legal/copyright-documents), and [software licensing](http://www.w3.org/Consortium/Legal/copyright-software) rules apply.

  This software or document includes material copied from or derived from "XSL Transformations (XSLT) Version 3.0", W3C Recommendation 8 June 2017. https://www.w3.org/TR/xslt-30/
  https://www.w3.org/copyright/software-license-2023/
  
  Text of W3C Document License: ../../../../third-party-licenses/W3C-document-license-2023.txt
  Text of W3C Software License: ../../../../third-party-licenses/W3C-software-license-2023.txt
-->
