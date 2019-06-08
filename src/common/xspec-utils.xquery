module namespace x = "http://www.jenitennison.com/xslt/xspec";

(:
	Returns true if item is namespace node
:)
declare function x:instance-of-namespace(
$item as item()?
) as xs:boolean
{
	(: Unfortunately "instance of namespace-node()" is not available on XPath 2.0 :)
	($item instance of node())
	and
	not(
	($item instance of attribute())
	or ($item instance of comment())
	or ($item instance of document-node())
	or ($item instance of element())
	or ($item instance of processing-instruction())
	or ($item instance of text())
	)
};
