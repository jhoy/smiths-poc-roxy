xquery version "1.0-ml";

import module namespace trgr='http://marklogic.com/xdmp/triggers'
at '/MarkLogic/triggers.xqy';

declare namespace local = "local";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace zip="xdmp:zip";

declare variable $trgr:uri as xs:string external;
declare variable $trgr:trigger as node() external;

(
xdmp:log("Trying to unzip..."),
for $x in xdmp:zip-manifest(doc($trgr:uri))//zip:part/text()
return

(: MW Can maybe insert ONIX namespace here :)

xdmp:document-insert(fn:concat("/", fn:substring-before($x, "."), "/", $x),
xdmp:zip-get(doc($trgr:uri), $x)),
xdmp:document-insert(fn:replace($trgr:uri, "zip-upload", "zip-processed"), $trgr:trigger),
xdmp:document-delete($trgr:uri)
)

