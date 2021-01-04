module namespace three-dots = "x-urn:test:three-dots";

(: Empty document node :)
declare variable $three-dots:document-node_empty as document-node() := (
document {()}
);

(: Zero-length text node :)
declare variable $three-dots:text-node_zero-length as text() := (
text {""}
);

(: Namespace node generator :)
declare function three-dots:namespace-node(
$prefix as xs:string,
$namespace-uri as xs:string
)
as namespace-node()
{
	namespace {$prefix} {$namespace-uri}
};
