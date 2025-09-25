(:~ 
 : Conveniences for assembling SVRL output. 
 :)
module namespace output = 'http://www.andrewsales.com/ns/xqs-output';

import module namespace utils = 'http://www.andrewsales.com/ns/xqs-utils' at
  'utils.xqm';

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";

declare function output:schema-title($title as element(sch:title)?)
as attribute(title)?
{
  if($title) then attribute{'title'}{$title} else ()
};

declare function output:namespace-decls-as-svrl($nss as element(sch:ns)*)
as element(svrl:ns-prefix-in-attribute-values)*
{
  for $ns in $nss 
  return 
  <svrl:ns-prefix-in-attribute-values>
  {$ns/@prefix, $ns/@uri}
  </svrl:ns-prefix-in-attribute-values>
};

(:~ Outputs a failed-assert or successful-report element. :)
declare function output:assertion(
  $assertion as element(),
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
{
  if($context?dry-run eq 'true')
  then output:assertion-message(
        $assertion/node(), 
        $prolog, 
        $rule-context,
        $context
      )
      else
  element{
    QName("http://purl.oclc.org/dsdl/svrl", 
    if($assertion/self::sch:assert) then 'failed-assert' else 'successful-report')}
    {
      attribute{'location'}{utils:location(
        $assertion,
        $prolog,
        $rule-context,
        $context
      )},
      $assertion/(@id, @test),
      output:pattern-rule-id($assertion),
      output:dynamic-attributes(
        $assertion/(@role, @flag, @severity),
        $prolog,
        $context
      ),
      output:diagnostics(
        $context?diagnostics[@id = tokenize($assertion/@diagnostics)],
        $prolog,
        $rule-context,
        $context
      ),
      output:properties(
        $context?properties[@id = tokenize($assertion/@properties)],
        $prolog,
        $rule-context,
        $context
      ),
      output:assertion-message(
        $assertion/node(), 
        $prolog, 
        $rule-context,
        $context
      )
    }
};

(:~ If the value of flag, role or severity is a variable reference, its value 
 : is dynamically evaluated.
 : This implementation returns the attribute with a dynamically evaluated value, 
 : or as-is if its value is not a variable reference.
 : @param atts the attributes to dynamically evaluate
 : @param prolog the query prolog
 : @param context the validation context
 : @see ISO2025 5.6.6, 5.6.14 & 5.6.16
 :)
declare %private function output:dynamic-attributes(
  $atts as attribute()*,
  $prolog as xs:string?,
  $context as map(*)
)
as attribute()*
{
  for $att in $atts
  return 
  if(starts-with($att, '$')) 
  then attribute{$att/name()}{xquery:eval($prolog || $att, $context?globals)}
  else $att
};

(:~ Transforms SCH namespace to SVRL. (Not attempting to address inconsistencies
 : between schema and SVRL elements and attributes.)
 :)
declare function output:assertion-child-elements($element as element())
as element()
{
  element{QName("http://purl.oclc.org/dsdl/svrl", local-name($element))}
  {$element/@*, utils:escape-literal-braces($element/node())}
};

declare function output:diagnostics(
  $diagnostics as element(sch:diagnostic)*,
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
as element(svrl:diagnostic-reference)*
{
  $diagnostics ! 
  <svrl:diagnostic-reference diagnostic='{@id}'>
  {output:assertion-message(node(), $prolog, $rule-context, $context)}
  </svrl:diagnostic-reference>
};

declare function output:properties(
  $properties as element(sch:property)*,
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
as element(svrl:property-reference)*
{
  $properties ! 
  <svrl:property-reference property='{@id}'>
  {@role, @scheme, 
  output:assertion-message(node(), $prolog, $rule-context, $context)}
  </svrl:property-reference>
};

(:~ Outputs svrl:text, which corresponds to the model <code>human-text</code>
 : in the SVRL schema.
 : @see ISO2020, Annex D
 :)
declare function output:assertion-message(
  $content as node()*,
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
as item()*
{
  if($context?dry-run eq 'true')
  then
    for $node in $content/(self::sch:name|self::sch:value-of)
    return
    typeswitch($node)
      case element(sch:name)
        return if($node/@path) 
          then output:name-value-of($node/@path, $prolog, $rule-context, $context)
          [self::svrl:*]
          else ()
      case element(sch:value-of)
        return output:name-value-of($node/@select, $prolog, $rule-context, $context)
        [self::svrl:*]
    default return ()
  else
  <svrl:text>{(:TODO attributes:)
  for $node in $content
    return
    typeswitch($node)
      case element(sch:name)
        return if($node/@path) 
          then output:name-value-of($node/@path, $prolog, $rule-context, $context)
          else name($rule-context)
      case element(sch:value-of)
        return text{output:name-value-of($node/@select, $prolog, $rule-context, $context)}
      case element(sch:emph) | element(sch:dir) | element(sch:span)
        return 
        element{QName("http://purl.oclc.org/dsdl/svrl", local-name($node))}
        {
          $node/@*, 
          output:assertion-message-content($node/node(), $prolog, $rule-context, $context)
        } 
    default return $node
  }</svrl:text>
};

declare function output:assertion-message-content(
  $content as node()*,
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
as item()*
{
  (:TODO dry-run?:)
  for $node in $content
    return
    typeswitch($node)
      case element(sch:name)
        return if($node/@path) 
          then text{output:name-value-of($node/@path, $prolog, $rule-context, $context)}
          else name($rule-context)
      case element(sch:value-of)
        return text{output:name-value-of($node/@select, $prolog, $rule-context, $context)}
    default return $node
};

declare function output:name-value-of(
  $attr as attribute(),
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
{
  utils:eval(
    $prolog || $attr, 
    map:merge((map{'':$rule-context}, $context?globals)),
    map{'dry-run':$context?dry-run},
    $attr
  )
};

(:~ Output ruleId and patternId attributes where an assertion's ancestors have 
 : these.
 : @param assertion the assertion
 : @see https://github.com/Schematron/schematron-enhancement-proposals/issues/82 
 :)
declare function output:pattern-rule-id($assertion as element())
as attribute()*
{
  if($assertion/../@id) then attribute{'ruleId'}{$assertion/../@id},
  if($assertion/../../@id) then attribute{local-name($assertion/../..)||'Id'}{$assertion/../../@id}
};