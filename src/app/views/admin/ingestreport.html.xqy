xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";
import module namespace i = "http://marklogic.com/roxy/lib-importer.xqy" at "/app/views/helpers/lib-importer.xqy";
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";


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

<div xmlns="http://www.w3.org/1999/xhtml" class="admin ingestreport">
  <!--p>This file lives at: C:/MarkLogic/smiths-poc-roxy/src/app/views/admin/ingestreport.html.xqy</p>
  <p>{fn:string(vh:get("message"))}</p-->
  
  <div style="width: 50%; float:left"> <p>{i:generate-master-docs(req:get("reportUri"))}</p></div>
<div style="width: 80%; float:right"> <p>ERROR XML GOES HERE</p></div>
</div>