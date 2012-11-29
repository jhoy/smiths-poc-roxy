xquery version "1.0-ml";

module namespace c = "http://marklogic.com/roxy/controller/admin";

declare namespace zip="xdmp:zip";

(: the controller helper library provides methods to control which view and template get rendered :)
import module namespace ch = "http://marklogic.com/roxy/controller-helper" at "/roxy/lib/controller-helper.xqy";

(: The request library provides awesome helper methods to abstract get-request-field :)
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";

import module namespace i = "http://marklogic.com/roxy/lib-importer.xqy" at "/app/views/helpers/lib-importer.xqy";

declare option xdmp:mapping "false";

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
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
};

declare function c:doupload() as item()*
{
  (: 1. upload zip :)
  let $file := xdmp:get-request-field("upload")
  let $fmt := xdmp:get-request-field("fileformat","zip")
  let $mapping := xdmp:get-request-field("validation")
  
  let $mappinglog := xdmp:log(fn:concat("MW: $mapping ", $mapping))
  
  let $uri := fn:concat("/cleansed/",$fmt,"/",xdmp:random(),".",$fmt)
  let $docresult :=
    xdmp:document-insert($uri,$file,xdmp:default-permissions(),(xdmp:default-collections(),"onixcleanse"))   
    
    (: New report code goes here :)
    let $reporturi := fn:concat("/reports/",$fmt,"/",xdmp:random(),"/report.xml")
    let $meta := i:create-meta($uri, $file)
    let $metamapping := i:create-metamapping($mapping)
    let $groups := i:create-groups($mapping, $file)
    let $metalog := xdmp:log(fn:concat("MW: meta ", xdmp:quote($meta)))
    let $grouplog := xdmp:log(fn:concat("MW: groups ", xdmp:quote($groups)))
    let $dotestinsert := xdmp:document-insert($reporturi, <i:report>{$meta}{$metamapping}{$groups}</i:report>,xdmp:default-permissions(),(xdmp:default-collections(),"import-reports"))
    
    return
    
    (
    xdmp:redirect-response(fn:concat("/admin/viewreport.html?docuri=",fn:encode-for-uri($uri),"&amp;reporturi=",fn:encode-for-uri($reporturi))))
	
};

declare function c:viewreport() as item()*
{
  let $reporturi := xdmp:get-request-field("reporturi")
  let $docuri := xdmp:get-request-field("docuri")
  return
  (

  ch:add-value("docuri",$docuri),
  ch:add-value("reporturi",$reporturi),
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
)
};

declare function c:editrepair() as item()*
{

  let $bookXMLUri := xdmp:get-request-field("bookXMLUri")
  let $reportUri := xdmp:get-request-field("reportUri")
  let $zipUri := xdmp:get-request-field("zipUri")
  return
  (
   ch:use-layout("smiths-editrepair"),  
   ch:add-value("bookXMLUri",$bookXMLUri),
   ch:add-value("reportUri",$reportUri),
   ch:add-value("zipUri",$zipUri)
  )
(:
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
:)
};

declare function c:remap() as item()*
{

  let $bookXMLUri := xdmp:get-request-field("bookXMLUri")
  let $reportUri := xdmp:get-request-field("reportUri")
  let $mappingUri := xdmp:get-request-field("mappingUri")
  
  return
  (
   ch:add-value("bookXMLUri",$bookXMLUri),
   ch:add-value("reportUri",$reportUri),
   ch:add-value("mappingUri",$mappingUri)
  )
(:
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
:)
};

declare function c:ingestreport() as item()*
{
  ()
(:
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
:)
};

declare function c:params() as item()*
{
  ()
(:
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
:)
};

declare function c:updateonix() as item()*
{
  ()
(:
  ch:add-value("message", "This is a test message."),
  ch:add-value("title", "This is a test page title"),
  ch:use-view((), "xml"),
  ch:use-layout((), "xml")
:)
};
