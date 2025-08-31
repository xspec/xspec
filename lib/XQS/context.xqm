(:~ 
 : Library for establishing the validation context. 
 :)

module namespace c = 'http://www.andrewsales.com/ns/xqs-context';

import module namespace utils = 'http://www.andrewsales.com/ns/xqs-utils'
  at 'utils.xqm';    

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace xqy = 'http://www.w3.org/2012/xquery';

declare variable $c:DEFAULT_PHASE as xs:string := '#DEFAULT';
declare variable $c:ALL_PATTERNS as xs:string := '#ALL';
declare variable $c:ANY_PHASE as xs:string := '#ANY';

(:~ Sets up the validation context: namespaces, global variables, parameters,
 : active phase (if configured) and patterns.
 : @param instance the document instance
 : @param schema the Schematron schema
 : @param options map of options: key 'phase' specifies the active phase
 :)
declare function c:get-context(
  $instance as node(),
  $schema as element(sch:schema),
  $options as map(*)?
)
as map(*)
{
  let $namespaces as xs:string? := c:make-ns-decls($schema/sch:ns)
  let $globals as element(sch:let)* := $schema/sch:let
  let $params as element(sch:param)* := $schema/sch:param
  let $_ := (utils:check-duplicate-variable-names($schema/sch:let),
    utils:check-duplicate-variable-names($schema/sch:param))
  let $globals as map(*) := if($globals|$params) 
    then c:evaluate-global-variables(
      $globals|$params, 
      $instance, 
      $namespaces, 
      $schema/sch:ns, 
      map{},
      $options
    )
    else map{}
    
  let $active-phase as element(sch:phase)? := c:get-active-phase($schema, $instance, $globals, $options)
  let $active-patterns as element(sch:pattern)* := c:get-active-patterns($schema, $active-phase)
  let $active-groups as element(sch:group)* := c:get-active-groups($schema, $active-phase)
      
  return 
  map:merge(
    (
      $options,
      map{
      'phase' : $active-phase,
      'patterns' : $active-patterns,
      'groups' : $active-groups,
      'ns-decls' : $namespaces,
      'globals' : $globals,
      'instance' : $instance,
      'diagnostics' : $schema/sch:diagnostics/sch:diagnostic,
      'properties' : $schema/sch:properties/sch:property,
      'functions' : $schema/xqy:function
      }
    ),
    map{'duplicates':'use-last'}    (:ensure existing keys are overwritten:)
  )
};

(:NAMESPACE DECLARATIONS:)

declare function c:make-ns-decls($nss as element(sch:ns)*)
as xs:string?
{
  (:exclude the XML namespace:)
  $nss[not(@uri eq 'http://www.w3.org/XML/1998/namespace')][not(@prefix eq 'xml')]
  ! c:make-ns-decl(.) => string-join()
};

declare %private function c:make-ns-decl($ns as element(sch:ns))
as xs:string
{
  'declare namespace ' || $ns/@prefix || '="' || $ns/@uri || '";'
};

(:PHASES:)

(:~ Compile-specific version of c:get-active-phase#5.
 : This is a convenience to preserve the existing API and necessitated by @when,
 : whose introduction means the active phase cannot be determined statically.
 : @see ISO2025 5.5.22
 : @param schema the Schematron schema
 : @param options map of options: key 'phase' specifies the active phase
 : @return the active phase, or the empty sequence if none is defined or can be
 : determined
 :)
declare function c:get-active-phase(
  $schema as element(sch:schema), 
  $options as map(*)?
)
as element(sch:phase)?
{
  if($options?phase eq $c:ANY_PHASE) then ()	(:#ANY:)
  else c:get-active-phase($schema, (), map{}, $options)
};

(:~ Determines the active phase.
 : @see ISO2020 5.4.11
 : @param schema the Schematron schema
 : @param instance the instance document
 : @param globals map of global variables
 : @param options map of options: key 'phase' specifies the active phase
 : @return the active phase, or the empty sequence if none is defined or can be
 : determined
 :)
declare function c:get-active-phase(
  $schema as element(sch:schema), 
  $instance as node()?,
  $globals as map(*)?,
  $options as map(*)
)
as element(sch:phase)?
{
  let $phase := $options?phase
  return
  if(empty($phase) or $phase eq $c:DEFAULT_PHASE)
  then
    if($schema/@defaultPhase)
    then $schema/sch:phase[@id eq $schema/@defaultPhase]	(:default phase:)
    else ()	(:fall back to #ALL:)	(:TODO report as info?:)
  else
    if($phase eq $c:ALL_PATTERNS)
    then ()
    else
      if($phase eq $c:ANY_PHASE)
      then c:get-active-phase-by-when($schema/sch:phase/@when, $instance, $globals, $options)
      else $schema/sch:phase[@id eq $phase]	(:TODO report if none?:)
};

(:~ Evaluate phase/@when against then document instance, 
 : returning the first matching phase, if any.
 : @param when phase/@when attributes
 : @param instance the document instance
 : @param globals map of global variables
 : @param options map of options
 :)
declare function c:get-active-phase-by-when(
  $when as attribute(when)*,
  $instance as node(),
  $globals as map(*)?,
  $options as map(*)
)
as element(sch:phase)?
{
    let $context as map(*) := map:merge((map{'':$instance}, $globals))
    let $options as map(*) := map{'dry-run':$options?dry-run} 
    
    let $phase := 
    (
        for $query in $when
        return
        (
         utils:eval(
           utils:escape($query),
           $context,
           $options,
           $query
         )/.
        )/$query/..
    )[1]
    
    return $phase
};

(:~ Determines the active patterns.
 : @see ISO2020 5.4.11
 : @param schema the Schematron schema
 : @param the active phase
 : @return the active patterns
 :)
declare function c:get-active-patterns(
  $schema as element(sch:schema), 
  $active-phase as element(sch:phase)?
)
as element(sch:pattern)*
{
  $schema/sch:pattern[sch:rule][
    if($active-phase) then @id = $active-phase/sch:active/@pattern else true()
  ]  
};

(:~ Determines the active groups.
 : @see https://github.com/Schematron/schematron-enhancement-proposals/issues/25#issuecomment-1178553154
 : @param schema the Schematron schema
 : @param the active phase
 : @return the active groups
 :)
declare function c:get-active-groups(
  $schema as element(sch:schema), 
  $active-phase as element(sch:phase)?
)
as element(sch:group)*
{
  $schema/sch:group[sch:rule][
    if($active-phase) then @id = $active-phase/sch:active/@pattern else true()
  ]  
};

(:~ Determines the global variables declared, i.e. with the current schema or 
 : active phase.
 : Note that this <emph>excludes</emph> pattern variables from the global scope:
 : "It is an error to reference a variable that has not been defined in the 
 : current schema, phase, pattern or rule"
 : @see ISO2020 5.4.6
 : @param schema the Schematron schema
 : @param the active phase
 : @return global variable declarations
 :)
declare function c:get-global-variables(
  $schema as element(sch:schema),
  $active-phase as element(sch:phase)?  
)
as element(sch:let)*
{
  ($schema,$active-phase)/sch:let
};

(:~ Evaluates global variables against the instance document root.
 : @see ISO2020, 5.4.6: "If the let element is the child of a rule element, the
 : variable is calculated and scoped to the current rule and context. Otherwise,
 : the variable is calculated with the context of the instance document root."
 : @return map of global variable bindings
 : @param variables global variables
 : @param instance the document instance
 : @param namespaces namespace declarations
 : @param bindings global variable bindings
 : @param options map of options
 :)
declare function c:evaluate-global-variables(
  $variables as element(sch:*)*,
  $instance as node(),
  $namespaces as xs:string?,
  $ns-elems as element(sch:ns)*,
  $bindings as map(*),
  $options as map(*)?
)
as map(*)
{
  if(empty($variables))
  then $bindings
  else 
    let $var := head($variables)
    let $prolog := $namespaces || 
      utils:global-variable-external-decls($bindings) ||
      utils:global-variable-decls($var)
    
    (: let $_ := trace('[1]$prolog='||serialize($prolog)) :)
    (: let $_ := trace('[2]$bindings='||serialize($bindings, map{'method':'adaptive'})) :)
    (: let $_ := trace('[3]evaluating GLOBAL variable $'||$var/@name) :)
    
    let $binding := c:evaluate-global-variable(
      $var,
      $instance,
      $prolog || '$' || $var/@name,
      $ns-elems,
      $bindings,
      $options
    )    
    
    (: let $_ := trace('[5]$bindings='||serialize($binding, map{'method':'adaptive'})) :)
    
    return c:evaluate-global-variables(
      tail($variables),
      $instance,
      $namespaces,
      $ns-elems,
      $binding,
      $options
    )
};

(:~ Evaluates pattern variables against the instance document root.
 : @see ISO2020, 5.4.6: "If the let element is the child of a rule element, the
 : variable is calculated and scoped to the current rule and context. Otherwise,
 : the variable is calculated with the context of the instance document root."
 : @return map of global and pattern-level variable bindings
 : @param variables pattern variables
 : @param instance the document instance
 : @param prolog global variable and namespace declarations
 : @param options map of options
 :)
declare function c:evaluate-root-context-variables(
  $variables as element(sch:let)*,
  $instance as node()+,
  $namespaces as xs:string?,
  $ns-elems as element(sch:ns)*,
  $bindings as map(*),
  $options as map(*)?
)
as map(*)
{
  if(empty($variables))
  then $bindings
  else 
    let $var := head($variables)
    let $prolog := $namespaces || 
      utils:global-variable-external-decls($bindings)
    
    (: let $_ := trace('[1]$prolog='||serialize($prolog)) :)
    (: let $_ := trace('[2]$bindings='||serialize($bindings, map{'method':'adaptive'})) :)
    (: let $_ := trace('[3]evaluating PATTERN variable $'||$var/@name|| ' ' || serialize($var)) :)
    
    let $binding := c:evaluate-global-variable(
      $var,
      $instance,
      $prolog ||  utils:local-variable-decls($var) || ' return $' || $var/@name,
      $ns-elems,
      $bindings,
      $options
    )    
    
    (: let $_ := trace('[5]$bindings='||serialize($binding, map{'method':'adaptive'})) :)
    
    return c:evaluate-root-context-variables(
      tail($variables),
      $instance,
      $namespaces,
      $ns-elems,
      $binding,
      $options
    )
};

(:~ 
 : @return updated map of global variable bindings
 : @param variable global variable to evaluate
 : @param instance the document instance
 : @param query the query to evaluate
 : @param ns-elems namespace declarations
 : @param bindings map of global variable bindings
 : @param options map of options
 :)
declare function c:evaluate-global-variable(
  $variable as element(sch:*),
  $instance as node(),
  $query as xs:string?,
  $ns-elems as element(sch:ns)*,
  $bindings as map(*),
  $options as map(*)?
)
as map(*)
{
  (: let $_ := trace('>>>QUERY='||$query) :)
  let $value as item()* := if($variable/@value) 
    then utils:eval(
      $query => utils:escape(),
      map:merge(($bindings, map{'':$instance})),
      map:merge(($options, map{'pass':true()})),
      $variable/@value
    )
    else $variable/*
  let $bindings := map:merge(
    (
      map{utils:variable-name-to-QName($variable/@name, $ns-elems):$value},
      $bindings
    )
  )
  (: let $_ := trace('[4]$bindings='||serialize($bindings, map{'method':'adaptive'})) :)
  return $bindings
};

(:~ Evaluate the pattern/@documents, updating the context map with the documents
 : at the resulting locations. The map is returned unchanged if no such attribute
 : exists.
 : @see ISO2020, 5.4.10: "The optional documents attribute provides IRIs of the
 : subordinate documents the rule contexts are relative to. If the expression 
 : evaluates to more than one IRI, then the pattern is sought in each of the 
 : documents. The documents attribute is evaluated in the context of the 
 : original instance document root."
 : @param documents the documents attribute
 : @param context the validation context
 :)
declare function c:evaluate-pattern-documents(
  $documents as attribute(documents)?,
  $context as map(*)
)
as map(*)
{
  if($documents) 
  then 
    let $uris := utils:eval(
      utils:make-query-prolog($context) || $documents => utils:escape(),
      map:merge(($context?globals, map{'':$context?instance})),
      map{'pass':true()},       (:report exception details:)
      $documents
    )
    return map:put(
      $context, 
      'instance', 
      $uris ! doc(
        resolve-uri(., $context?instance/base-uri())
      )
    )
  else $context
};

(:~ Establish the context against which rule context expressions are evaluated.
 : Normally this will be the instance document, but with phase/@from, this can
 : change.
 : @param context the overall validation context
 :)
declare function c:rule-evaluation-context($context as map(*))
as map(*)
{
  let $from := $context?from
  return
  if($from)
  then
    let $from-context := utils:eval(
      utils:make-query-prolog($context) || $from => utils:escape(), 
      map:merge((map{'':$context?instance}, $context?globals)),
      map{'dry-run':$context?dry-run},
      $from
    )
    return map:merge((map{'':$from-context}, $context?globals))
  else
    map:merge((map{'':$context?instance}, $context?globals))
};