module namespace x = "http://www.jenitennison.com/xslt/xspec";

(:
	Returns node type
		Example: 'element'
:)
declare function x:node-type(
$node as node()
) as xs:string
{
	if ($node instance of attribute()) then
		'attribute'
	else
		if ($node instance of comment()) then
			'comment'
		else
			if ($node instance of document-node()) then
				'document-node'
			else
				if ($node instance of element()) then
					'element'
				else
					if (x:instance-of-namespace($node)) then
						'namespace-node'
					else
						if ($node instance of processing-instruction()) then
							'processing-instruction'
						else
							if ($node instance of text()) then
								'text'
							else
								'node'
};

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

(:
	Returns numeric literal of xs:decimal
		http://www.w3.org/TR/xpath20/#id-literals

		Example:
			in:  1
			out: '1.0'
:)
declare function x:decimal-string(
$decimal as xs:decimal
) as xs:string
{
	let $decimal-string as xs:string := string($decimal)
	return
		if (contains($decimal-string, '.')) then
			$decimal-string
		else
			concat($decimal-string, '.0')
};

(:
	Returns XPath expression of fn:QName() which represents the given xs:QName
:)
declare function x:QName-expression(
$qname as xs:QName
) as xs:string
{
	let $escaped-uri as xs:string :=
	replace(
	namespace-uri-from-QName($qname),
	"(')",
	'$1$1'
	)
	return
		concat(
		"QName('",
		$escaped-uri,
		"', '",
		$qname,
		"')"
		)
};
