module namespace use-uri-qualified-name = "x-urn:test:use-uri-qualified-name";

(: Returns the items in the parameter intact :)
declare function Q{x-urn:test:use-uri-qualified-name}param-mirror-function(
$Q{x-urn:test:use-uri-qualified-name}param-items as item()*
)
as item()*
{
	$Q{x-urn:test:use-uri-qualified-name}param-items
};
