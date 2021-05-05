(:
	This query module just renames some elements. All the other nodes including whitespace-only
	text nodes are kept intact.
:)

module namespace test-target = "x-urn:tutorial:helper:ws-only-text:test-target";

import module namespace x = "http://www.jenitennison.com/xslt/xspec"
at "../../../src/common/common-utils.xqm";

declare function test-target:my-func(
$node as node()
)
as node()
{
	typeswitch ($node)
		case document-node()
			return
				document {
					$node/node() ! test-target:my-func(.)
				}
		
		case element()
			return
				element
				{
					(: Rename <foo> to <bar> :)
					if (node-name($node) eq xs:QName('foo')) then
						xs:QName('bar')
					
					(: Rename <bar> to <baz> :)
					else if (node-name($node) eq xs:QName('bar')) then
						xs:QName('baz')
					
					else
						node-name($node)
				}
				{
					x:copy-of-additional-namespaces($node),
					$node/attribute(),
					$node/node() ! test-target:my-func(.)
				}
		
		default
			return
				$node
};
