xquery version "1.0-ml";

module namespace c = "http://marklogic.com/roxy/controller/do-upload";


declare namespace local = "local";
declare namespace zip = "xdmp:zip";


(: the controller helper library provides methods to control which view and template get rendered :)
import module namespace ch = "http://marklogic.com/roxy/controller-helper" at "/roxy/lib/controller-helper.xqy";

(: The request library provides awesome helper methods to abstract get-request-field :)
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";

import module namespace s = "http://marklogic.com/roxy/models/search" at "/app/models/search-lib.xqy";

declare option xdmp:mapping "false";
declare variable $CONTEXT :=
  <context>{
      for $i in xdmp:get-request-field-names()
	  where (fn:not($i eq "upload"))
      return element { $i } { xdmp:get-request-field($i) },
      <user>{ xdmp:get-request-username() }</user>
    }</context>;
	
declare variable $join := fn:string($CONTEXT/join);
declare variable $load-type := fn:string($CONTEXT/load_type);
declare variable $file := xdmp:get-request-field("upload");

(:
 : Usage Notes:
 :
 : use the ch library to pass variables to the view
 :
 : use the request (req) library to get access to request parameters easily
 :
 :)
declare function c:main() as item()*
{
(
xdmp:log(xdmp:get-request-field-filename("upload")),
xdmp:log(xdmp:quote($CONTEXT)),
(:xdmp:log(xdmp:quote(req:get-request()/*)):)
c:upload-file()

)
};

 


declare function c:upload-file() {
	let $filename := xdmp:get-request-field-filename("upload") 
	let $disposition := fn:concat("attachment; filename=""",$filename,"""") 	
	let $filetype := xdmp:get-request-field("file_type")
	


	let $subcollection := if ($filetype eq 'doc') then 'word' else $filetype
	let $file-extn := fn:replace($filename, '^.*\.', '')
	let $file_name := fn:replace($filename, '^.*\\', '')
	let $uri := fn:concat('/zip-upload/', $file_name)
							
	return 
		
			let $document-insert :=
					xdmp:document-insert(
								$uri, 
								$file,
								xdmp:default-permissions(), 
								xdmp:default-collections(), 
								10
							     )
			let $property-insert:=
				xdmp:document-add-properties($uri,
							(			
							<document-type>{fn:string($CONTEXT/doc_type)}</document-type>,				 
							 <uploaded_by>{xdmp:user(xdmp:get-current-user())}</uploaded_by>
							)
						)
			return
			(
			(: for $x in xdmp:zip-manifest(fn:doc($uri))//zip:part/text()
				return
				
					(: MW Can maybe insert ONIX namespace here :)
				
					xdmp:document-insert(fn:concat("/", fn:substring-before($x, "."), "/", $x),
									     xdmp:zip-get(fn:doc($uri), $x)),
					xdmp:document-insert(fn:replace($uri, "zip-upload", "zip-processed"), /),
					xdmp:document-delete($uri), :)
					xdmp:redirect-response('/')
			)

};

declare function c:update-file() {
	let $filename := xdmp:get-request-field-filename("upload") 
	let $disposition := fn:concat("attachment; filename=""",$filename,"""") 
	(:let $x := xdmp:add-response-header("Content-Disposition", $disposition) 
	let $x := xdmp:set-response-content-type( xdmp:get-request-field-content-type("upload")):) 
	let $filetype := xdmp:get-request-field("file_type")
	(:let $file := xdmp:get-request-field("upload"):)

	
	let $subcollection := if ($filetype eq 'doc') then 'word' else $filetype
	let $file-extn := fn:replace($filename, '^.*\.', '')
	let $file_name := fn:replace($filename, '^.*\\', '')
	let $uri := fn:concat('/updatesIn/', $file_name)
	
	let $xml-uri:= 
			fn:concat(fn:replace(fn:replace($uri, fn:concat('^(.*)',"\.",'.*'),'$1'),"sIn",
						"Repository"),'.xml')
						
	return
		
			let $properties := (<doc_date>{}</doc_date>,	
							<target-document>{xdmp:url-decode(fn:string($CONTEXT/target_doc))}</target-document>,
							<document-type>{fn:string($CONTEXT/doc_type)}</document-type>,
							<join-type>{fn:string($CONTEXT/join)}</join-type>,						 
							 <uploaded_by>{xdmp:user(xdmp:get-current-user())}</uploaded_by>
							)
			
			let $document-insert :=
					xdmp:document-insert(
								$uri, 
								$file,
								xdmp:default-permissions(), 
								xdmp:default-collections(), 
								10
							     )
			
			let $property-insert:=
				xdmp:document-add-properties($uri,$properties)
			return if ($join eq "paragraph") then xdmp:redirect-response (fn:concat('/detail', fn:string($CONTEXT/target_doc), '?displaymode=update_para&amp;srcdoc=', fn:encode-for-uri($xml-uri),'&amp;targetdoc=', fn:string($CONTEXT/target_doc)))
			else xdmp:redirect-response(fn:concat('/edit-metadata', fn:replace(fn:encode-for-uri($xml-uri), "update", "doc")))

		

};



