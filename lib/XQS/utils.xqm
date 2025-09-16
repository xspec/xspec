(:~ Common utility functions. :)

module namespace utils = 'http://www.andrewsales.com/ns/xqs-utils';

declare namespace xqs = 'http://www.andrewsales.com/ns/xqs';
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace xqy = 'http://www.w3.org/2012/xquery';  

(:~ Builds the string of variable declarations in the prolog, for initial
 : evaluation.
 : @param globals the global variables
 :)
declare function utils:global-variable-decls($globals as element(sch:*)*)
as xs:string?
{
  string-join(
    for $var in $globals
    return 'declare variable $' || $var/@name || (if($var/@as) then (' as ' || $var/@as || ' ') else '') ||
    ':=' || utils:variable-value($var)  || ';'
  )
};

(:~ Builds the string of external global variable declarations in the prolog.
 : Global variables are evaluated and bound as external variables.
 : @param globals the map of evaluated global variables
 :)
declare function utils:global-variable-external-decls($globals as map(*))
as xs:string?
{
  string-join(for $k in map:keys($globals)
    return 'declare variable $' || $k || ' external;')
};

(:~ Builds the string of local variable declarations.
 : @param locals the variables to declare
 :)
declare function utils:local-variable-decls($locals as element(sch:let)*)
as xs:string
{
  string-join(
    for $var in $locals
    return utils:declare-variable($var/@name, utils:variable-value($var),
  $var/@as),
    ' '
  )
};

(:~ Adds the value to a variable declaration. 
 : @param var the variable
 : @see ISO2020, 5.4.6: "The value attribute is an expression evaluated in the 
 : current context. If no value attribute is specified, the value of the 
 : attribute is the element content of the let element."
 :)
declare function utils:variable-value($var as element(sch:*))
as xs:string
{
  if($var/@as => normalize-space() => matches('^map\([^\)]+\)')) 
  then $var/@value/data()
  else
  if($var/@value) then $var/@value/data() => utils:escape() else serialize($var/*)
};

(:~ Assembles the query prolog of namespace and variable declarations.
 : @param context the validation context
 :)
declare function utils:make-query-prolog($context as map(*))
as xs:string?
{
  ($context?ns-decls || utils:global-variable-external-decls($context?globals))
  => utils:escape() || $context?functions ! string(.)
};

(:~ Creates a QName from a prefixed variable name, looking up any URI from the
 : namespace declarations passed in.
 : @param name name of the variable
 : @param namespaces namespace declarations
 :)
declare function utils:variable-name-to-QName(
  $name as attribute(name),
  $namespaces as element(sch:ns)*
)
as xs:QName
{
  let $prefix := substring-before($name, ':')
  return QName(
    if($prefix ne '') then $namespaces[@prefix eq $prefix]/@uri else '',
    $name
  )
};

(:~ Escape ampersands in dynamically-evaluated queries.
 : @param query the string of the query to escape
 :)
declare function utils:escape($query as xs:string)
as xs:string
{
  replace($query, '&amp;', '&amp;amp;') 
  (: => replace('\{', '&amp;#x7B;') 
  => replace('\}', '&amp;#x7D;') :)
};

(:~ Escape literal braces (in compiled schemas).
 : @param nodes nodes to escape
 :)
declare function utils:escape-literal-braces($nodes as node()*)
as node()*
{
    for $node in $nodes
    return
    typeswitch($node)
      case text()
        return text{replace($node, '\{', '{{') => replace('\}', '}}')}  (:CHECKME node constructor required, else padded with space:)
    default return $node
};

declare function utils:declare-variable(
  $name as xs:string,
  $value as item()+
)
as xs:string
{
  'let $' || $name || ':=' || $value
};

declare function utils:declare-variable(
  $name as xs:string,
  $value as item()+,
  $type as attribute(as)?
)
as xs:string
{
  'let $' || $name || (if($type) then (' as ' || $type || ' ') else '') 
  || ':=' || $value
};

(:VARIABLES:)

(:~ @see ISO2020, 7.2: "A Schematron schema shall have one definition only in 
 : scope for any global variable name in the global context and any local 
 : variable name in the local context." 
 : @see ISO2025: "Parameter names shall be distinct within the scope of a 
 : pattern or schema."
 :)
declare function utils:check-duplicate-variable-names($decls as element(sch:*)*)
{
  let $names as xs:string* := $decls/@name/string()
  return
  if(count($decls) ne count(distinct-values($names)))
  then error(
    xs:QName('xqs:multiply-defined-variable'),
    'duplicate variable name in element ' || local-name(head($decls)/..) || ': '
    || $names[index-of($names, .)[2]]
  ) else()
};

(:~ In dry-run mode only, evaluate rule variables.
 : Provides more localized information if syntax errors are present in rule 
 : variable declarations.
 :)
declare function utils:evaluate-rule-variables(
  $variables as element(sch:let)*,
  $prolog as xs:string?,
  $bindings as map(*),
  $context as map(*),
  $errors as element()*
)
as element()*
{
  if($context?dry-run eq 'true')
  then
    if(exists($variables))
    then
      let $var := head($variables)
      let $prolog := $prolog || utils:local-variable-decls($var)
      let $errs := utils:eval(
        $prolog || ' return $' || $var/@name => utils:escape(),
        $bindings,
        map{'dry-run':$context?dry-run},
        $var/@value
      )
      return utils:evaluate-rule-variables(
        tail($variables),
        $prolog,
        $bindings,
        $context,
        ($errors,$errs)
      )
    else $errors
  else ()
};

(:~ Wrapper around xquery:eval(). In "dry-run" mode, the query passed in is 
 : parsed only, and any errors caught reported as svrl:failed-assert.
 : @param $query string of the query to evaluate
 : @param bindings map of bindings
 : @param options map of options
 : @param node the schema node being evaluated
 :)
declare function utils:eval(
  $query as xs:string,
  $bindings as map(*),
  $options as map(*),
  $node as node()
) as item()*
{
  if($options?dry-run eq 'true')
  then
    (<svrl:fired-rule context='{$node/path()}'/>,
    try{
      xquery:parse($query, map{'pass':true()})
    }
    catch * {
      <svrl:failed-assert err:code='{$err:code}' location='{$node/path()}' 
      test='xquery:parse(.)'>
      <svrl:text>{$err:description}{' @'||$node/name()}='{$node/data()}'</svrl:text></svrl:failed-assert>
    })
  else 
  xquery:eval(
    $query, 
    $bindings, 
    map{
      'pass':if($options?pass) then $options?pass else true(),
      'base-uri':$node/base-uri()
    }
  )
};

(:~ Obtain the (XPath) location of a node which has failed an assertion.
 : Use @subject to refine the location by evaluating its expression against the
 : rule context node: the assertion's @subject if present, falling back to
 : the parent rule's @subject. Otherwise, use the location of the rule context
 : node.
 : @param assertion the assertion reported
 : @param prolog query prolog
 : @param rule-context the evaluated rule context
 : @param context evaluation context
 :)
declare function utils:location(
  $assertion as element(),
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
as xs:string
{
  if($assertion/@subject or $assertion/../@subject)
  then utils:eval(
    $prolog || ($assertion/@subject, $assertion/../@subject)[1],
    map:merge((map{'':$rule-context}, $context?globals)),
    map{'dry-run':$context?dry-run},
    $rule-context
  ) => path()
  else
  path($rule-context)	(:just use rule context:)
};

declare function utils:parse-function(
  $node as element(xqy:function),
  $options as map(*)
)
as element()+
{
  <svrl:fired-rule context='{$node/path()}'/>,
  try{
    xquery:parse($node || 0, map{'pass':true()})
  }
  catch * {
    <svrl:failed-assert err:code='{$err:code}' location='{$node/path()}' 
    test='xquery:parse(.)'>
    <svrl:text>{$err:description}{' '||$node/name()}='{$node/data()}'</svrl:text>
    </svrl:failed-assert>
  }  
};

(:~ Report the Schematron edition declared in the schema. 
 : This implementation emits the schema root element with any schematronEdition 
 : attribute if present to stderr.
 : @param schema the schema 
 : @param map of options
 : @see ISO2025 5.5.15
 :)
declare function utils:report-edition(
  $schema as element(sch:schema),
  $options as map(*)?
)
{
  if(lower-case($options?report-edition) = ('true', 'y', 'yes', '1'))
  then 
  trace(<sch:schema>{$schema/@schematronEdition}</sch:schema>)    
  else ()
};

declare function utils:attributes-to-elements(
  $schema as element(sch:schema)
)
as element(sch:schema)
{
  copy $copy := $schema
  modify
    for $att in ($copy//sch:param/@value | $copy//sch:let/@value | $copy//sch:phase/(@from, @when) | $copy//sch:pattern/@documents | $copy//sch:rule/(@context, @subject, @visit-each) | $copy//(sch:assert | sch:report)/(@test, @subject) | $copy//sch:name/@path | $copy//sch:value-of/@select)
      return
      (delete node $att,
      insert node element{$att/name()}{$att/data()} as first into $att/..)
  return $copy
};

declare function utils:elements-to-attributes(
  $schema as element(sch:schema)
)
as element(sch:schema)
{
  copy $copy := $schema
  modify
    for $elem in ($copy//sch:param/sch:value | $copy//sch:let/sch:value | $copy//sch:phase/(sch:from, sch:when) | $copy//sch:pattern/sch:documents | $copy//sch:rule/(sch:context | sch:subject | sch:visit-each) | $copy//(sch:assert | sch:report)/(sch:test | sch:subject) | $copy//sch:name/sch:path | $copy//sch:value-of/sch:select)
      return
    (insert node attribute{$elem/local-name()}{$elem/data()} into $elem/..,
      delete node $elem)
  return $copy
};