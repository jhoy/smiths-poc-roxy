xquery version "1.0-ml";

module namespace m = "http://marklogic.com/roxy/lib-onix-html.xqy";

import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare function m:show-report($docuri as xs:string,$reporturi as xs:string) {

  let $report := fn:doc($reporturi)/*:report
  return
  
  <div>
  
    <BR>&nbsp;</BR>
                
                <span id="tabCaption" class="tabCaption">Validation Report</span>
                
                <table CELLSPACING="0" CELLPADDING="0" width="100%" class="contentTable" border="0">
                
                  <tr class="headerRow">
                       <td class="leftCol" width="30%">Filename</td>
                       <td class="centerCol" width="30%">Title</td>
                       <td class="centerCol" width="20%">Author</td>
                       <td class="centerCol" width="10%">Status</td>
                       <td class="centerCol" width="10%"></td>
                       <td class="rightCol">&nbsp;</td>
                   </tr>,
                  
                  {for $file in $report/*:files/*:file
                  order by $file/*:uri/text()
                  return
                        <tr class="dataRow">
                            <td class="leftpad">{$file/*:filename/text()}</td>
                            <td class="leftpad">TEST</td>
                            <td class="leftpad">TEST</td>
                            <td class="leftpad">{if ($file/*:status/text() ne 'OK') then 'OK' else ('ERROR')}</td>
                            <td>
                                <form method="get" action="/admin/editreportdoc.html">
                                     <input type="hidden" value="{$file/*:uri/text()}" name="bookXMLUri" />
                                     <input type="hidden" value="Edit" name="action" />
                                     <input type="submit" value="Edit Document"></input>
                                </form>
                            </td>
                        </tr>}
                  
                  <tr><td><BR>&nbsp;</BR></td></tr>
                  
                  <tr><td><button type="submit" value="Reanalyse " name="action">Reanalyse</button></td>
                            <td><button type="submit" value="Ingest " name="action">Ingest</button></td>
                        </tr>
                    
                </table>
                
                </div>
  
};

declare function m:edit-report-doc($docuri as xs:string) {

let $doc-to-edit := fn:doc($docuri)
  return

<div>

    <!--p>{$docuri}</p-->
    
    <p>{$doc-to-edit}</p>

    <!--form  method="post" action="./profile.xqy">
                    <table border="0" cellspacing="1" cellpadding="1" width="100%" class="formTable">
                        <tr><td class="formTitle" width="30%">Title</td><td>{$studentID}</td></tr>
                        <tr><td class="formTitle">Author</td><td><input type="text" name="surname" value="{$doc//*:surname}"/></td></tr>
                        <tr><td class="formTitle">Publisher</td><td><input type="text" name="firstname" value="{$doc//*:firstname}"/></td></tr>
                        <tr><td class="formTitle">ISBN</td><td><input type="text" name="dob" value="{$doc//*:dob}"/></td></tr>
                        <tr><td class="formTitle">Published Date</td><td><input type="text" name="address" value="{$doc//*:address}"/></td></tr>
                        
                        <tr>
                            <td><button type="submit" value="Insert" name="action">Save</button></td>
                        </tr>
                    </table>
                        
                 </form-->
</div>
};


