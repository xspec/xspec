<?xml version="1.0" encoding="UTF-8"?>
<!--
	This stylesheet checks the elapsed run time (obtained by /x:description/@measure-time="yes") in
	the test result report XML to see if x:description or x:scenario was properly multi-threaded.
-->
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../../src/reporter/format-xspec-report.xsl" />

	<xsl:template as="element(xhtml:html)" match="document-node()">
		<xsl:for-each select="descendant::x:*[x:scenario[empty(x:scenario)]] => one-or-more()">
			<xsl:variable as="xs:integer" name="child-scenario-count" select="count(x:scenario)" />
			<xsl:variable as="attribute(threads)?" name="description-threads"
				select="self::x:report/doc(@xspec)/x:description/@threads" />
			<xsl:variable as="xs:integer" name="expected-thread-count">
				<xsl:choose>
					<xsl:when test="($description-threads, x:label) eq '#child-scenario-count'">
						<xsl:sequence select="$child-scenario-count" />
					</xsl:when>
					<xsl:when test="($description-threads, x:label) eq '#logical-processor-count'">
						<xsl:sequence select="
								Q{java:java.lang.Runtime}getRuntime()
								=> Q{java:java.lang.Runtime}availableProcessors()" />
					</xsl:when>
					<xsl:when test="x:label eq 'XPath expression using local namespace declaration'">
						<xsl:variable as="attribute(threads)" name="threads-attribute" select="
								doc('test_scenario-threads.xspec')
								/x:description
								/x:scenario[@label eq current()/x:label]
								/@threads" />
						<xsl:evaluate namespace-context="$threads-attribute"
							xpath="$threads-attribute" />
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable as="xs:positiveInteger" name="expected-iteration-count" select="
					ceiling($child-scenario-count div $expected-thread-count)
					=> xs:positiveInteger()" />
			<xsl:variable as="xs:integer" name="sleep-period-ms"
				select="doc('sleeper.xml')/sleep/@ms" />
			<xsl:variable as="xs:dayTimeDuration" name="expected-elapsed-min" select="
					xs:dayTimeDuration('PT1S')
					* ($sleep-period-ms div 1000)
					* $expected-iteration-count" />
			<xsl:variable as="xs:dayTimeDuration" name="expected-elapsed-max" select="
					$expected-elapsed-min
					+ (: assumed overhead :) xs:dayTimeDuration('PT2S')" />
			<xsl:variable as="xs:dayTimeDuration" name="actual-elapsed" select="
					xs:dateTimeStamp(x:timestamp[@event eq 'end']/@at)
					- xs:dateTimeStamp(x:timestamp[@event eq 'start']/@at)" />
			<xsl:message terminate="
					{
						($actual-elapsed lt $expected-elapsed-min)
						or
						($actual-elapsed gt $expected-elapsed-max)
					}">
				<xsl:if test="self::x:scenario">
					<xsl:text expand-text="yes">'{x:label}' scenario containing </xsl:text>
				</xsl:if>
				<xsl:text expand-text="yes">{$child-scenario-count} scenarios took {$actual-elapsed}. Expected {$expected-elapsed-min} to {$expected-elapsed-max} with {$expected-thread-count} thread(s).</xsl:text>
			</xsl:message>
		</xsl:for-each>

		<xsl:next-match />
	</xsl:template>

</xsl:stylesheet>
