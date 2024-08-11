module namespace g = "x-urn:test:xspec-global-override";

import module namespace mirror = "x-urn:test:mirror" at "mirror.xqm";

declare variable $g:external-value_vs_global-variable as xs:string external := 'default';
declare variable $g:empty-external-value_vs_global-variable as xs:string external := 'default';
declare variable $g:non-external-value_vs_global-variable as xs:string := 'default';

declare function g:variable-values() as xs:string+ {
(
$g:external-value_vs_global-variable,
$g:empty-external-value_vs_global-variable,
$g:non-external-value_vs_global-variable)
};