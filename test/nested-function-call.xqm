module namespace nested-function-call = "x-urn:test:nested-function-call";

declare function nested-function-call:createTable(
$cols as xs:integer,
$nodes as element(value)+
)
as document-node(element(table))
{
	document {
		<table>
			<colgroup>
				{
					for $i in (1 to $cols)
					return
						<col/>
				}
			</colgroup>
			<tbody>
				<tr>
					{
						for $node in subsequence($nodes, 1, $cols)
						return
							<td>{string($node)}</td>
					}
				</tr>
			</tbody>
		</table>
	}
};
