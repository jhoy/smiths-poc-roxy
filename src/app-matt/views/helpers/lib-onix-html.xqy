xquery version "1.0-ml";

module namespace m = "http://marklogic.com/roxy/lib-onix-html.xqy";

import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";
import module namespace i = "http://marklogic.com/roxy/lib-importer.xqy" at "/app/views/helpers/lib-importer.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare function m:show-report($docuri as xs:string,$reporturi as xs:string) {

  let $report := fn:doc($reporturi)/*:report
  let $reportlog := xdmp:log(fn:concat("MW: report for display", xdmp:quote($report)))
  
  
  return
  
  <div>
  
    <BR>&nbsp;</BR>
                
                <span id="tabCaption" class="tabCaption">Validation Report</span>
                
                <table CELLSPACING="0" CELLPADDING="0" width="100%" class="contentTable" border="0">
                
                  <tr class="headerRow">
                       <td class="centerCol" width="30%">Title</td>
                       <td class="centerCol" width="20%">Author</td>
                       <td class="centerCol" width="10%">Status</td>
                       <td class="centerCol" width="10%"></td>
                       <td class="rightCol">&nbsp;</td>
                   </tr>,
                  
                  {for $group in $report/i:groups//i:group
                  
                  let $grouplog := xdmp:log(fn:concat("MW: html view metadata group", xdmp:quote($group)))
                  
                  (:MW: Handle one metafile for PoC :)
                  
                  let $bookuri := $group/i:files/i:metafile[1]//i:uri/text()
                  let $bookstatus := $group/i:files/i:metafile[1]//i:status/text()
                  let $metadata := fn:doc($bookuri)
                  let $author := $metadata/*:ONIXMessage/*:Product/*:Contributor[1]/*:PersonName/text()
                  let $title := $metadata/*:ONIXMessage/*:Product/*:Title/*:TitleText/text()
                  
                  let $bookurilog := xdmp:log(fn:concat("MW: html book metadata uri", $bookuri))
                  let $bookstatuslog := xdmp:log(fn:concat("MW: html book metadata status", $bookstatus))
                  let $metadatalog := xdmp:log(fn:concat("MW: html view metadata ", xdmp:quote($metadata)))
                  
                  order by $group/@i:name/text()
                  
                  return
                        <tr class="dataRow">
                            <td class="leftpad">{$title}</td>
                            <td class="leftpad">{$author}</td>
                            <td class="leftpad">{if ($bookstatus ne 'OK') then 'ERROR' else ('OK')}</td>
                            <td>
                                <form method="get" action="/admin/editreportdoc.html">
                                     <input type="hidden" value="{$bookuri/text()}" name="bookXMLUri" />
                                     <input type="hidden" value="Edit" name="action" />
                                     <input type="submit" value="Edit Document"></input>
                                </form>
                            </td>
                        </tr>}
                  
                  <tr><td><BR>&nbsp;</BR></td></tr>
                  
                  <tr><td><button type="submit" value="Reanalyse " name="action">Reanalyse</button></td>
                  <td><button type="submit" value="DRM Books" name="action">DRM</button></td>
                            <td><button type="submit" value="Ingest " name="action">Ingest</button></td>
                        </tr>
                    
                </table>
                
                </div>
  
};

declare function m:edit-report-doc($docuri as xs:string) {

let $doc-to-edit := fn:doc($docuri)
let $onix-schema := fn:doc("/core/ONIX_Book.xml")
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
                            <td><button type="submit" value="DRM Book" name="action">DRM</button></td>
                        </tr>
                    </table>
                        
                 </form-->
</div>
};


