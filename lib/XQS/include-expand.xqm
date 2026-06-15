(:~ Library for processing inclusions and instantiating abstract rules and 
 : patterns.
 :)

module namespace ie = 'http://www.andrewsales.com/ns/xqs-include-expand';

import module namespace util = 'http://www.andrewsales.com/ns/xqs-utils' at
  'utils.xqm';

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";

(:~ Perform inclusion and expansion.
 :)
declare function ie:include-expand($schema as element(sch:schema)) 
as element(sch:schema)
{
  ie:process-includes($schema) => ie:process-abstracts()
};

(:~ Perform abstract rule and pattern expansion. :)
declare function ie:process-abstracts($schema as element(sch:schema))
as element(sch:schema)
{
  ie:expand-rules($schema) => ie:expand-patterns()
};

(:~ Handle includes in the main schema document. 
 : Resolve any includes, then recurse if any remain as a result.
 :)
declare function ie:process-includes(
  $schema as element(sch:schema)
)
as element(sch:schema)
{
  (: let $_ := trace('SCHEMA base URI=' || $schema/base-uri()) :)
  let $copy :=
  copy $copy := $schema
    modify
      for $include in ($copy//sch:include | $copy//sch:extends[@href])
      let $replacement := ie:process-include($include, $schema/base-uri())
      return
      replace node $include with 
        if($include/self::sch:extends)
        then $replacement/*
        else $replacement
    return $copy
    
  return 
  if($copy//sch:include | $copy//sch:extends[@href])
  then ie:process-includes($copy)
  else
    (if($copy/@xml:base)	(:don't replace:)
    then $copy
    else
      copy $copy := $copy
      modify
        insert node attribute{'xml:base'}{$schema/base-uri()} into $copy
    return $copy) => util:elements-to-attributes()
};

(:~ For a given inclusion instruction, retrieve the element to be included,
 : performing base URI fixup on any inclusion instructions it contains. 
 : @param include the inclusion instruction
 : @param base-uri base URI of the containing document
 :)
declare %private function ie:process-include(
  $include as element(),
  $base-uri as xs:anyURI
) as node()
{
  (: let $_ := trace('include='||$include=>serialize())
  let $_ := trace('base URI='||$base-uri)
  let $_ := trace('resolving include='||$include/@href) :)
  let $include := ie:get-inclusion($include/@href, $base-uri)
  let $include-base-uri := $include/base-uri()	(:store before we create the copy:)
  return
  copy $copy := $include
    modify
      for $href in $copy/(descendant-or-self::sch:include | descendant-or-self::sch:extends)/@href
      let $resolved-uri := resolve-uri($href, $include-base-uri)
      return
      replace value of node $href with $resolved-uri
  return $copy    
};

(:~ Return the element to be included. 
 : @param href href attribute giving location of the inclusion
 : @param base-uri base URI of the inclusion
 :)
declare %private function ie:get-inclusion(
  $href as attribute(href),
  $base-uri as xs:anyURI
)
as element()
{
  let $url := if(contains($href, '#')) then substring-before($href, '#') else $href
  let $fragment := substring-after($href, '#')
  let $doc := doc(resolve-uri($url, $base-uri))
  let $inclusion as element() :=
    if($fragment)
    then ($doc//*[@id eq $fragment])[1]
    else $doc/*
  (: let $_ := trace('inclusion='||serialize($inclusion)||' base URI='||$inclusion/base-uri()) :)
  
  return $inclusion
};

(:~ Expand abstract rules by replacing the contents of extends with the contents
 : of the abstract rule referenced, then removing all abstract rules.
 : @param schema the containing schema
 :)
declare function ie:expand-rules($schema as element(sch:schema))
as element(sch:schema)
{
  copy $copy := $schema
  modify
    (for $extends in $copy//sch:extends[@rule]
    return replace node $extends with ie:expand-rule($extends, $schema),
    delete node $copy//(sch:rule[@abstract eq 'true']|sch:rules)
    )
  return $copy
};

declare function ie:expand-rule(
  $extends as element(sch:extends),
  $schema as element(sch:schema)
)
as node()*
{
  let $abstract := $schema//sch:rule[@id eq $extends/@rule]
  return
  if(empty($abstract))
  then error(xs:QName('xqs:no-such-abstract-rule'), $extends/@rule)
  else 
  $abstract/node()
  (:TODO language fixup:)
};

(:~ Instantiate abstract patterns and delete abstract patterns. :)
declare function ie:expand-patterns($schema as element(sch:schema))
as element(sch:schema)
{
  let $abstract-pattern-ids := $schema//sch:pattern[@abstract eq 'true']/@id
  return
  copy $copy := $schema
     modify (
     for $pattern in $copy//sch:pattern[@is-a]
     return replace node $pattern with 
     ie:expand-pattern($pattern, $abstract-pattern-ids[. eq $pattern/@is-a]/..),
     delete node $copy//sch:pattern[@abstract eq 'true']
   )
  return $copy
};

(:~ Instantiate an abstract pattern by inserting the abstract pattern body and
 : replacing any parameter references.
 : @param pattern the pattern instance
 : @param abstract the abstract pattern
 :)
declare function ie:expand-pattern(
  $pattern as element(sch:pattern),
  $abstract as element(sch:pattern)
)
as element(sch:pattern)
{
  (: if(not(@documents)) then $abstract/@documents else ():)
  (: TODO language fixup :)
  (: TODO @documents :)
  (: TODO properties :)
  (: TODO diagnostics :)
  <sch:pattern>
  {$pattern/@* except $pattern/@is-a}
  {$abstract/node() ! ie:pattern-filter(., $pattern/sch:param)}
  </sch:pattern>
};

(:~ Process the contents of an abstract pattern instance.
 : @param node child nodes of the instance
 : @param params instance parameters
 :)
declare function ie:pattern-filter(
  $node as node()*,
  $params as element(sch:param)*
)
{
  typeswitch($node)
    case element() 
      return element{$node/name()}
        {ie:pattern-elements($node, $params),
        $node/node() ! ie:pattern-filter(., $params)}
    default return $node
};

(:~ Replace any parameter references in instantiated abstract patterns. 
 : @param element the element whose attributes might contain param refs
 : @param params parameters declared in the instantiated pattern 
 :)
declare function ie:pattern-elements(
  $element as element(),
  $params as element(sch:param)*
)
as attribute()*
{
  switch($element)
    case $element/(self::sch:assert | self::sch:report)
      return ie:pattern-attributes($element, 'test', $params)
    case $element/self::sch:rule
      return ie:pattern-attributes($element, 'context', $params)
    case $element/self::sch:value-of
      return ie:pattern-attributes($element, 'select', $params)
    case $element/self::sch:let
      return ie:pattern-attributes($element, 'value', $params)
    case $element/self::sch:name
      return ie:pattern-attributes($element, 'path', $params)
    (:TODO sch:pattern/@documents:)
    default return $element/@*
};

(:~ Replace parameter references in the attribute value passed in with parameter : values.
 : @param element parent element of the attribute
 : @param attribute attribute value to be updated
 : @param params parameters to replace
 :)
declare function ie:pattern-attributes(
  $element as element(),
  $attribute as xs:string,
  $params as element(sch:param)*
)
as attribute()*
{
  let $replace := $element/@*[name() eq $attribute]
  return
  (
    $element/@* except $replace,
    attribute{$attribute}{ie:replace-param-refs($replace, $params)}
  )
};

(:~ Replace parameter references with parameter values.
 : N.B. This matches the recursive approach SchXslt uses.
 :)
declare function ie:replace-param-refs(
  $expr as xs:string,
  $params as element(sch:param)*
)
as xs:string?
{
  if(empty($params))
  then $expr
  else
  (:sort params by desc length of name:)
  let $sorted := for $param in $params 
    order by string-length($param/@name) descending
    return $param
  let $value := replace(head($sorted)/@value, '\\', '\\\\') => replace('\$', '\\\$')
  let $expr := replace(
    $expr, 
    '(\W*)\$' || $sorted[1]/@name || '(\W*)', 
    '$1' || $value || '$2'
  )
  return ie:replace-param-refs($expr, tail($sorted))
};