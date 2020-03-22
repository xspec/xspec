module namespace test = "http://www.jenitennison.com/xslt/unit-test";

(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(:  File:       generate-query-utils.xql                                    :)
(:  Author:     Jeni Tennison                                               :)
(:  URL:        http://github.com/xspec/xspec                               :)
(:  Tags:                                                                   :)
(:    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)             :)
(: ------------------------------------------------------------------------ :)

import module namespace x = "http://www.jenitennison.com/xslt/xspec"
  at "../common/xspec-utils.xquery";

declare namespace fn = "http://www.w3.org/2005/xpath-functions";

declare function test:deep-equal(
    $seq1 as item()*,
    $seq2 as item()*,
    $flags as xs:string
  ) as xs:boolean
{
  if ( fn:contains($flags, '1') ) then
    let $flags as xs:string := fn:translate($flags, '1', '')
      return
        if ( $seq1 instance of xs:string and $seq2 instance of text()+ ) then
          test:deep-equal($seq1, fn:string-join($seq2, ''), $flags)
        else if ( $seq1 instance of xs:double and $seq2 instance of text()+ ) then
          test:deep-equal($seq1, xs:double(fn:string-join($seq2, '')), $flags)
        else if ( $seq1 instance of xs:decimal and $seq2 instance of text()+ ) then
          test:deep-equal($seq1, xs:decimal(fn:string-join($seq2, '')), $flags)
        else if ( $seq1 instance of xs:integer and $seq2 instance of text()+ ) then
          test:deep-equal($seq1, xs:integer(fn:string-join($seq2, '')), $flags)
        else
          test:deep-equal($seq1, $seq2, $flags)
  else if ( fn:empty($seq1) or fn:empty($seq2) ) then
    fn:empty($seq1) and fn:empty($seq2)
  else if ( fn:count($seq1) = fn:count($seq2) ) then
    every $i in (1 to fn:count($seq1))
    satisfies test:item-deep-equal($seq1[$i], $seq2[$i], $flags)
  else if ( $seq1 instance of text() and $seq2 instance of text()+ ) then
    test:deep-equal($seq1, text { fn:string-join($seq2, '') }, $flags)
  else
    fn:false()
};

declare function test:item-deep-equal(
    $item1 as item(),
    $item2 as item(),
    $flags as xs:string
  ) as xs:boolean
{
  if ( $item1 instance of node() and $item2 instance of node() ) then
    test:node-deep-equal($item1, $item2, $flags)
  else if ( fn:not($item1 instance of node()) and fn:not($item2 instance of node()) ) then
    fn:deep-equal($item1, $item2)
  else
    fn:false()
};

declare function test:node-deep-equal(
    $node1 as node(),
    $node2 as node(),
    $flags as xs:string
  ) as xs:boolean
{
  if ( $node1 instance of document-node() and $node2 instance of document-node() ) then
    test:deep-equal(test:sorted-children($node1, $flags), test:sorted-children($node2, $flags), $flags)
  else if ( $node1 instance of element() and $node2 instance of element() ) then
    if ( fn:node-name($node1) eq fn:node-name($node2) ) then
      let $atts1 as attribute()* := test:sort-named-nodes($node1/@*)
      let $atts2 as attribute()* := test:sort-named-nodes($node2/@*)
        return
          if ( test:deep-equal($atts1, $atts2, $flags) ) then
            if ( fn:count($node1/node()) = 1 and $node1/text() = '...' ) then
              fn:true()
            else
              test:deep-equal(test:sorted-children($node1, $flags), test:sorted-children($node2, $flags), $flags)
          else
            fn:false()
    else
      fn:false()
  else if ( $node1 instance of text() and $node1 = '...' ) then
    fn:true()
  else if ( $node1 instance of text() and $node2 instance of text() ) then
    fn:string($node1) eq fn:string($node2)
  else if ( ( $node1 instance of attribute() and $node2 instance of attribute() )
            or ( $node1 instance of processing-instruction()
                 and $node2 instance of processing-instruction())
            or ( x:instance-of-namespace($node1)
                 and x:instance-of-namespace($node2) ) ) then
    fn:deep-equal( fn:node-name($node1), fn:node-name($node2) )
      and ( fn:string($node1) eq fn:string($node2) or fn:string($node1) = '...' )
  else if ( $node1 instance of comment() and $node2 instance of comment() ) then
    fn:string($node1) eq fn:string($node2) or fn:string($node1) = '...' 
  else
    fn:false()
};

declare function test:sorted-children(
    $node as node(),
    $flags as xs:string
  ) as node()*
{
  $node/child::node() 
  except ( $node/text()[fn:not(fn:normalize-space())][fn:contains($flags, 'w')][fn:not($node/self::test:ws)],
           $node/test:message )
};

(: Aim to be identical to:
 :
 :     <xsl:perform-sort select="$nodes">
 :        <xsl:sort select="namespace-uri(.)" />
 :        <xsl:sort select="local-name(.)" />
 :     </xsl:perform-sort>
 :)
declare function test:sort-named-nodes($nodes as node()*) as node()*
{
  if ( fn:empty($nodes) ) then
    ()
  else
    let $idx := test:named-nodes-minimum($nodes)
      return (
        $nodes[$idx],
        test:sort-named-nodes(fn:remove($nodes, $idx))
      )
};

(: Return the "minimum" of $nodes, using the order defined by
 : test:sort-named-nodes().
 :)
declare function test:named-nodes-minimum($nodes as node()+) as xs:integer
{
  (: if there is only one node, this is the minimum :)
  if ( fn:empty($nodes[2]) ) then
    1
  (: if not, init the temp minimum on the first one, then walk through the sequence :)
  else
    test:named-nodes-minimum($nodes, fn:node-name($nodes[1]), 1, 2)
};

declare function test:named-nodes-minimum(
    $nodes as node()+,
    $min   as xs:QName,
    $idx   as xs:integer,
    $curr  as xs:integer
  ) as xs:integer
{
  if ( $curr gt fn:count($nodes) ) then
    $idx
  else if ( test:qname-lt(fn:node-name($nodes[$curr]), $min) ) then
    test:named-nodes-minimum($nodes, fn:node-name($nodes[$curr]), $curr, $curr + 1)
  else
    test:named-nodes-minimum($nodes, $min, $idx, $curr + 1)
};

declare function test:qname-lt($n1 as xs:QName, $n2 as xs:QName) as xs:boolean
{
  if ( fn:namespace-uri-from-QName($n1) eq fn:namespace-uri-from-QName($n2) ) then
    fn:local-name-from-QName($n1) lt fn:local-name-from-QName($n2)
  else
    fn:namespace-uri-from-QName($n1) lt fn:namespace-uri-from-QName($n2)
};

declare function test:report-sequence(
    $sequence as item()*,
    $wrapper-name as xs:string
  ) as element()
{
  test:report-sequence($sequence, $wrapper-name, ())
};

declare function test:report-sequence(
    $sequence as item()*,
    $wrapper-name as xs:string,
    $test as attribute(test)?
  ) as element()
{
  let $wrapper-ns as xs:string := 'http://www.jenitennison.com/xslt/xspec'

  let $attribute-nodes as attribute()* := $sequence[. instance of attribute()]
  let $document-nodes as document-node()* := $sequence[. instance of document-node()]
  let $namespace-nodes as node()* := $sequence[x:instance-of-namespace(.)]
  let $text-nodes as text()* := $sequence[. instance of text()]

  let $report-element as element() :=
    element
      { fn:QName($wrapper-ns, $wrapper-name) }
      {
        $test,

        (
          (: Empty :)
          if (fn:empty($sequence))
          then attribute select { "()" }

          (: One or more atomic values :)
          else if ($sequence instance of xs:anyAtomicType+)
          then (
            let $atomic-value-reports as xs:string+ :=
              (for $value in $sequence return test:report-atomic-value($value))
            return attribute select { fn:string-join($atomic-value-reports, ', ') }
          )

          (: One or more nodes of the same type which can be a child of document node :)
          else if (
            ($sequence instance of comment()+)
            or ($sequence instance of element()+)
            or ($sequence instance of processing-instruction()+)
            or ($sequence instance of text()+)
          )
          then (
            attribute select { fn:concat('/', x:node-type($sequence[1]), '()') },
            for $node in $sequence return test:report-node($node)
          )

          (: Single document node :)
          else if ($sequence instance of document-node())
          then (
            (: People do not always notice '/' in the report HTML. So express it more verbosely.
              Also the expression must match the one in ../reporter/format-xspec-report.xsl. :)
            attribute select { "/self::document-node()" },
            test:report-node($sequence)
          )

          (: One or more nodes which can be stored in an element safely and without losing each position.
            Those nodes include document nodes and text nodes. By storing them in an element, they will
            be unwrapped and/or merged with adjacent nodes. When it happens, the report does not
            represent the sequence precisely. That's ok, because
              * Otherwise the report will be cluttered with pseudo elements.
              * XSpec in general including its test:deep-equal() inclines to merge them. :)
          else if (($sequence instance of node()+) and fn:not($attribute-nodes or $namespace-nodes))
          then (
            attribute select { "/node()" },
            for $node in $sequence return test:report-node($node)
          )

          (: Otherwise each item needs to be represented as a pseudo element :)
          else (
            attribute select {
              fn:concat(
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
                    let $multi-expr as xs:boolean := (fn:count($expressions) ge 2)
                    return
                      fn:concat(
                        '/',
                        '('[$multi-expr],
                        fn:string-join($expressions, ' | '),
                        ')'[$multi-expr]
                      )
                  )
                  else (
                    (: Not all items can be expressed in @select. Just leave the pseudo elements selected. :)
                  )
                )
              )
            },

            for $item in $sequence
            return test:report-pseudo-item($item, $wrapper-ns)
          )
        )
      }

  (: Output the report element :)
  return (
    (: TODO: If too many nodes, save the report element as an external doc :)
    $report-element
  )
};

declare function test:report-pseudo-item(
    $item as item(),
    $wrapper-ns as xs:string
  ) as element()
{
  let $local-name-prefix as xs:string := 'pseudo-'
  return (
    if ($item instance of xs:anyAtomicType)
    then
      element
        { fn:QName($wrapper-ns, fn:concat($local-name-prefix, 'atomic-value')) }
        { test:report-atomic-value($item) }

    else if ($item instance of node())
    then
      element
        { fn:QName($wrapper-ns, fn:concat($local-name-prefix, x:node-type($item))) }
        { test:report-node($item) }

    (: TODO: function(*) including array(*) and map(*) :)

    else
      element 
        { fn:QName($wrapper-ns, fn:concat($local-name-prefix, 'other')) }
        {}
  )
};

(:
  Copies the nodes while wrapping whitespace-only text nodes in <test:ws>
:)
declare function test:report-node(
    $node as node()
    ) as node()
{
  if ( ($node instance of text()) and fn:not(fn:normalize-space($node)) ) then
    element test:ws { $node }
  else if ( $node instance of document-node() ) then
    document {
      for $child in $node/child::node() return test:report-node($child)
    }
  else if ( $node instance of element() ) then
    element { fn:node-name($node) } {
      (
        for $prefix in fn:in-scope-prefixes($node)
          return namespace { $prefix } { fn:namespace-uri-for-prefix($prefix, $node) }
      ),
      $node/attribute(),
      (for $child in $node/child::node() return test:report-node($child))
    }
  else $node
};

declare function test:report-atomic-value($value as xs:anyAtomicType) as xs:string
{
  (: Derived types must be handled before their base types :)

  (: String types :)
  (: xs:normalizedString: Requires schema-aware processor :)
  if ( $value instance of xs:string ) then
    fn:concat("'", fn:replace($value, "'", "''"), "'")

  (: Derived numeric types: Requires schema-aware processor :)

  (: Numeric types which can be expressed as numeric literals:
    http://www.w3.org/TR/xpath20/#id-literals :)
  else if ( $value instance of xs:integer ) then
    fn:string($value)
  else if ( $value instance of xs:decimal ) then
    x:decimal-string($value)
  else if ( $value instance of xs:double ) then
    (: Do not report xs:double as a numeric literal. Report as xs:double() constructor instead.
      Justifications below.
      * Expression of xs:double as a numeric literal is a bit complicated:
        http://www.w3.org/TR/xpath-functions/#casting-to-string
      * xs:double is not used as frequently as xs:integer
      * xs:double() constructor is valid expression. It's just some more verbose than a numeric literal. :)
    test:report-atomic-value-as-constructor($value)

  else if ( $value instance of xs:QName ) then
    x:QName-expression($value)

  else
    test:report-atomic-value-as-constructor($value)
};

declare function test:report-atomic-value-as-constructor($value as xs:anyAtomicType) as xs:string
{
  (: Constructor usually has the same name as type :)
  let $constructor-name as xs:string := test:atom-type($value)

  (: Cast as either xs:integer or xs:string :)
  let $casted-value as xs:anyAtomicType := (
    if ( $value instance of xs:integer )
    then
      (: Force casting down to integer, by first converting to string :)
      (fn:string($value) cast as xs:integer)
    else
      fn:string($value)
  )

  (: Constructor parameter:
    Either numeric literal of integer or string literal :)
  let $costructor-param as xs:string :=
    test:report-atomic-value($casted-value)

  return fn:concat($constructor-name, '(', $costructor-param, ')')
};

declare function test:atom-type($value as xs:anyAtomicType) as xs:string
{
  (: Grouped as the spec does: http://www.w3.org/TR/xslt20/#built-in-types
    Groups are in the reversed order so that the derived types are before the primitive types,
    otherwise xs:integer is recognised as xs:decimal, xs:yearMonthDuration as xs:duration, and so on. :)

  (: A schema-aware XSLT processor additionally supports: :)

  (:    * All other built-in types defined in [XML Schema Part 2] :)
  (: Requires schema-aware processor :)

  (: Every XSLT 2.0 processor includes the following named type definitions in the in-scope schema components: :)

  (:    * The following types defined in [XPath 2.0] :)
  if ( $value instance of xs:yearMonthDuration ) then
    'xs:yearMonthDuration'
  else if ($value instance of xs:dayTimeDuration ) then
    'xs:dayTimeDuration'
  (: xs:anyAtomicType: Abstract :)
  (: xs:untyped: Not atomic :)
  else if ( $value instance of xs:untypedAtomic ) then
    'xs:untypedAtomic'

  (:    * The types xs:anyType and xs:anySimpleType. :)
  (: Not atomic :)

  (:    * The derived atomic type xs:integer defined in [XML Schema Part 2]. :)
  else if ( $value instance of xs:integer ) then
    'xs:integer'

  (:    * All the primitive atomic types defined in [XML Schema Part 2], with the exception of xs:NOTATION. :)
  else if ( $value instance of xs:string ) then
    'xs:string'
  else if ( $value instance of xs:boolean ) then
    'xs:boolean'
  else if ( $value instance of xs:decimal ) then
    'xs:decimal'
  else if ( $value instance of xs:double ) then
    'xs:double'
  else if ( $value instance of xs:float ) then
    'xs:float'
  else if ( $value instance of xs:date ) then
    'xs:date'
  else if ( $value instance of xs:time ) then
    'xs:time'
  else if ( $value instance of xs:dateTime ) then
    'xs:dateTime'
  else if ( $value instance of xs:duration ) then
    'xs:duration'
  else if ( $value instance of xs:QName ) then
    'xs:QName'
  else if ( $value instance of xs:anyURI ) then
    'xs:anyURI'
  else if ( $value instance of xs:gDay ) then
    'xs:gDay'
  else if ( $value instance of xs:gMonthDay ) then
    'xs:gMonthDay'
  else if ( $value instance of xs:gMonth ) then
    'xs:gMonth'
  else if ( $value instance of xs:gYearMonth ) then
    'xs:gYearMonth'
  else if ( $value instance of xs:gYear ) then
    'xs:gYear'
  else if ( $value instance of xs:base64Binary ) then
    'xs:base64Binary'
  else if ( $value instance of xs:hexBinary ) then
    'xs:hexBinary'
  else
    'xs:anyAtomicType'
};


(: ------------------------------------------------------------------------ :)
(:  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.               :)
(:                                                                          :)
(:  Copyright (c) 2008, 2010 Jeni Tennison                                  :)
(:                                                                          :)
(:  The contents of this file are subject to the MIT License (see the URI   :)
(:  http://www.opensource.org/licenses/mit-license.php for details).        :)
(:                                                                          :)
(:  Permission is hereby granted, free of charge, to any person obtaining   :)
(:  a copy of this software and associated documentation files (the         :)
(:  "Software"), to deal in the Software without restriction, including     :)
(:  without limitation the rights to use, copy, modify, merge, publish,     :)
(:  distribute, sublicense, and/or sell copies of the Software, and to      :)
(:  permit persons to whom the Software is furnished to do so, subject to   :)
(:  the following conditions:                                               :)
(:                                                                          :)
(:  The above copyright notice and this permission notice shall be          :)
(:  included in all copies or substantial portions of the Software.         :)
(:                                                                          :)
(:  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,         :)
(:  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF      :)
(:  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  :)
(:  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY    :)
(:  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,    :)
(:  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE       :)
(:  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                  :)
(: ------------------------------------------------------------------------ :)
