module namespace use-uqname = "x-urn:test:use-uqname";

(: Returns the items in the parameter intact :)
declare function Q{x-urn:test:use-uqname}param-mirror-function(
$Q{x-urn:test:use-uqname}param-items as item()*
)
as item()*
{
	$Q{x-urn:test:use-uqname}param-items
};
