(: This file is just for checking to see if the XQuery processor is able to run version 3.1 :)

xquery version "3.1";

let $map := map {'foo': 'bar'}
return
	$map?foo
