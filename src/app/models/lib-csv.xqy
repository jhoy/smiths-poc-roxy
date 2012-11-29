xquery version "1.0-ml";

module namespace m = "http://marklogic.com/lib-csv";

import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";

import module namespace csvh = "http://marklogic.com/lib-csv/html" at "/app/views/helpers/lib-csv-html.xqy";

import module namespace co = "http://marklogic.com/lib-coordinates" at "/app/models/lib-coordinates.xqy";

declare namespace epsg4326 = "http://spatialreference.org/ref/epsg/4326/";

declare option xdmp:mapping "false";

(: 
 : CSV utility module for interactive data cleansing and parameterised conversion to XML
 :
 : Note on returned transform data:-
 : method = document-per-row or one-document. If one-document, document-element and ns will be used for a single xml doc, containing multiple row-element and ns elements. 
 : If document-per-row, top will be a row-element element with row-ns namespace, in multiple xml documents
 : Data cell transform methods include:-
 :   last-first => Turns "Last, First" string in to "First Last" - useful for people's names and placenames ("Longton, Little")
 :)
 
 
 
(:
 : Returns an XML representation of a CSV file, with guessed column titles.
 :
 : Note: If any csv line has a different column count to the first (assumed column names) row, then
 : the error attribute on that row element will have the value column-count.
 :)
declare function m:parse($csvdoc as xs:string) as element(m:report) {
  (: process first row for number of columns (likely the labels) :)
  let $lines := fn:tokenize($csvdoc,"(\r\n?|\n\r?)")
  let $firstline := m:parse-line($lines[1])
  
  (: get some useful info for later :)
  let $columns := fn:count($firstline)
  let $remainder := $lines[2 to fn:count($lines)]
  
  (: Go through each line and see if it matches the number of elements :)
  (: Generate XML for line :)
  (: Generate status (matches, potential error) for each line :)
  
     (: <m:orig>{$csvdoc}</m:orig> :)
  let $report :=
    <m:report>
      if (xdmp:get-current-user()) then
        attribute user {
          xdmp:get-current-user()
        }
      else ()
      ,
      attribute status {"unprocessed"}
      ,
     <m:column-count>{$columns}</m:column-count>
     <m:data-row-count>{fn:count($remainder)}</m:data-row-count>
     <m:column-names>{
       for $col in $firstline
       return
         <m:column>{$col}</m:column>
     }</m:column-names>
     <m:data-rows>{
       for $line at $pos in $remainder
       let $cols := m:parse-line($line)
       return
         element m:row {
         (
           attribute index {
             $pos
           }
           ,
           if (fn:count($cols) ne $columns) then
             attribute error {"column-count"}
           else ()
         
           ,
           for $col at $colidx in $cols
           return
             <m:cell index="{$colidx}">{$col}</m:cell>
         )
       }
     }</m:data-rows>
     <m:transform method="document-per-row" row-element="row" row-ns="" document-element="data" document-ns="" first-row-is-data="false">
     {
       for $col in $firstline
       return
         <m:column-mapping col="{$col}" col-element="{$col}" col-ns="" data-transform=""/>
     }
     </m:transform>
    </m:report>
  
  return
    $report
};

(:
 : Parses a single line. Understands escaped strings using double quotes "", and handles the case where these contain commas
 : (This particular format confuses some software - like LibreOffice - but is the most common)
 :)
declare function m:parse-line($line as xs:string) as xs:string* {
  let $log := xdmp:log(fn:concat("csv:parse-line: ",$line))
  let $commas := fn:tokenize($line,",")
  let $log := xdmp:log(fn:concat("csv:parse-line: Split by commas: ",fn:string-join($commas,"||")))
  let $parts := map:map()
  let $inquote := map:map()
  let $put := map:put($inquote,"inquote",fn:false())
  let $put := map:put($inquote,"curpart",0)
  let $proc :=
    for $part in $commas
    
    let $log := xdmp:log(fn:concat("csv:parse-line: Processing part: ",$part,", are we in a quote?: ", map:get($inquote,"inquote")))
    let $put := map:put($inquote,"curpart",
      if (map:get($inquote,"inquote")) then
        map:get($inquote,"curpart") 
      else
        map:get($inquote,"curpart") + 1
    )
    
    (: Check for starting with Quote :)
    let $startsquote := fn:matches($part,'^"') (: should be starts with (whitespace?) :)
    let $log := if ($startsquote) then xdmp:log("csv:parse-line: This part start with a quote") else()
    let $wasinquote := map:get($inquote,"inquote")
    let $part :=
      if ($startsquote) then
        fn:substring($part,2)
      else
        $part
        
    (: Check for ending with quote :)
    let $endquote := fn:matches($part,'"$')
    let $put := map:put($inquote,"inquote", ((map:get($inquote,"inquote") or $startsquote) and fn:not($endquote)))
    let $log := if ($endquote) then xdmp:log("csv:parse-line: Part ends with quote") else ()
    let $log := if (map:get($inquote,"inquote")) then xdmp:log("csv:parse-line: Still in quoted string") else xdmp:log("csv:parse-line: Not in quoted string")
    let $part :=
      if ($endquote) then
        fn:substring($part,1,fn:string-length($part)-1)
      else
        $part
        
    
    let $log := xdmp:log(fn:concat("csv:parse-line: Part is now: ",$part)  ) 
      
    return
      if (map:get($parts,xs:string(map:get($inquote,"curpart")))) then
        map:put($parts,xs:string(map:get($inquote,"curpart")),fn:concat(map:get($parts,xs:string(map:get($inquote,"curpart"))),",",$part))
      else
        map:put($parts,xs:string(map:get($inquote,"curpart")),$part)
  
  let $text :=
    for $key in map:keys($parts)
    order by xs:int($key) ascending
    return
      map:get($parts,$key)
  
  let $log := xdmp:log(fn:concat("csv:parse-line: resultant parts: ",fn:string-join($text,"||")))
  return $text
};

declare function m:transform($docuri as xs:string,$reporturi as xs:string,$format-name as xs:string?,$ingest-format as xs:string?,
  $doc-name-start as xs:string,$doc-name-end as xs:string,$doc-collections as xs:string?,$doc-transform as xs:string,
  $doc-el-name as xs:string?,$res-el-name as xs:string?) as xs:string {
  
  let $report := fn:doc($reporturi)/m:report
  let $doc-cols := fn:tokenize($doc-collections,",")
  
  (: get column settings :)
  let $col-el := map:map()
  let $col-transform := map:map()
  let $col-enrich := map:map()
  let $doc-count := 0
  let $column-names :=
    for $colel at $cid in $report/m:column-names/m:column
    let $c := csvh:xmlname($colel/text())
    order by xs:integer($colel/@index) ascending
    return
      let $el := xdmp:get-request-field(fn:concat("col-",$cid),$c)
      let $tx := xdmp:get-request-field(fn:concat("transform_",$cid))
      let $en := xdmp:get-request-field(fn:concat("enrichment_",$cid))
      return
        (
          map:put($col-el,xs:string($cid),$el),
          map:put($col-transform,xs:string($cid),$tx),
          map:put($col-enrich,xs:string($cid),$en),
          $c
        )
  
  let $uri-map := map:map()
  
  (: go through results, row by row :)
  (: let $add-result := :)
  let $rows :=
    for $row in $report/m:data-rows/m:row
    order by xs:integer($row/@index) ascending
    return (: returning rows :)
      let $rowout :=
        element {$res-el-name} {
          for $cell at $cid in $row/m:cell
          order by xs:integer($cell/@index) ascending
          return (: returning result element :)
            element {map:get($col-el,xs:string($cid))} {
              (: transform data :)
              let $tx := map:get($col-transform,xs:string($cid))
              let $en := map:get($col-enrich,xs:string($cid))
              let $orig := $cell/text()
              let $transformed :=
                if ($tx) then
                  if ("last-first" = $tx) then
                    (: Bloggs, Joe -> Joe Bloggs :)
                    let $parts := fn:tokenize($orig,",")
                    return
                      fn:string-join(
                        for $part at $pid in $parts
                        order by $pid descending
                        return
                          $part
                      ," ")
                  else
                    (: TODO add other transforms within here :)
                    $orig
                else
                  $orig
                    
              (: enrich data :)
              return (: returning value :)
                if ($en) then
                  if ("osgb-lonlat" = $en) then
                    (: TODO get mathematical OSGB 50000,40000 reference :)
                    (: Translate to EPSG 4326 (US GPS) system :)
                    let $epsg4326 := co:ngr-to-epsg4326($transformed)
                    return (:Probably a neater way to do the below:)
                      element epsg4326:epsg4326 {
                        attribute lon {
                          $epsg4326/@lon
                        }, attribute lat {
                          $epsg4326/@lat
                        },
                        $transformed
                      }
                  else
                    (: TODO add other enrichments within here :)
                    $transformed
                else
                  $transformed
            }
        }
      return (: add of row result to rows :)
        if ("document-per-row" = $doc-transform) then
          let $resuri := fn:concat($doc-name-start,xdmp:random(),$doc-name-end)
          let $map-put-do := map:put($uri-map,$resuri,"1")
          let $doc-count := $doc-count + 1
          return xdmp:document-insert($resuri,$rowout,xdmp:default-permissions(),(xdmp:default-collections(),$doc-cols)) 
        else
          $rowout
    
    let $docout :=
      element {$doc-el-name} {
        $rows
      }
      
    (: Save output summary :)
    let $docdo := 
      if ("one-document" = $doc-transform) then
          let $newdocuri := fn:concat($doc-name-start,xdmp:random(),$doc-name-end)
          let $map-put-do := map:put($uri-map,$docuri,"1")
          let $doc-count := $doc-count + 1
          return xdmp:document-insert($newdocuri,$docout,xdmp:default-permissions(),(xdmp:default-collections(),$doc-cols)) 
      else
        ()
    
      
  let $summary := 
    <m:csv-ingest-report>
      <m:report-uri>{$reporturi}</m:report-uri>
      <m:csv-uri>{$docuri}</m:csv-uri>
      <m:total-documents-created>{$doc-count}</m:total-documents-created>
      <m:document-uris>{for $uri in map:keys($uri-map) return <m:document-uri>{$uri}</m:document-uri>}</m:document-uris>
    </m:csv-ingest-report>
  let $summary-uri := fn:concat("/csvreport/csv-ingest-report-",xdmp:random(),".xml")
  let $summary-insert := xdmp:document-insert($summary-uri,$summary,xdmp:default-permissions(),(xdmp:default-collections(),"csv-ingest-report"))
      
  return $summary-uri
};



