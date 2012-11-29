xquery version "1.0-ml";

(: Copyright 2002-2008 Mark Logic Corporation.  All Rights Reserved. :)

(:
:: Condition to check whether the document is a html document. It assumes all .xhtml docs are html docs
::
:: Uses the external variables:
::    $cpf:document-uri: The document being processed
:)

declare namespace cpf = "http://marklogic.com/cpf";
declare namespace prop="http://marklogic.com/xdmp/property";
declare namespace lnk="http://marklogic.com/cpf/links";

declare variable $cpf:document-uri as xs:string external;

(
xdmp:log("is-xhtml.xqy", "debug"),
let $retval as xs:boolean := fn:ends-with($cpf:document-uri, ".xhtml")
let $log := xdmp:log(fn:concat("[is-xhtml.xqy] returning ", $retval, " for ", $cpf:document-uri), "debug")
return $retval
)