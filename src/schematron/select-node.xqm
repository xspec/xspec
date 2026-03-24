module namespace sn = "urn:x-xspec:schematron:select-node";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";

(:
  Evaluates the given XPath expression in the context of the given source node,
  with the given namespaces.

  NOTE: This function requires BaseX's `xquery:eval` or Elemental's `util:eval` function.
:)
declare function sn:select-node(
$source-node as node(),
$expression as xs:string,
$namespaces as element(svrl:ns-prefix-in-attribute-values)*
)
as node()?
{
  let $ns-bindings as xs:string* :=
      $namespaces ! ('declare namespace ' || ./@prefix || ' = "' || ./@uri || '"; ')
  let $query := $ns-bindings || $expression
  return
    let $eval-fn := lookup(QName("http://basex.org/modules/xquery", "eval"), 2)
    return
      if (exists($eval-fn))
      then
        $eval-fn($query, map {  '': $source-node })
      else
        let $eval-fn := lookup(QName("http://exist-db.org/xquery/util", "eval-with-context"), 4)
        return
          if (exists($eval-fn))
          then
            $eval-fn($query, (), false(), $source-node)
          else
            error((), "Unable to find Basex or Elemental eval functions")
};

declare function sn:node-or-error(
$maybe-node as item()*,
$expression as xs:string,
$error-owner as xs:string
)
as item()*
{
  if ($maybe-node instance of node())
  then $maybe-node
  else
    let $description as xs:string := concat(
      'ERROR in ',
      $error-owner,
      ': Expression ',
      $expression,
      ' should point to one node.'
    )
    return error((),$description)
};