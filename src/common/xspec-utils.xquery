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
