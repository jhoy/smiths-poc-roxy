xquery version "1.0-ml";

module namespace m = "http://marklogic.com/lib-csv/html";

import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";

import module namespace csv = "http://marklogic.com/lib-csv" at "/app/models/lib-csv.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare function m:summaries($reports as element(csv:report)*) as element(div) {
  <div>
    {
      for $report at $ridx in $reports
      return
        (element a {
          attribute href {
            fn:concat("/cleanse/csvpreview?uri=",fn:encode-for-uri(fn:base-uri($report)))
          }
          ,
          fn:base-uri($report)
        }
        ,
        element br{})
    }
  </div>
};

declare function m:xmlname($name as xs:string) as xs:string {
  fn:replace(fn:replace($name," ",""),"/","")
};

declare function m:errors($report as element(csv:report),$docuri as xs:string) as element(div) {
  m:render($report,1000,fn:true(),$docuri) (: TODO make unlimited :)
};

declare function m:topresults($report as element(csv:report),$limit as xs:integer,$docuri as xs:string) as element(div) {
  m:render($report,$limit,fn:false(),$docuri)
};

declare function m:render($report as element(csv:report),$limit as xs:integer,$errors as xs:boolean,$docuri as xs:string) as element(div) {
  let $reporturi := fn:base-uri($report)
  return
  <div>
    <form method="POST" action="/cleanse/transformcsv.html">
     <input type="submit" name="submit" value="Save and create XML Documents"/>
     <br/><br/>
     <input type="hidden" name="reporturi" value="{$reporturi}"/>
     <input type="hidden" name="docuri" value="{$docuri}"/>
     
     <label for="ingest-format-name">Ingest Format Name: </label>
     <input name="ingest-format-name" id="ingest-format-name" value=""/> 
     OR
     
     <label for="ingest-format-choose">Choose Ingest Format: </label>
     <select name="ingest-format-choose" id="ingest-format-choose"><option value="__" selected="selected">Unspecified</option></select>
     &nbsp;&nbsp;<span><i>Optional</i></span>
     
     <br/><br/>
     
     <label for="doc-name-start">Document Name Start: </label>
     <input name="doc-name-start" id="doc-name-start" value="/csvxml/"/> 
     <br/>
     <label for="doc-name-end">Document Name End: </label>
     <input name="doc-name-end" id="doc-name-start" value=".xml"/> 
     <br/>
     <label for="doc-collections">Document Collection(s): </label>
     <input name="doc-collections" id="doc-collections" value="csvcleansedxml"/> &nbsp;&nbsp;<span><i>Comma separated list</i></span>
     <br/>
     <label for="doc-transform">Document Transform Method: </label>
     <select name="doc-transform" id="doc-transform">
       {(
         element option {
           attribute value {"one-document"},
           if ($report/csv:transform/@method eq "one-document") then
             attribute selected {"selected"}
           else ()
           ,"Create single document containing all CSV rows"
         },
         element option {
           attribute value {"document-per-row"},
           if ($report/csv:transform/@method eq "document-per-row") then
             attribute selected {"selected"}
           else ()
           ,"Create one document for each CSV row"
         }
       )}
     </select>
     <br/>
     <label for="doc-el-name">Document element name: </label>
     <input name="doc-el-name" id="doc-el-name" value="csvresults"/> &nbsp;&nbsp;<span><i>Single document mode only</i></span>
     <br/>
     <label for="res-el-name">Result element name</label>
     <input name="res-el-name" id="res-el-name" value="result"/>
     
     <br/><br/>
     <i>First {$limit} rows of 
     {
       if ($errors) then
         "rows in error"
       else
         "all rows"
     }
     
     </i><br/>
     <table style="border: 1px solid black; width: 100%;">
      <thead>
        <tr>
          <th>Actions</th>
          {
            for $colname in $report/csv:column-names/csv:column/text()
            return
              <th>{$colname}</th>
          }
        </tr>
        <tr>
          <th>Elements</th>
          {
            for $colel at $cid in $report/csv:column-names/csv:column
            let $c := m:xmlname($colel/text())
            order by xs:integer($colel/@index) ascending
            return
              <th><input style="width:90px;" name="col-{$cid}" value="{$c}"/></th>
          }
        </tr>
        <tr>
          <th>Cell Transforms: </th>
          {
            for $colname at $cid in $report/csv:column-names/csv:column/text()
            let $mapping := $report/csv:transform/csv:column-mapping[./@col eq $colname]
            return
              <th>
                <select name="transform_{$cid}" width="2">
                {(
                  element option {
                    attribute value {"__"},
                    if (fn:not($mapping/@data-transform)) then
                      attribute selected {"selected"}
                    else ()
                    ,"None"
                  },
                  element option {
                    attribute value {"last-first"},
                    if ($mapping/@data-transform eq "last-first") then
                      attribute selected {"selected"}
                    else ()
                    ,"B, J > J B"
                  })
                }
                </select>
              </th>
          }
        </tr>
        <tr>
          <th>Data Enrichment: </th>
          {
            for $colname at $cid in $report/csv:column-names/csv:column/text()
            let $mapping := $report/csv:transform/csv:column-mapping[./@col eq $colname]
            return
              <th>
                <select name="enrichment_{$cid}" width="2">
                {(
                  element option {
                    attribute value {"__"},
                    if (fn:not($mapping/@data-enrichment)) then
                      attribute selected {"selected"}
                    else ()
                    ,"None"
                  },
                  element option {
                    attribute value {"osgb-lonlat"},
                    if ($mapping/@data-enrichment eq "osgb-lonlat") then
                      attribute selected {"selected"}
                    else ()
                    ,"OSGB > GPS"
                  })
                }
                </select>
              </th>
          }
        </tr>
      </thead>
      <tbody>
      {
        let $rows :=
          if ($errors) then
            $report/csv:data-rows/csv:row[./@error][1 to $limit]
          else
            $report/csv:data-rows/csv:row[1 to $limit]
        return
        
        for $row in $rows
        order by xs:integer($row/@index) ascending
        return
          element tr {
            (if ($row/@error) then 
              attribute class {"csverror"}
            else ()
            ),
            (<td><a href="/cleanse/csvrowedit.html?reporturi={fn:encode-for-uri($reporturi)}&amp;rowindex={$row/@index}">Edit</a></td>,
            
              for $cell in $row/csv:cell
              order by xs:integer($cell/@index) ascending
              return
                <td>{$cell/text()}</td>
            )
          }
      }
      </tbody>
     </table>
     <br/><br/>
     <input type="submit" name="submit" value="Save and create XML Documents"/>
    </form>
  </div>
};
