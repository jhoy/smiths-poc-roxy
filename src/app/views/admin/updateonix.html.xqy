xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";
import module namespace oh = "http://marklogic.com/roxy/lib-onix-html.xqy" at "/app/views/helpers/lib-onix-html.xqy";

declare option xdmp:mapping "false";

declare variable $params := 
<params>
    {
        for $i in xdmp:get-request-field-names()[fn:not(. = ("controller", "func", "format"))]
        return
            for $j in xdmp:get-request-field($i)
			
            return
				if ($i eq "docuri") then
				element docuri {$j}
				else if ($i eq "reporturi") then
				element reporturi {$j}
				else if ($i eq "zipuri") then
				element zipuri {$j}
                else if ($i ne "") then
                    element param {
						element name {$i},
						element value {$j}
					}
                else 
                    ()
					
    }
    </params>;

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
  <p>{
	
	for $param in $params//*:param
	return 
	xdmp:node-replace(
		xdmp:unpath(fn:concat("fn:doc('", $params/*:docuri/text(), "')", $param/*:name/text())),
		$param/*:value/text()
	)
	}
	Metadata Updated.  <a href="{fn:concat('/admin/viewreport.html?docuri=', $params/*:zipuri/text(), '&amp;reporturi=', $params/*:reporturi/text())}">Click to return</a> to the Validation Report page</p>
</div>