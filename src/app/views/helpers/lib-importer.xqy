xquery version "1.0-ml";

module namespace i = "http://marklogic.com/roxy/lib-importer.xqy";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

import module namespace mem = "http://xqdev.com/in-mem-update" at "/MarkLogic/appservices/utils/in-mem-update.xqy";
      
declare namespace mime="http://marklogic.com/xdmp/mimetypes";

declare namespace zip="xdmp:zip";


(: Step 1 - import -> Done on Wednesday :)

declare function i:create-report() as element(i:report){

(: 1. upload doc :)
  let $file := xdmp:get-request-field("upload")
  let $fmt := xdmp:get-request-field("fileformat","zip")
  let $uri := fn:concat("/cleansed/",$fmt,"/",xdmp:random(),".",$fmt)
  let $docresult :=
    xdmp:document-insert($uri,$file,xdmp:default-permissions(),(xdmp:default-collections(),"onixcleanse"))
    
  (: 2. unzip and process :)
  
  return <i:report><i:files>
  {
  for $x in xdmp:zip-manifest($file)//zip:part/text() return
  
    let $fileuri := fn:concat("/zipcontent/",xdmp:random(),"/", fn:substring-before($x, "."), "/", $x)
    
    return
    
    let $filecontent := xdmp:zip-get($file, $x)
    let $file-extn := fn:replace($x, '^.*\.', '')
    let $file-name := fn:replace($x, '^.*\\', '')
    
    return
    
    if ($file-extn = ('pdf','ebk','xml')) then
    
    let $docout := xdmp:document-insert($fileuri, $filecontent) (: TODO perform fixing :)
    
    return
    
    if ($file-extn eq 'xml') then
    
       (: validate XML schema :)
       let $schema-err:=
       try {
           validate strict {$filecontent}
       } 
          catch ($err) 
       {
        $err
       }
       
       return
       
       element file {
        if ($schema-err) then
          element status {$schema-err}
        else (element status {'OK'}),
       element uri {$fileuri}, 
       element ext {$file-extn},
       element filename {$file-name}
      }
      
    else (
    
    (: element file {
       element uri {$fileuri}, 
       element ext {$file-extn}
       } :)
    )
    
    else ()
    
    }
    
    </i:files></i:report>

};

declare function i:create-meta($uri as xs:string*, $file) as element(i:meta)* {

    let $meta-out :=
    
    <i:meta>
        <i:source-archive>
            <i:formatmime>application/zip</i:formatmime>
            <i:uri>{$uri}</i:uri>
            <i:files>
            {
                for $fn in xdmp:zip-manifest($file)//zip:part/text()
                
                let $file-uri := fn:tokenize($fn, "/")[fn:last()]
                let $group-name := fn:replace($file-uri, '[.][^.]+$', '')
                let $file-extn := fn:replace($fn, '^.*\.', '')
                
                return
                
                if ($file-extn = ('pdf','epub','xml')) then
                
                <i:file>
                    <i:name>{$fn}</i:name>
                    <i:uri>{fn:concat("/", $group-name, "/", $file-uri)}</i:uri>
                </i:file>
                
                else ()
                
            }
            
            </i:files>
        </i:source-archive>
        
        <i:import-date>Some W3C date here</i:import-date>
        <i:import-user>admin</i:import-user>
        <i:status>unprocessed</i:status>
    </i:meta>
    
    return
    
    $meta-out
    
};

declare function i:create-metamapping($mapping-file) as element(i:meta-mappings)* {

    let $meta-mapping :=
    
    (: MW: Hardcoded for PoC :)
    
    <i:meta-mappings>
        
        {if ($mapping-file ne 'NONE') then
        
        <i:use-meta-mapping>/mappings{$mapping-file}</i:use-meta-mapping> 
        
        else ()
        }
    </i:meta-mappings>
    
    return
    
    $meta-mapping
    
};


(: Step 2 - import, generate report :)

declare function i:create-groups($mapping-file, $file) as element(i:groups)* { 

  (: group files by first part of file name using map structure :)
  let $group-map := map:map()
  
  let $grouped-out :=
    
    for $fn in xdmp:zip-manifest($file)//zip:part/text()
    
        let $file-uri := fn:tokenize($fn, "/")[fn:last()]
        let $group-name := fn:replace($file-uri, '[.][^.]+$', '')
        let $file-extn := fn:replace($fn, '^.*\.', '')
        let $filecontent := xdmp:zip-get($file, $fn)
        
        let $mappinglog := xdmp:log(fn:concat("MW: $mappinglog ", $mapping-file))
    
        return
    
        if ($file-extn = ('pdf','epub','xml')) then
            
            (: MW: Insert document :)
            let $docout := xdmp:document-insert(fn:concat("/", $group-name, "/", $file-uri), $filecontent, xdmp:default-permissions(),(xdmp:default-collections(),"imported-unprocessed-file"))
            
            let $schema-err :=
            
                if ($file-extn eq 'xml' and $mapping-file ne 'NONE') then
                
                (: MW: map supplier specific fields to ONIX3.0 schema :)
            
                try {
                    
                    validate strict {$filecontent}
                } 
                catch ($err) 
                {
                    $err
                }
            
                else (<noerror><format-string>OK</format-string></noerror>)
            
            (: let $schemaerrlog := xdmp:log(fn:concat("MW: $schemaerrlog ", xdmp:quote($schema-err))) :)
            
            let $fileinfo := (
                <i:name>{$group-name}</i:name>,
                <i:ext>{$file-extn}</i:ext>,
                <i:uri>{fn:concat("/", $group-name, "/", $file-uri)}</i:uri>,
                if ($schema-err) then
                    <i:status>{$schema-err/*:format-string/text()}</i:status>
                else ()
            )
      
            let $thisfile := 
                if ($file-extn eq "xml") then
                    <i:file i:type="metadata">{$fileinfo}
                    </i:file>
                else
                    <i:file i:type="content">{$fileinfo}
                    </i:file>
                    
            (: let $thisfilelog := xdmp:log(fn:concat("MW: thisfile ", xdmp:quote($thisfile))) :)
    
            return
    
            if ($group-name = map:keys($group-map)) then
                let $thisfilelog := xdmp:log("MW: Update group")
                let $temp-group :=
                    map:put($group-map, $group-name, (map:get($group-map,$group-name), $thisfile))
                return $temp-group
            else 
                let $thisfilelog := xdmp:log("MW: Add new group")
                let $temp-group :=
                    map:put($group-map, $group-name, $thisfile)
                return $temp-group
                
          
  else ()
  
  (: let $groupedlog := xdmp:log(fn:concat("MW: group-map ", xdmp:quote($group-map))) :)
  
   let $groups := 
                
                <i:groups>
                
                {
                
                for $key in map:keys($group-map) return
                
                element i:group {
                    attribute name {$key},
                
                        element i:files {
                    
                        for $files in map:get($group-map,$key) return
                    
                            for $file in $files return
                            
                                if ($file/@i:type eq "metadata") then
                                    
                                    element i:metafile {
                                        element i:uri {
                                            $file/i:uri/text()
                                            },
                                        element i:status {
                                            $file/i:status/text()
                                            },
                                        () 
                                    }
                                
                                else if ($file/@i:type eq "content") then
                            
                                let $mime := i:get-mime($file/i:ext/text())
                                return
                                    element i:contentfile {
                                        element i:uri {
                                        $file/i:uri/text()
                                        },
                                        element i:formatmime {
                                            $mime/name/text()
                                    },
                                    ()  
                                }
                                
                                else ()
                    }
               }
               }
               </i:groups>
               
               return $groups
  
};

declare function i:get-mime($ext as xs:string) as element(mime:mimetype)? {
    
  let $config := admin:get-configuration()
  return admin:mimetypes-get($config)/mime:mimetype[fn:contains(./mime:extensions/text(),$ext)] (: TODO check this works for all XML enum types :)
};


declare function i:shortname($fn as xs:string) as xs:string {
    let $slash-positions := fn:index-of($fn,"/")
    let $last-slash := ($slash-positions[fn:last()],0)[1]
  
    return fn:substring($fn,$last-slash + 1)
  
};

(: Step 3 - alter report -> TODO :)

(: TODO update ONIX30 via mappings function :)



(: Step 4 - generate output documents :)

(: NB Following function assumes a re-evaluate has been called since the last save on the report. I.e. that the contents of all <i:generated-onix30> is complete and valid. :)
declare function i:complete-import($report as element(i:report)) {
  let $reporturi := fn:base-uri($report)
  let $doit-out :=
    (: loop through all groups :)
    for $group in $report/i:groups/i:group
    (: get onix metadata :)
    let $generatedmeta := <i:generated-meta>{$group/i:metafiles/i:metafile/i:generated-output/*}</i:generated-meta> (: Collates all approved meta data :)
    return
      (: loop through all content files, generating ISYS where applicable/possible. :)
      for $content in $group/i:contentfiles/i:contentfile
      let $curi := $content/i:uri/text()
      (: TODO add check for only supported isys formats to be processed :)
      let $isysout := xdmp:document-filter(fn:doc($curi))
      let $isysmeta := 
        for $meta in $isysout//*:meta
        return element {fn:concat("ISYS-",$meta/@name)} {fn:string($meta/@content)}
      let $fname := fn:replace(i:shortname($curi),".","__")
      let $genuri := fn:concat("/imported/",xdmp:random(),"/",$fname,"__isys.xml")
      return
        (
          xdmp:document-insert($genuri,$isysout,xdmp:default-permissions(),(xdmp:default-collections(),"import-processed")),
          xdmp:document-set-properties($genuri,($generatedmeta,$isysmeta,<i:import-report>{$reporturi}</i:import-report>,<i:import-report-group>{$group/@id/text()}</i:import-report-group>)),
          xdmp:node-insert-after($content/i:uri,<i:output-isys-uri>{$genuri}</i:output-isys-uri>)
        )
        
  return
    (:  update report (will only have affect after transaction completes) - content file gen info, report status :)
    xdmp:node-replace($report/i:meta/i:status,<i:status>processed</i:status>)      
};

declare function i:generate-master-docs($import-doc-uri) {
let $log := xdmp:log($import-doc-uri)
let $import-doc := fn:doc($import-doc-uri)
return
for $meta-file-uri in $import-doc//i:metafile/i:uri/text()
let $meta-file-element := $import-doc//i:metafile[i:uri eq $meta-file-uri]
let $content-file-elements := $import-doc//i:contentfile[fn:contains(./i:uri/text(), fn:substring-before($meta-file-uri, '.xml'))]

	let $master-xml :=
		<master>
			<meta>
			{
				$meta-file-element
			}	
			</meta>
			<content>
			{
				for $content-file-element in $content-file-elements
				return
				<i:contentfile>
				{
					($content-file-element/@*, $content-file-element/*),
					if (fn:contains($content-file-element/i:uri/text(), ".pdf")) then
					<i:output-isys-data>
					{
						xdmp:document-filter(fn:doc($content-file-element/i:uri/text()))/*
					}
					</i:output-isys-data>
					else ()
					
				}
				</i:contentfile>
			}	
			</content>
		</master>
	
	
	return
	  xdmp:document-insert(
		fn:replace($meta-file-uri, ".xml", "-master.xml"),
		$master-xml,
		xdmp:default-permissions(), 
		("master", xdmp:default-collections())
	  )



};

