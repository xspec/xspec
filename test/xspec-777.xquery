module namespace my = "my-namespace";

declare variable $my:test-doc as document-node(element(test)) := document {
	<test>document defined in SUT</test>
};

declare variable $my:test-doc-uri as xs:anyURI := xs:anyURI('URI defined in SUT');
