module namespace eqname = "x-urn:test:eqname";

(: Returns the items in the parameter intact :)
declare function Q{x-urn:test:eqname}param-mirror-function(
$Q{x-urn:test:eqname}param-items as item()*
)
as item()*
{
	$Q{x-urn:test:eqname}param-items
};
