xquery version "1.0-ml";


module namespace c = "http://marklogic.com/roxy/controller/upload";

(: the controller helper library provides methods to control which view and template get rendered :)
import module namespace ch = "http://marklogic.com/roxy/controller-helper" at "/roxy/lib/controller-helper.xqy";

(: The request library provides awesome helper methods to abstract get-request-field :)
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";

import module namespace s = "http://marklogic.com/roxy/models/search" at "/app/models/search-lib.xqy";

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


let $action := xdmp:get-request-field("action")
return

		
	<div id="upload-form" xmlns="http://www.w3.org/1999/xhtml">
		<form name="upload-form" id="uploadForm" action="/do-upload" method="post" enctype="multipart/form-data">
			<table>
				<tr>
					<td>File Name :
					<input type="file" name="upload" size="45" id="upload"/>
					 File Type :<select name="file_type" id="file_type">                                   
						            <option value="zip">ZIP</option>
					</select>
					</td>
				</tr>
					  
				<tr>
					<td><input type="submit" value="Upload"/></td></tr>
			</table>	
		</form>
	</div>
};