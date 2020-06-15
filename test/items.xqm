module namespace items = "x-urn:test:xspec-items";

(:
	This module defines some common items as variables so that they can be used in tests
:)

(:
	All kinds of nodes
:)

(: Sequence of all kinds of nodes :)
declare variable $items:all-nodes as node()+ := ($items:wrappable-nodes, $items:non-wrappable-nodes);

(: Sequence of nodes that can be wrapped in document node :)
declare variable $items:wrappable-nodes as node()+ := ($items:comment, $items:document, $items:element, $items:processing-instruction, $items:text);

(: Sequence of nodes that cannot be wrapped in document node :)
declare variable $items:non-wrappable-nodes as node()+ := ($items:attribute, $items:namespace);

(: Each node :)
declare variable $items:attribute as attribute(attribute-name) := attribute attribute-name {"attribute-text"};
declare variable $items:comment as comment() := comment {"comment-text"};
declare variable $items:document as document-node() := document {"document-text"};
declare variable $items:element as element(element-name) := element element-name { (: Insert non wrappable nodes just in case :)$items:non-wrappable-nodes, "element-text"};
declare variable $items:namespace as node() := namespace namespace-name {"namespace-text"};
declare variable $items:processing-instruction as processing-instruction(processing-instruction-name) := processing-instruction processing-instruction-name {"processing-instruction-text"};
declare variable $items:text as text() := text {"text"};

(:
	Other namespace nodes
:)
declare variable $items:another-namespace as node() := namespace another-namespace-name {"another-namespace-text"};
declare variable $items:default-namespace as node() := namespace {""} {"default-namespace-text"};

(:
	Atomic values
:)
declare variable $items:integer as xs:integer := xs:integer(1);
