module namespace rep = "urn:x-xspec:common:report-sequence";

import module namespace x = "http://www.jenitennison.com/xslt/xspec"
  at "../common/common-utils.xqm";

declare function rep:report-sequence(
  $sequence as item()*,
  $report-name as xs:string
) as element()
{
  let $report-namespace as xs:string := string($x:xspec-namespace)

  let $attribute-nodes as attribute()* := $sequence[. instance of attribute()]
  let $document-nodes as document-node()* := $sequence[. instance of document-node()]
  let $namespace-nodes as namespace-node()* := $sequence[. instance of namespace-node()]
  let $text-nodes as text()* := $sequence[. instance of text()]

  (: Do not set a prefix in this element name. This prefix-less name undeclares the default
    namespace that pollutes the namespaces in the content. :)
  let $content-wrapper-qname as xs:QName := QName('', 'content-wrap')

  let $report-element as element() :=
    element
      { QName($report-namespace, $report-name) }
      {
        (
          (: Empty :)
          if (empty($sequence))
          then attribute select { "()" }

          (: One or more atomic values :)
          else if ($sequence instance of xs:anyAtomicType+)
          then (
            attribute select {
              ($sequence ! rep:report-atomic-value(.))
              => string-join(',&#x0A;')
            }
          )

          (: One or more nodes of the same type which can be a child of document node :)
          else if (
            ($sequence instance of comment()+)
            or ($sequence instance of element()+)
            or ($sequence instance of processing-instruction()+)
            or ($sequence instance of text()+)
          )
          then (
            attribute select { '/' || rep:node-type($sequence[1]) || '()' },
            element { $content-wrapper-qname } {
              $sequence ! rep:report-node(.)
            }
          )

          (: Single document node :)
          else if ($sequence instance of document-node())
          then (
            (: People do not always notice '/' in the report HTML. So express it more verbosely.
              Also the expression must match the one in ../reporter/format-xspec-report.xsl. :)
            attribute select { "/self::document-node()" },
            element { $content-wrapper-qname } {
              rep:report-node($sequence)
            }
          )

          (: One or more nodes which can be stored in an element safely and without losing each position.
            Those nodes include document nodes and text nodes. By storing them in an element, they will
            be unwrapped and/or merged with adjacent nodes. When it happens, the report does not
            represent the sequence precisely. That's ok, because
              * Otherwise the report will be cluttered with pseudo elements.
              * XSpec in general including its deq:deep-equal() inclines to merge them. :)
          else if (($sequence instance of node()+) and not($attribute-nodes or $namespace-nodes))
          then (
            attribute select { "/node()" },
            element { $content-wrapper-qname } {
              $sequence ! rep:report-node(.)
            }
          )

          (: Otherwise each item needs to be represented as a pseudo element :)
          else (
            attribute select {
              concat(
                (: Select the pseudo elements :)
                '/*',

                (
                  (: If all items are instance of node, they can be expressed in @select.
                    (Document nodes are unwrapped, though.) :)
                  if ($sequence instance of node()+)
                  then (
                    let $expressions as xs:string+ := (
                      '@*'[$attribute-nodes],
                      'namespace::*'[$namespace-nodes],
                      'node()'[$sequence except ($attribute-nodes | $namespace-nodes)]
                    )
                    let $multi-expr as xs:boolean := (count($expressions) ge 2)
                    return
                      concat(
                        '/',
                        '('[$multi-expr],
                        string-join($expressions, ' | '),
                        ')'[$multi-expr]
                      )
                  )
                  else (
                    (: Not all items can be expressed in @select. Just leave the pseudo elements selected. :)
                  )
                )
              )
            },

            element { $content-wrapper-qname } {
              $sequence ! rep:report-pseudo-item(., $report-namespace)
            }
          )
        )
      }

  (: Output the report element :)
  return (
    (: TODO: If too many nodes, save the report element as an external doc :)
    $report-element
  )
};

declare %private function rep:report-pseudo-item(
  $item as item(),
  $report-namespace as xs:string
) as element()
{
  let $local-name-prefix as xs:string := 'pseudo-'
  return (
    if ($item instance of xs:anyAtomicType) then
      element
        { QName($report-namespace, ($local-name-prefix || 'atomic-value')) }
        { rep:report-atomic-value($item) }

    else if ($item instance of node()) then
      element
        { QName($report-namespace, ($local-name-prefix || rep:node-type($item))) }
        { rep:report-node($item) }

    else if (rep:instance-of-function($item)) then
      element
        { QName($report-namespace, ($local-name-prefix || rep:function-type($item))) }
        { rep:serialize-adaptive($item) }

    else
      element
        { QName($report-namespace, ($local-name-prefix || 'other')) }
        {}
  )
};

(:
  Copies the nodes while wrapping whitespace-only text nodes in <x:ws>
:)
declare %private function rep:report-node(
  $node as node()
) as node()
{
  if (($node instance of text()) and not(normalize-space($node))) then
    element { QName($x:xspec-namespace, 'ws') } { $node }

  else if ($node instance of document-node()) then
    document {
      $node/child::node() ! rep:report-node(.)
    }

  else if ($node instance of element()) then
    element { node-name($node) } {
      (
        in-scope-prefixes($node)
        ! namespace { . } { namespace-uri-for-prefix(., $node) }
      ),
      $node/attribute(),
      ($node/child::node() ! rep:report-node(.))
    }

  else $node
};

(:
  This function should be %private. But ../../test/report-sequence.xspec requires this to be exposed.
:)
declare function rep:report-atomic-value(
  $value as xs:anyAtomicType
) as xs:string
{
  typeswitch ($value)
    (: Derived types must be handled before their base types :)

    (: String types :)
    (: xs:normalizedString: Requires schema-aware processor :)
    case xs:string return x:quote-with-apos($value)

    (: Derived numeric types: Requires schema-aware processor :)

    (: Numeric types which can be expressed as numeric literals:
      http://www.w3.org/TR/xpath20/#id-literals :)
    case xs:integer return string($value)
    case xs:decimal return x:decimal-string($value)
    case xs:double
      return (
        if (string($value) = ('NaN', 'INF', '-INF')) then
          rep:report-atomic-value-as-constructor($value)
        else
          rep:serialize-adaptive($value)
      )

    case xs:QName return x:QName-expression($value)

    default return rep:report-atomic-value-as-constructor($value)
};

declare %private function rep:report-atomic-value-as-constructor(
  $value as xs:anyAtomicType
) as xs:string
{
  (: Constructor usually has the same name as type :)
  let $constructor-name as xs:string := rep:atom-type($value)

  (: Cast as either xs:integer or xs:string :)
  let $casted-value as xs:anyAtomicType := (
    if ($value instance of xs:integer) then
      (: Force casting down to integer, by first converting to string :)
      (string($value) cast as xs:integer)
    else
      string($value)
  )

  (: Constructor parameter:
    Either numeric literal of integer or string literal :)
  let $costructor-param as xs:string :=
    rep:report-atomic-value($casted-value)

  return ($constructor-name || '(' || $costructor-param || ')')
};

(:
  This function should be %private. But ../../test/report-sequence.xspec requires this to be exposed.
:)
declare function rep:atom-type(
  $value as xs:anyAtomicType
) as xs:string
{
  let $local-name as xs:string := (
    typeswitch ($value)
      (: Grouped as the spec does: http://www.w3.org/TR/xslt20/#built-in-types
        Groups are in the reversed order so that the derived types are before the primitive types,
        otherwise xs:integer is recognised as xs:decimal, xs:yearMonthDuration as xs:duration, and so on. :)

      (: A schema-aware XSLT processor additionally supports: :)

      (:    * All other built-in types defined in [XML Schema Part 2] :)
      (: Requires schema-aware processor :)

      (: Every XSLT 2.0 processor includes the following named type definitions in the in-scope schema components: :)

      (:    * The following types defined in [XPath 2.0] :)
      case xs:yearMonthDuration return 'yearMonthDuration'
      case xs:dayTimeDuration   return 'dayTimeDuration'
      (: xs:anyAtomicType: Abstract :)
      (: xs:untyped: Not atomic :)
      case xs:untypedAtomic     return 'untypedAtomic'

      (:    * The types xs:anyType and xs:anySimpleType. :)
      (: Not atomic :)

      (:    * The derived atomic type xs:integer defined in [XML Schema Part 2]. :)
      case xs:integer return 'integer'

      (:    * All the primitive atomic types defined in [XML Schema Part 2], with the exception of xs:NOTATION. :)
      case xs:string       return 'string'
      case xs:boolean      return 'boolean'
      case xs:decimal      return 'decimal'
      case xs:double       return 'double'
      case xs:float        return 'float'
      case xs:date         return 'date'
      case xs:time         return 'time'
      case xs:dateTime     return 'dateTime'
      case xs:duration     return 'duration'
      case xs:QName        return 'QName'
      case xs:anyURI       return 'anyURI'
      case xs:gDay         return 'gDay'
      case xs:gMonthDay    return 'gMonthDay'
      case xs:gMonth       return 'gMonth'
      case xs:gYearMonth   return 'gYearMonth'
      case xs:gYear        return 'gYear'
      case xs:base64Binary return 'base64Binary'
      case xs:hexBinary    return 'hexBinary'
      default              return 'anyAtomicType'
  )
  return
    ('Q{http://www.w3.org/2001/XMLSchema}' || $local-name)
};

declare %private function rep:serialize-adaptive(
  $item as item()
) as xs:string
{
  serialize(
    $item,
    map {
      'indent': true(),
      'method': 'adaptive'
    }
  )
};

(:
  Returns node type
    Example: 'element'

  This function should be %private. But ../../test/report-sequence.xspec requires this to be exposed.
:)
declare function rep:node-type(
  $node as node()
) as xs:string
{
  if ($node instance of attribute()) then
    'attribute'
  else if ($node instance of comment()) then
    'comment'
  else if ($node instance of document-node()) then
    'document-node'
  else if ($node instance of element()) then
    'element'
  else if ($node instance of namespace-node()) then
    'namespace-node'
  else if ($node instance of processing-instruction()) then
    'processing-instruction'
  else if ($node instance of text()) then
    'text'
  else
    'node'
};

(:
  Returns true if item is function (including map and array).

  Alternative to "instance of function(*)" which is not widely available.

  This function should be %private. But ../../test/report-sequence.xspec requires this to be exposed.
:)
declare function rep:instance-of-function(
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

  This function should be %private. But ../../test/report-sequence.xspec requires this to be exposed.
:)
declare function rep:function-type(
  (: TODO: "as function(*)" :)
  $function as item()
) as xs:string
{
  typeswitch ($function)
    case array(*) return 'array'
    case map(*)   return 'map'
    default       return 'function'
};
