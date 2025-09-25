(:~ 
 : Library for evaluating schema assertions. 
 :)

module namespace eval = 'http://www.andrewsales.com/ns/xqs-evaluate';

import module namespace context = 'http://www.andrewsales.com/ns/xqs-context' at
  'context.xqm';
import module namespace dr = 'http://www.andrewsales.com/ns/xqs-dry-run' at
  'dry-run.xqm';  
import module namespace output = 'http://www.andrewsales.com/ns/xqs-output' at
  'svrl.xqm';  
import module namespace utils = 'http://www.andrewsales.com/ns/xqs-utils' at
  'utils.xqm';

declare namespace xqy = 'http://www.w3.org/2012/xquery';  
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";

(:~ Evaluates the schema to produce SVRL output, without processing options.
 : @param instance the document instance
 : @param schema the Schematron schema
 :)
declare function eval:schema(
  $instance as node(),
  $schema as element(sch:schema)
)
{
  eval:schema($instance, $schema, map{})
};

(:~ Evaluates the schema to produce SVRL output, applying the processing options
 : specified.
 : @param instance the document instance
 : @param schema the Schematron schema
 : @param options map of processing options
 :)
declare function eval:schema(
  $instance as node(),
  $schema as element(sch:schema),
  $options as map(xs:string, item())?
)
{
  utils:report-edition($schema, $options),
  if($options?dry-run eq 'true')
  then dr:schema($instance, $schema, $options)  
  else
  let $context as map(*) := context:get-context($instance, $schema, $options)  
  return 
  <svrl:schematron-output>
  {output:schema-title($schema/sch:title)}
  {$schema/@schemaVersion}
  {$schema/@schematronEdition}
  {if($context?phase) then attribute{'phase'}{$context?phase/@id} else ()}
  {output:namespace-decls-as-svrl($schema/sch:ns)}
  {eval:phase($context)}
  </svrl:schematron-output>
};

(:~ Evaluates a pattern.
 : @param pattern the pattern to evaluate
 : @param context the validation context
 :)
declare function eval:pattern(
  $pattern as element(sch:pattern),
  $context as map(*)
)
{
  let $_ := utils:check-duplicate-variable-names($pattern/sch:let)
  
  (:update context in light of @documents:)
  let $context as map(*) := context:evaluate-pattern-documents($pattern/@documents, $context)
  
  (:evaluate pattern variables against global context:)
  let $globals as map(*) := context:evaluate-root-context-variables(
        $pattern/sch:let,
        $context?instance,
        $context?ns-decls,
        $pattern/../sch:ns,
        $context?globals,
        map{'dry-run':$context?dry-run}
      )

  let $context := map:put($context, 'globals', $globals)
  let $rules := $pattern/sch:rule
  
  return (
    if($context?dry-run eq 'true')
    then dr:pattern($context, $rules)
    else (
      <svrl:active-pattern>
      {$pattern/(@id, @name, @role), 
      if($pattern/@documents) then attribute{'documents'}{$context?instance ! base-uri(.)} else()}
      </svrl:active-pattern>, 
      $context?instance 
      ! 
      eval:rules(
        $rules, 
        utils:make-query-prolog($context),
        map:put($context, 'instance', .)
      )
    )
  )
};

(:~ Evaluates a group.
 : @param group the group to evaluate
 : @param context the validation context
 :)
declare function eval:group(
  $group as element(sch:group),
  $context as map(*)
)
{
  let $_ := utils:check-duplicate-variable-names($group/sch:let)
  
  (:update context in light of @documents:)
  let $context as map(*) := context:evaluate-pattern-documents($group/@documents, $context)
  
  (:evaluate pattern variables against global context:)
  let $globals as map(*) := context:evaluate-root-context-variables(
        $group/sch:let,
        $context?instance,
        $context?ns-decls,
        $group/../sch:ns,
        $context?globals,
        map{'dry-run':$context?dry-run}
      )

  let $context := map:put($context, 'globals', $globals)
  
  return	(
    <svrl:active-group>
    {$group/(@id, @name, @role), 
    if($group/@documents) then attribute{'documents'}{$context?instance ! base-uri(.)} else()}
    </svrl:active-group>, 
    eval:all-rules($group/sch:rule, $context)
  )
};

(:~ Evaluates all the rules in a pattern.
 : Initially added for use in dry-run mode, to check for syntax errors.
 : N.B. we don't need to map the instance each time for this purpose, since we 
 : are not evaluating @documents, but this approach could be used for 
 : evaluating sch:rule-set (see https://github.com/AndrewSales/XQS/tree/%234).
 :)
declare function eval:all-rules(
  $rules as element(sch:rule)*,
  $context as map(*)
)
as element()*
{
  $context?instance 
  ! 
  (for $rule in $rules
  return
  eval:rule(
    $rule, 
    utils:make-query-prolog($context),
    map:put($context, 'instance', .)
  ))
};

(:~ Evaluate rules, only further processing those whose context has not already
 : been matched.
 : @see ISO2020 6.5.
 : @param rules the rules to evaluate
 : @param prolog the query prolog consisting of any variable and namespace declarations
 : @param context the validation context
 :)
declare function eval:rules(
  $rules as element(sch:rule)*,
  $prolog as xs:string?,
  $context as map(*)
)
as element()*
{
  if(empty($rules))
  then ()
  else
    let $rule := head($rules)
    let $rule-context := eval:rule-context($rule, $prolog, $context)
    return 
    (
      eval:process-rule($rule, $prolog, $rule-context, $context),
      eval:rules(
        tail($rules), 
        $prolog, 
        (:update the matched contexts each time:)
        map:put(
          $context,
          'matched',
          $context?matched | $rule-context
        )
      )
    )
};

(:~ Evaluate the rule context.
 : @param rule the rule whose context is to be evaluated
 : @param prolog the query prolog consisting of any variable and namespace declarations
 : @param context the validation context
 : @return the rule context
 :)
declare function eval:rule-context(
  $rule as element(sch:rule),
  $prolog as xs:string?,
  $context as map(*)
) as node()*
{
  let $_ := utils:check-duplicate-variable-names($rule/sch:let)
  let $query := string-join(
      ($prolog, $rule/@context),
      ' '
    )
  let $evaluation-context := context:rule-evaluation-context($context)
  let $result:= utils:eval(
    $query => utils:escape(),
    $evaluation-context,
    map{'dry-run':$context?dry-run},
    $rule/@context
  )
  return $result
};

(:~ Evaluates a rule, regardless of whether the context has been matched previously.
 : @param rule the rule to evaluate
 : @param prolog the query prolog consisting of any variable and namespace declarations
 : @param context the validation context
 :)
declare function eval:rule(
  $rule as element(sch:rule),
  $prolog as xs:string?,
  $context as map(*)
)
as element()*
{
  let $rule-context as node()* := eval:rule-context($rule, $prolog, $context)
  return 
  if($rule-context)
  then eval:process-rule($rule, $prolog, $rule-context, $context)
  else ()
};

(:~ Process a rule.
 : @param rule the rule to process
 : @param prolog the query prolog consisting of any variable and namespace declarations
 : @param rule-context the evaluated rule context
 : @param context the validation context :)
declare function eval:process-rule(
  $rule as element(sch:rule),
  $prolog as xs:string?,
  $rule-context as node()*,
  $context as map(*)
)
{
    if($context?dry-run eq 'true')
    then dr:rule($rule, $prolog, $rule-context, $context)
    else
  if(exists($rule-context) and empty($rule-context intersect $context?matched))
  then eval:assertions($rule, $prolog, $rule-context, $context)
  else ()
};

(:~ Evaluates assertions within a rule.
 : @param rule the containing rule
 : @param prolog the query prolog consisting of any variable and namespace declarations
 : @param rule-context the rule context
 : @param context the validation context
 :)
declare function eval:assertions(
  $rule as element(sch:rule),
  $prolog as xs:string?,
  $rule-context as node()+,
  $validation-context as map(*)
)
as element()*
{
  let $prolog := $prolog || utils:local-variable-decls($rule/sch:let)
    || (if($rule/sch:let) then ' return ' else '')
  let $context := eval:visit-each($rule, $prolog, $rule-context, $validation-context)
  
  for $context in $context    
    return 
    (<svrl:fired-rule>
      {$rule/(@id, @name, @context, @visit-each, @role, @flag),
      if($rule/../@documents) then attribute{'document'}{$validation-context?instance/base-uri()} else ()}
      </svrl:fired-rule>,
    ($rule/(sch:assert|sch:report) 
    ! 
    eval:assertion(
      ., 
      $prolog,
      $context,
      $validation-context
    )))
};

(:~ Adjust the rule context by evaluating attribute visit-each against it.
 : @param rule-context the rule context
 :)
declare function eval:visit-each(
  $rule as element(sch:rule),
  $prolog as xs:string?,
  $rule-context as node()*,
  $validation-context as map(*)
)
{
  let $visit-each as attribute(visit-each)? := $rule/@visit-each
  return
  if($visit-each)
  then
    utils:eval(
      $prolog || $visit-each => utils:escape(),
      map:merge((map{'':$rule-context}, $validation-context?globals)),
      map{'dry-run':$validation-context?dry-run},
      $rule/@visit-each
    )
  else $rule-context
};

(:~ Evaluates an assertion.
 : @param assertion the assertion to evaluate
 : @param prolog the query prolog consisting of any variable and namespace declarations
 : @param rule-context the rule context
 : @param context the validation context
 :)
declare function eval:assertion(
  $assertion as element(),
  $prolog as xs:string?,
  $rule-context as node(),
  $context as map(*)
)
{
  let $result := utils:eval(
    $prolog || $assertion/@test => utils:escape(),
    map:merge((map{'':$rule-context}, $context?globals)),
    map{'dry-run':$context?dry-run},
    $assertion/@test
  )
  return
  if($context?dry-run eq 'true')
  then dr:assertion($result, $assertion, $prolog, $rule-context, $context)
  else
  typeswitch($assertion)
    case element(sch:assert)
      return if($result) then () 
        else output:assertion($assertion, $prolog, $rule-context, $context)
    case element(sch:report)
      return if($result) 
        then output:assertion($assertion, $prolog, $rule-context, $context) 
        else ()
  default return error(
    xs:QName('eval:invalid-assertion-element'), 
    'invalid assertion element: '||$assertion/name()
  )
};

(:~ Evaluate a phase.
 : @param context the validation context
 : @see ISO2025 5.5.7 re phase/@from
 :)
declare function eval:phase($context as map(*))
{
  let $phase := $context?phase
  let $_ := utils:check-duplicate-variable-names($phase/sch:let)
  
  let $dry-run as map(*) := map{'dry-run':$context?dry-run}
  
  (:add phase variables to context:)
  let $globals as map(*) := context:evaluate-root-context-variables(
        $phase/sch:let,
        $context?instance,
        $context?ns-decls,
        $phase/../sch:ns,
        $context?globals,
        $dry-run
      )
  let $context := map:put($context, 'globals', $globals)
  let $_:= map:merge(($context, $dry-run))
    
  return
  ($context?patterns ! 
  eval:pattern(., if($phase/@from) then map:put($context, 'from', $phase/@from)
   else $context),
   $context?groups ! 
  eval:group(., if($phase/@from) then map:put($context, 'from', $phase/@from)
   else $context))
};