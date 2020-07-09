module namespace three-dots = "x-urn:test:three-dots";

(:
	Document node
:)
declare variable $three-dots:document-node_multiple-nodes as document-node() := (
document {
	<?pi?>,
	<!--comment-->,
	<elem/>
}
);

declare variable $three-dots:document-node_empty as document-node() := (
document {()}
);

declare variable $three-dots:document-node_three-dots as document-node() := (
document {"..."}
);

declare variable $three-dots:document-node_text as document-node() := (
document {"text"}
);

(:
	Text node
:)
declare variable $three-dots:text-node_usual as text() := (
text {"text"}
);

declare variable $three-dots:text-node_whitespace-only as text() := (
text {"&#x09;&#x0A;&#x0D;&#x20;"}
);

declare variable $three-dots:text-node_zero-length as text() := (
text {""}
);

declare variable $three-dots:text-node_three-dots as text() := (
text {"..."}
);

(:
	Namespace node
:)
declare function three-dots:namespace-node(
$prefix as xs:string,
$namespace-uri as xs:string
)
as namespace-node()
{
	namespace {$prefix} {$namespace-uri}
};
