xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";
import module namespace oh = "http://marklogic.com/roxy/lib-onix-html.xqy" at "/app/views/helpers/lib-onix-html.xqy";

declare option xdmp:mapping "false";

(: use the vh:required method to force a variable to be passed. it will throw an error
 : if the variable is not provided by the controller :)
(:
  declare variable $title as xs:string := vh:required("title");
    or
  let $title as xs:string := vh:required("title");
:)

(: grab optional data :)
(:
  declare variable $stuff := vh:get("stuff");
    or
  let $stuff := vh:get("stuff")
:)


<div xmlns="http://www.w3.org/1999/xhtml" class="admin viewreport">
  <!--p>{fn:string(vh:get("message"))}</p-->
  <!--p>{fn:string(vh:get("docuri"))}</p-->
  <p>{oh:edit-repair(vh:get("bookXMLUri"), vh:get("reportUri"), vh:get("zipUri"))}</p>
</div>