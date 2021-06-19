module namespace test-helper = "x-urn:tutorial:helper:ws-only-text:test-helper";

import module namespace x = "http://www.jenitennison.com/xslt/xspec"
at "../../../src/common/common-utils.xqm";

(:
	This test helper function just removes whitespace-only text nodes from the input node.
	All the other nodes are kept intact.
:)
declare function test-helper:remove-whitespace-only-text(
$node as node()
)
as node()?
{
	typeswitch ($node)
		case document-node()
			return
				document {
					$node/node() ! test-helper:remove-whitespace-only-text(.)
				}
		
		case element()
			return
				element {node-name($node)} {
					x:copy-of-additional-namespaces($node),
					$node/attribute(),
					$node/node() ! test-helper:remove-whitespace-only-text(.)
				}
		
		case text()
			return
				$node[normalize-space()]
		
		default
			return
				$node
};
