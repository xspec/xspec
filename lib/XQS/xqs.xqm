module namespace xqs = 'http://www.andrewsales.com/ns/xqs';

import module namespace context = 'http://www.andrewsales.com/ns/xqs-context' at
  'context.xqm';
import module namespace eval = 'http://www.andrewsales.com/ns/xqs-evaluate' at
  'evaluate.xqm';  
import module namespace compile = 'http://www.andrewsales.com/ns/xqs-compile' at
  'compile.xqm';    
import module namespace ie = 'http://www.andrewsales.com/ns/xqs-include-expand'
  at 'include-expand.xqm';  

declare namespace sch = "http://purl.oclc.org/dsdl/schematron";

(:~ Validates a document against a Schematron schema, without options.
 : @param instance the instance document
 : @param schema the Schematron schema
 :)
declare function xqs:validate(
  $instance as node(),
  $schema as element(sch:schema)
)
{
  xqs:check-query-binding($schema),
  eval:schema($instance, ie:include-expand($schema), map{})
};

(:~ Validates a document against a Schematron schema, applying an optional phase.
 : @param instance the instance document
 : @param schema the Schematron schema
 : @param options map of options: key 'phase' specifies the active phase
 :)
declare function xqs:validate(
  $instance as node(),
  $schema as element(sch:schema),
  $options as map(xs:string, xs:string)?
)
{
  xqs:check-query-binding($schema),
  eval:schema($instance, ie:include-expand($schema), $options)
};

(:~ Compiles a Schematron schema.
 : @param schema the Schematron schema
 : @param options map of options: key 'phase' specifies the active phase
 :)
declare function xqs:compile(
  $schema as element(sch:schema),
  $options as map(xs:string, xs:string)?
)
as item()+
{
  xqs:check-query-binding($schema),
  compile:schema(ie:include-expand($schema), $options)
};

(:~ Mandate one of the reserved names for the XQuery query language binding. :)
declare function xqs:check-query-binding($schema as element(sch:schema))
{
  let $query-binding := $schema/@queryBinding
  return
    if (exists($query-binding))
    then
      if(lower-case($query-binding) = ('xquery', 'xquery3', 'xquery31'))
      then ()
      else error(
        xs:QName('xqs:invalid-query-binding'),
        'query language binding must be XQuery',
        $schema/@queryBinding
      )
    else()
};
