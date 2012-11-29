xquery version "1.0-ml";

import module namespace cpf = "http://marklogic.com/cpf" at "/MarkLogic/cpf/cpf.xqy";

(: Copyright 2002-2012 Mark Logic Corporation.  All Rights Reserved. :)

(:
:: Combines xhtml and ONIX xmldoc to generate master file 
::
:: Uses the external variables:
::    $cpf:document-uri: The document being processed
:)

declare namespace prop="http://marklogic.com/xdmp/property";
declare namespace lnk="http://marklogic.com/cpf/links";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as node() external;
declare variable $cpf:options as node() external;

(
  xdmp:log("combine-xhtml-meta.xqy", "debug"),

  if (cpf:check-transition($cpf:document-uri, $cpf:transition)) then
    try
    {
      (
	xdmp:log(fn:concat("Entered combine-xhtml-meta.xqy: ", $cpf:document-uri), "debug"),
	
	let $master-xml :=
		<master>
			<meta>
			{
				fn:doc(fn:replace($cpf:document-uri, "_pdf.xhtml", ".xml"))
			}	
			</meta>
			<content>
			{
				fn:doc($cpf:document-uri)
			}	
			</content>
		</master>
	
	
	return
	  xdmp:document-insert(
		fn:replace($cpf:document-uri, "_pdf.xhtml", "-master.xml"),
		$master-xml,
		xdmp:default-permissions(), 
		("master", xdmp:default-collections())
	  ),
	cpf:success($cpf:document-uri, $cpf:transition, ()),
	xdmp:log("Exiting combine-xhtml-meta.xqy", "debug")
      )
    } 
    catch ($e) 
    {
      cpf:failure($cpf:document-uri, $cpf:transition, $e, ())
    }
  else
    ()
)
