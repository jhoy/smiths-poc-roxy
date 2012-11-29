xquery version "1.0-ml";

module namespace m = "http://marklogic.com/roxy/lib-onix-html.xqy";

import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";
import module namespace i = "http://marklogic.com/roxy/lib-importer.xqy" at "/app/views/helpers/lib-importer.xqy";

(:declare default element namespace "http://www.w3.org/1999/xhtml"; :)

declare variable $m:EDITABLE-FIELDS := map:map
(
<map:map xmlns:map="http://marklogic.com/xdmp/map">
 <map:entry>
   <map:key>/*:ONIXMessage/*:Product/*:DescriptiveDetail/*:Contributor/*:PersonName/text()</map:key>
   <map:value xsi:type="xs:string"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">Author</map:value>
 </map:entry>
 <map:entry>
   <map:key>/*:ONIXMessage/*:Product/*:DescriptiveDetail/*:Contributor[1]/*:PersonName/*:text()</map:key>
   <map:value xsi:type="xs:string"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">Author</map:value>
 </map:entry>
 <map:entry>
    <map:key>/*:ONIXMessage/*:Product/*:DescriptiveDetail/*:TitleDetail/*:TitleElement/*:TitleText/text()</map:key>
    <map:value xsi:type="xs:string"
       xmlns:xs="http://www.w3.org/2001/XMLSchema"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">Title</map:value>
 </map:entry>
</map:map>
);

declare function m:do-fields($doc, $reporturi, $zipuri) {
let $fields :=
for $i in $doc//text()
where fn:normalize-space($i) ne ""
return 
xdmp:path($i)
return
(
<form name="editfieldsform" method="post" action="/admin/updateonix.html">
	<input type="hidden" name="docuri" value="{fn:base-uri($doc)}"/>
	<input type="hidden" name="reporturi" value="{$reporturi}"/>
	<input type="hidden" name="zipuri" value="{$zipuri}"/>
{
for $edit-field in $fields[. = map:keys($m:EDITABLE-FIELDS)]
let $value := xdmp:unpath(fn:concat("fn:doc('", fn:base-uri($doc), "')", $edit-field))

let $_ := xdmp:log($value)
return 
	(
		<span>{fn:concat($edit-field, ' : (', map:get($m:EDITABLE-FIELDS, $edit-field) , ')')}</span>,
		<br/>,
		<input type="text" id="{$edit-field}" name="{$edit-field}" 
			value="{$value}"/>,
		<br/>	
	)
}
<button type="submit">Submit</button>	
</form>,

<form name="noneditfieldsform">
{	
for $non-edit-field in $fields[fn:not(. = map:keys($m:EDITABLE-FIELDS))]
let $value := xdmp:unpath(fn:concat("fn:doc('", fn:base-uri($doc), "')", $non-edit-field))
let $_ := xdmp:log($value)
return 	
	(
		<span>{$non-edit-field}</span>,
		<br/>,
		<input type="text" id="{$non-edit-field}" name="{$non-edit-field}" 
			value="{$value}" disabled="disabled"/>,
		<br/>	
	)
}
</form>
)

};

declare function m:do-all-fields($doc) {
let $fields :=
for $i in $doc//text()
where fn:normalize-space($i) ne ""
return 
xdmp:path($i)
return
(
<form name="allfieldsform">
{	
for $non-edit-field in $fields
let $value := xdmp:unpath(fn:concat("fn:doc('", fn:base-uri($doc), "')", $non-edit-field))
let $_ := xdmp:log($value)
return 	
	(
		<span>{$non-edit-field}</span>,
		<br/>,
		<input type="text" id="{$non-edit-field}" name="{$non-edit-field}" 
			value="{$value}" disabled="disabled"/>,
		<br/>	
	)
}
</form>
)

};

declare function m:show-report($docuri as xs:string,$reporturi as xs:string) {

  let $report := fn:doc($reporturi)/*:report
  let $reportlog := xdmp:log(fn:concat("MW: report for display", xdmp:quote($report)))
  
 let $error-map := map:map()
  
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
                  
                  order by $group/@name
                  
                  (: let $grouplog := xdmp:log(fn:concat("MW: html view metadata group", xdmp:quote($group))) :)
                  
                  return
                  
                  (:MW: Check whether there is any metadata file :)
                  
                  if (fn:exists($group/i:files/i:metafile[1])) then
                  
                  
                  let $bookuri := $group/i:files/i:metafile[1]//i:uri/text()
                  let $bookstatus := $group/i:files/i:metafile[1]//i:status/text()
                  let $metadata := fn:doc($bookuri)
                  let $author := $metadata/*:ONIXMessage/*:Product/*:DescriptiveDetail/*:Contributor[1]/*:PersonName/text()
                  let $title := $metadata/*:ONIXMessage/*:Product/*:DescriptiveDetail/*:TitleDetail/*:TitleElement/*:TitleText/text()
                  
                  (: let $bookurilog := xdmp:log(fn:concat("MW: html book metadata uri", $bookuri))
                  let $bookstatuslog := xdmp:log(fn:concat("MW: html book metadata status", $bookstatus))
                  let $metadatalog := xdmp:log(fn:concat("MW: html view metadata ", xdmp:quote($metadata))) :)
                  
                  
                  return
                        <tr class="dataRow">
                            <td class="leftpad">{$title}</td>
                            <td class="leftpad">{$author}</td>
                            <td class="leftpad">{if ($bookstatus ne 'OK') then 'ERROR' else ('OK')}</td>
                            <td>
                                <form method="get" action="/admin/editrepair.html">
                                     <input type="hidden" value="{$bookuri}" name="bookXMLUri" />
									 <input type="hidden" value="{$reporturi}" name="reportUri" />
									 <input type="hidden" value="{$docuri}" name="zipUri" />                                     
                                     <input type="submit" value="Edit/Repair Metadata"></input>
                                </form>
								<form method="get" action="/admin/remap.html">
                                     <input type="hidden" value="{$bookuri}" name="bookXMLUri" />
									 <input type="hidden" value="{$reporturi}" name="reportUri" />
									 <input type="hidden" value="{$docuri}" name="zipUri" />
									 <input type="hidden" value="/mappings/default-mapping.xml" name="mappingUri" />                                     
                                     <input type="submit" value="Remap Metadata"></input>
                                </form>
                            </td>
                        </tr>
                        
                  else (
                  
                    let $errorlog := xdmp:log(fn:concat("MW: error in group ", $group/@name))
                    return
                    map:put($error-map, $group/@name, "No Metadata file available")
                    
                  )      
                        
                  }
                  
                  <tr><td><BR>&nbsp;</BR></td></tr>
                  <tr class="dataRow"><td colspan="4">UNIMPORTED BOOKS: </td></tr>,
  
                  {for $key in map:keys($error-map) return
                    <tr class="dataRow">
                    <td colspan="1">{$key}</td>
                    <td colspan="3">{map:get($error-map, $key)}</td></tr>}
           
                  <tr><td><button type="submit" value="Reanalyse " name="action">Reanalyse</button></td>
                  <td><button type="submit" value="DRM Books" name="action">DRM</button></td>
                            <td><form method="post" action="/admin/ingestreport.html">
								<input type="hidden" value="{$reporturi}" name="reportUri" />
								<button type="submit" value="Ingest " name="action">Ingest</button>
								</form></td>
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

declare function m:edit-repair($bookuri as xs:string,$reporturi as xs:string,$zipuri as xs:string) {

  let $report := fn:doc($reporturi)/*:report
  let $reportlog := xdmp:log(fn:concat("MW: report for display", xdmp:quote($report)))
  
  
  return
  (
  <div id="fields">
  
    <BR>&nbsp;</BR>
                
                <span id="tabCaption" class="tabCaption">Edit/Repair Metadata</span>
                
                <table CELLSPACING="0" CELLPADDING="0" width="100%" class="contentTable" border="0">
                
                  <tr class="headerRow">
                       <td class="centerCol" width="50%">Default ONIX</td>
                       <td class="centerCol" width="50%">Current ONIX</td>
                       
                   </tr>,
                  
                  {
				  let $group := $report/i:groups//i:group
                  
                  let $grouplog := xdmp:log(fn:concat("MW: html view metadata group", xdmp:quote($group)))
                  
				  let $metadata := fn:doc($bookuri)
				  let $report-metadata := ($group/i:files/i:metafile[//i:uri eq $bookuri])[1]
                                    
                                    
                  
                  return
				  (
                        <tr class="dataRow">
                            <td class="leftpad">
								<div style="width:400; height:500; overflow: auto;">
								
									{
										m:do-fields($metadata, $reporturi, $zipuri)
									}
								
								</div>
                            </td>
                            <td class="leftpad"><div style="width:400; height:500; overflow: auto;">
								
									{
										m:do-all-fields($metadata)
									}
								
								</div></td>
                            
                        </tr>,
				 
                  
                  <tr><td><BR>&nbsp;</BR></td></tr>,
				  <tr class="dataRow"><td colspan="2">ERRORS:</td></tr>,
				  <tr class="dataRow"><td colspan="2">{$report-metadata/i:status/text()}</td></tr>
				  )
                  }
                  <tr><td colspan="2"><button type="submit" value="Reanalyse " name="action">Update</button></td></tr>                 
                    
                </table>
                
        </div>,
		<div id="xmledit" style="display:none;">
			<BR>&nbsp;</BR>
                
                <span id="tabCaption" class="tabCaption">Edit/Repair Metadata</span>
                
                <table CELLSPACING="0" CELLPADDING="0" width="100%" class="contentTable" border="0">
                
                  <tr class="headerRow">
                       <td class="centerCol" width="50%">Default ONIX</td>
                       <td class="centerCol" width="50%">Current ONIX</td>
                       
                   </tr>,
                  
                  {
				  let $group := $report/i:groups//i:group
                  
                  let $grouplog := xdmp:log(fn:concat("MW: html view metadata group", xdmp:quote($group)))
                  
				  let $metadata := fn:doc($bookuri)
				  let $report-metadata := ($group/i:files/i:metafile[//i:uri eq $bookuri])[1]
                                    
                                    
                  
                  return
				  (
                        <tr class="dataRow">
                            
                            <td class="leftpad" colspan="2"><textarea id="current-meta" cols="50" rows="30">{$metadata}</textarea></td>
                            
                        </tr>,
				 
                  
                  <tr><td><BR>&nbsp;</BR></td></tr>,
				  <tr class="dataRow"><td colspan="2">ERRORS:</td></tr>,
				  <tr class="dataRow"><td colspan="2">{$report-metadata/i:status/text()}</td></tr>
				  )
                  }
                  <tr><td colspan="2"><button type="submit" value="Reanalyse" name="action">Update</button></td></tr>                 
                    
                </table>
		</div>
  )
};

declare function m:remap($bookuri as xs:string,$reporturi as xs:string,$mappinguri as xs:string) {

  let $report := fn:doc($reporturi)/*:report
  let $reportlog := xdmp:log(fn:concat("MW: report for display", xdmp:quote($report)))
  
  
  return
  
  <div>
  
    <BR>&nbsp;</BR>
                
                <span id="tabCaption" class="tabCaption">Remap Metadata</span>
                
                <table CELLSPACING="0" CELLPADDING="0" width="100%" class="contentTable" border="0">
                
                  <tr class="headerRow">
                       <td class="centerCol" width="50%">Current ONIX</td>
                       
                   </tr>,
                  
                  {
				  let $group := $report/i:groups//i:group
                  
                  let $grouplog := xdmp:log(fn:concat("MW: html view metadata group", xdmp:quote($group)))
                  
				  let $metadata := fn:doc($bookuri)
				  let $report-metadata := ($group/i:files/i:metafile[//i:uri eq $bookuri])[1]
                                    
                                    
                  
                  return
				  (
                        <tr class="dataRow">
                            <td colspan="2" class="leftpad"><textarea id="current-meta" cols="50" rows="30">{$metadata}</textarea></td>   
                        </tr>,
				 
                  <tr><td colspan="2">{m:mappings($mappinguri, $bookuri, $reporturi)}</td></tr>,
				  
                  <tr><td><BR>&nbsp;</BR></td></tr>,
				  <tr class="dataRow"><td colspan="2">ERRORS:</td></tr>,
				  <tr class="dataRow"><td colspan="2">{$report-metadata/i:status/text()}</td></tr>
				  )
                  }
                  <tr><td colspan="2"><button type="submit" value="Reanalyse " name="action">Update</button></td></tr>                 
                    
                </table>
                
                </div>
  
};

declare function m:mappings($mappinguri as xs:string, $bookuri as xs:string, $reporturi as xs:string) {
(: new query :)
<div>
	<form name="setmappingform" method="get" action="/admin/remap.html">
	<input type="hidden" name="bookXMLUri" value="{$bookuri}"/>
	<input type="hidden" name="reportUri" value="{$reporturi}"/>
	<select type="dropdown" name="mappingUri">
	{
		for $uri in cts:uris((), (), cts:collection-query("mappings"))
		return 
		<option value="{$uri}">{$uri}</option>
	}
	</select>
	<button type="submit">Change mapping</button>
	</form>
	{
		m:mappings-table($mappinguri)
	}
	
</div>
};

declare function m:mappings-table($mappinguri as xs:string) {
<table CELLSPACING="0" CELLPADDING="0" width="100%" class="contentTable" border="0">
	<tr class="headerRow">
		<th>Alias</th>
		<th>XPath From</th>
		<th>XPath To</th>
	</tr>

	{
		let $_ := xdmp:log(fn:concat("MAP : ", fn:doc($mappinguri)//mappings))
		return
		for $mapping in fn:doc($mappinguri)/*:mappings/*:mapping
		
		return 
		(
			<tr class="dataRow">
				<td><input type="text" size="10" value="{fn:string($mapping/@alias)}"/></td>
				<td><input type="text" size="50" value="{fn:string($mapping/*:from)}"/></td>
				<td><input type="text" size="50" value="{fn:string($mapping/*:to)}"/></td>
			</tr>
		)
	}
</table>
};


