module namespace xspec-eqname = "x-urn:test:xspec-eqname";

(: Returns the items in the parameter intact :)
declare function Q{x-urn:test:xspec-eqname}param-mirror-function(
$Q{x-urn:test:xspec-eqname}param-items as item()*
)
as item()*
{
	$Q{x-urn:test:xspec-eqname}param-items
};
