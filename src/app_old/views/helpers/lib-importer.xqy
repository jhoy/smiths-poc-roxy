xquery version "1.0-ml";

module namespace i = "http://marklogic.com/roxy/lib-importer.xqy";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
      
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

(: Step 2 - import, generate report -> utility functions to add to wednesday's work:)

declare function i:create-groups($filenames as xs:string*) as element(i:groups)* { 
  (: group files by first part of file name using xml structure :)
  let $grouped := <i:groups-inter><i:group-inter /></i:groups-inter>
  let $grouped-out :=
    for $fn in $filenames
    let $slash-positions := fn:index-of($fn,"/")
    let $last-slash := ($slash-positions[fn:last()],0)[1]
  
    let $dot-positions := fn:index-of($fn,".")
    let $last-dot := ($dot-positions[fn:last()],fn:string-length($fn))[1]
  
    let $shortname := fn:substring($fn,$last-slash + 1)
    let $shortpart := fn:substring($fn,$last-slash + 1,$last-dot)
    let $ext := fn:substring($fn,$last-dot)
    
    let $groupinter := $grouped/i:group-inter[./shortpart eq $shortpart]
    let $fileinfo := (
         <i:shortname>{$shortname}</i:shortname>,
         <i:shortpart>{$shortpart}</i:shortpart>,
         <i:ext>{$ext}</i:ext>,
         <i:uri>{$fn}</i:uri>
      )
    let $thisfile := 
      if ($ext eq ".xml") then
        <i:file i:type="metadata">{$fileinfo}
        </i:file>
      else
        <i:file i:type="content">{$fileinfo}
        </i:file>
    
    return
      if ($groupinter) then
        fn:insert-before($groupinter/i:files/i:file[1],0,
            $fileinfo
          )
      else 
        fn:insert-before($grouped/i:group-inter[1],0,
            <i:inter-group><i:shortpart>{$shortpart}</i:shortpart><i:files>{$fileinfo}</i:files></i:inter-group>
          )
  
  let $groups := 
    for $group in $grouped/i:group-inter[./i:shortpart]
    let $metas := $group/i:files/i:file[@i:type = "metadata"]
    let $content := $group/i:files/i:file[@i:type = "content"]
    return
      element i:group {
        attribute id {xdmp:random()},
        element i:metafiles {
          for $meta in $metas
          return
            element i:metafile {
              element i:uri {
                $meta/text()
              },
              () (: TODO add any other info here. E.g. from processed meta XML file. Or even do the processing here :)
            }
        },
        element i:contentfiles {
          for $c in $content
          let $mime := i:get-mime($c/text())
          return
            element i:contentfile {
              element i:uri {
                $c/text()
              },
              element i:formatmime {
                $mime/name/text()
              },
              () (: TODO any other doc info here such as mime type, or processed content ref :)
              
            }
        }
      }

  return <i:groups>{$groups}</i:groups>
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

