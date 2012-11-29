xquery version "1.0-ml";
import module namespace trgr="http://marklogic.com/xdmp/triggers" 
   at "/MarkLogic/triggers.xqy";

trgr:create-trigger("Zip Process Trigger", "Zip Process Trigger", 
  trgr:trigger-data-event(
      trgr:directory-scope("/zip-upload/", "infinity"),
      trgr:document-content("create"),
      trgr:post-commit()),
  trgr:trigger-module(xdmp:database("smiths-roxy-modules"), "/", "/triggers/process-zip.xqy"),
  fn:true(), xdmp:default-permissions() )

(:trgr:remove-trigger("Zip Process Trigger"):)