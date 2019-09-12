module namespace x = "x-urn:test:xspec-prefix-conflict";

(: Returns the items in the parameter intact :)
declare function x:param-mirror-function(
$x:param-items as item()*
)
as item()*
{
	$x:param-items
};
