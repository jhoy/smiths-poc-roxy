xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at "/roxy/lib/view-helper.xqy";

declare variable $view as item()* := vh:get("view");
declare variable $column3 as item()* := vh:get("column3");
declare variable $sidebar as item()* := vh:get("sidebar");
declare variable $title as xs:string? := vh:get("title");
declare variable $username as xs:string? := vh:get("username");
declare variable $q as xs:string? := vh:get("q");

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>{$title}</title>
    <!--link href="/css/reset.css" type="text/css" rel="stylesheet/less"/-->
    <link href="/css/themes/ui-lightness/jquery-ui.css" type="text/css" rel="stylesheet"/>
    <!--link href="/css/var.less" type="text/css" rel="stylesheet/less"/-->
	<link href="/css/smiths-three-column.less" type="text/css" rel="stylesheet/less"/>
    <link href="/css/app.less" type="text/css" rel="stylesheet/less"/>
    <script src="/js/lib/less-1.3.0.min.js" type='text/javascript'></script>
    <script src="/js/lib/jquery-1.7.1.min.js" type='text/javascript'></script>
    <script src="/js/lib/jquery-ui-1.8.18.min.js" type='text/javascript'></script>
    <!--script src="/js/global.js" type='text/javascript'></script-->
    <script src="/js/app.js" type='text/javascript'></script>
	<script src="/js/editrepair.js" type='text/javascript'></script>
    
    <!-- CSS -->
    <link rel="stylesheet" type="text/css" media="screen" href="/css/bertramsv419.css"/>
    <link rel="stylesheet" type="text/css" media="print" href="/css/printv419.css"/>
    <!--
    <script type="text/javascript" src="/js/lib/jquery.js"></script>
    <script type="text/javascript" src="/js/lib/jquery-ui.js"></script>
	
    <script type="text/javascript" src="/js/lib/thickbox.js"></script>
    
	<script type="text/javascript" src="/js/lib/jquery-calendar.js"></script>
    -->
    <link rel="stylesheet" href="/css/thickbox.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/css/jquery-calendar.css" type="text/css" media="screen"/>
    <link rel="stylesheet" href="/css/jquery.css" type="text/css" media="screen"/>
    
    <!--  standard BLS javascript functions -->
    <script src="/js/blsapplicationv406.js" type="text/javascript"></script>
    
  </head>
  
  <body>
  
    <div id="centre">
        <div>
            <div>
                <table id="topbar" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                    <tr>
                        <td style="padding:0px 35px 0px 17px" width="149px">
                            <div id="logo"></div> 
                            <div style="font-size:8px; padding-top: 5px; text-align:center;"> 
                            Powered by MarkLogic       
                            </div>
                        </td>
                        
                        <td style="text-align:center; padding: 0px 20px 0px 0px" width="215px">
                        <span style="font-size:large; font-weight:bold;">Call us on <br></br>01274 853500</span><br></br>
                        <span>our customer services<br></br>team is here to help</span>
                        </td> 
                          
                        <td style="padding: 0px 30px 0px 0px; vertical-align: bottom;" width="90px">
                            <a href=""></a>
                        </td>  
                         
                        <td valign="middle">
            
                        <div>
                            <form name="LoginForm" method="post" action="https://libraryservices.bertrams.com/BertramLibraryServices/login.do" onsubmit="return validateLoginForm(this);">
                            <table>
                                <tbody>
                                    <tr>
                                        <td valign="top" width="115px">
                                            <label for="logonId">Logon Id:</label>
                                        </td>
                                        <td valign="top" width="115px">
                                            <label for="password">Password:</label>
                                        </td>
                                    </tr>
                                    
                                    <tr>
                                    <td>
                                        <input name="logonId" style="width: 130px" type="text"></input>
                                    </td>
                                    
                                    <td>
                                        <input name="password" value="" style="width: 130px;" type="password"></input>
                                    </td>
                                    
                                    <td></td>
                                    <td>
                                        <button type="submit" class="imgButton" style="width: 86px; height: 17px;" id="loginSubmit">
                                        <img src="/images/10login.gif" alt="Log In"></img>
                                        </button>
                                    </td>
                                    
                                    </tr>
                                </tbody>
                               </table>
                            
                               </form>
                            </div>
                       
                       <div>
                        <div id="errorsAndMessagesDisplay"></div>
                       </div>      
                        </td>
                           
                    <td style="float:right" valign="top">
                        <div class="nowrap"></div>
                    </td>
                        
                        
                    </tr>
                    </tbody>
                    
                    </table>

</div></div>
 
        <table border="0" cellpadding="0" cellspacing="1" width="100%">
            <tbody>
                <tr valign="top">
                    <td id="nav_tile" valign="top">
                        <div class="nowrap" id="nav_sizing">
                            <div id="link_container">
                                <div id="tabs">
    
    <ul>
        <li id="selected"><a href="/admin">Administration</a></li>
        <li><a href="/">Search</a></li>

</ul>
</div>

</div>
                        </div>
                    </td>
                </tr>
                
                <!--tr valign="top">
                    <td id="nav_tile2" style="padding:0px 0px 0px 17px" valign="top">
                        <div class="nowrap" id="nav_sizing">
                            <div id="link_container">
                                <div id="subLinks">
    
</div>
</div>
                        </div>
                    </td>
                </tr-->
                
                </tbody>
        </table>
  
    <div class="colmask threecol">
		<div class="search threecol">
        <label>Search</label>
        <form id="searchform" name="searchform" method="GET" action="/">
          <input type="text" id="q" name="q" class="searchbox" value="{$q}"/>
          <div id="suggestions"><!--suggestions here--></div>
          <button type="submit" title="Run Search"><img src="/images/mt_icon_search.gif"/></button>
        </form>
      </div>
        <div class="colmid">
            <div class="colleft">
                <div class="col1">
                  {$view}
                </div>
                <div class="col2">
                  {$sidebar}
                </div>
                <div class="col3">
                  {$column3}
                </div>
            </div>
        </div>
    </div>
    
    </div>
    
    <!-- Footer -->
    
    <div id="footer">
      <img src="/images/ml-logo.gif" style="float:right;"/>
    </div>
    
  </body>
</html>