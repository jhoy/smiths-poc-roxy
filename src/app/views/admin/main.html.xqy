xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";
import module namespace i = "http://marklogic.com/roxy/lib-importer.xqy" at "/app/views/helpers/lib-importer.xqy";

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

<div xmlns="http://www.w3.org/1999/xhtml" class="cleanse upload">
  <h2>File Upload</h2>
  
  <form action="/admin/doupload.html" method="POST" enctype="multipart/form-data">
    <h3>Upload Zip file</h3>
    <label for="upload">File: </label>
    <input type="file" id="upload" name="upload" size="50"/>
    <br/>
    <div>
        <label for="validation">Validation Schema: </label>
        <select name="validation" id="validation">
            <option value="NONE">None Selected</option>
            <option value="ONIX3.0">ONIX 3.0 Schema</option>
            {for $mapping-file in fn:collection("mapping-file") return
            <option value="{$mapping-file/i:name/text()}">{$mapping-file/i:name/text()}</option>}
        </select>
    </div>
    <br/>
    <input type="submit" value="Upload"/>
    <input type="hidden" name="fileformat" value="zip"/>
  </form>
</div>