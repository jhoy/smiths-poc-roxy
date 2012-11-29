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
	<link href="/css/three-column.less" type="text/css" rel="stylesheet/less"/>
    <link href="/css/app.less" type="text/css" rel="stylesheet/less"/>
    <script src="/js/lib/less-1.3.0.min.js" type='text/javascript'></script>
    <script src="/js/lib/jquery-1.7.1.min.js" type='text/javascript'></script>
    <script src="/js/lib/jquery-ui-1.8.18.min.js" type='text/javascript'></script>
    <!--script src="/js/global.js" type='text/javascript'></script-->
    <script src="/js/app.js" type='text/javascript'></script>
    
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
    <div class="home" id="home">
      <a class="text" href="/" title="Home">My Application</a>
    </div>
    {
      uv:build-user($username, fn:concat("/user/profile?user=", $username), "/user/login", "/user/register", "/user/logout")
    }
    <div class="canvas">
      <div class="header" arcsize="5 5 0 0">
        <label>Search</label>
        <form id="searchform" name="searchform" method="GET" action="/">
	        <input type="text" id="q" name="q" class="searchbox" value="{$q}"/>
	          <div id="suggestions"><!--suggestions here--></div>
	          <div id="searchbutton" class="searchbutton">
              <button type="submit" title="Run Search"><img src="/images/mt_icon_search.gif"/></button>
            </div>
	      </form>
      </div>
      { $sidebar }
      <div class="content">
        { $view }
      </div>
      <div class="footer" arcsize="0 0 5 5"><span class="copyright">&copy; 2012, MarkLogic Corporation, All Rights Reserved.</span>
        <a href="/page/help">My Application Help</a>
        <span class="pipe"> </span>
        <a href="/page/contact">Contact Us</a>
        <span class="pipe"> </span>
        <a href="/page/terms">Terms of Use</a>
      </div>
    </div>
  </body>
</html>
