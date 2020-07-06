module namespace x = "http://www.jenitennison.com/xslt/xspec";

(:
	U+0027
:)
declare variable $x:apos as xs:string := "'";

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
					if ($node instance of namespace-node()) then
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
	Returns true if item is function (including map and array).
	
	Alternative to "instance of function(*)" which is not widely available.
:)
declare function x:instance-of-function(
$item as item()
) as xs:boolean
{
	if (($item instance of array(*)) or ($item instance of map(*))) then
		true()
	else
		(: TODO: Enable this 'if' when function(*) is made available on all the supported XQuery processors :)
		(:
		if ($item instance of function(*)) then
			true()
		else
		:)
		false()
};

(:
	Returns type of function (including map and array).
	
	$function must be an instance of function(*).
:)
declare function x:function-type(
(: TODO: "as function(*)" :)
$function as item()
) as xs:string
{
	typeswitch ($function)
		case array(*)
			return
				'array'
		case map(*)
			return
				'map'
		default
			return
				'function'
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
			($decimal-string || '.0')
};

(:
	Returns XPath expression of fn:QName() which represents the given xs:QName
:)
declare function x:QName-expression(
$qname as xs:QName
) as xs:string
{
	let $quoted-uri as xs:string := (
	$qname
	=> namespace-uri-from-QName()
	=> x:quote-with-apos()
	)
	return
		('QName(' || $quoted-uri || ", '" || $qname || "')")
};

(:
	Duplicates every apostrophe character in a string
	and quotes the whole string with apostrophes
:)
declare function x:quote-with-apos(
$input as xs:string
)
as xs:string
{
	let $escaped as xs:string := replace($input, $x:apos, ($x:apos || $x:apos))
	return
		($x:apos || $escaped || $x:apos)
};
