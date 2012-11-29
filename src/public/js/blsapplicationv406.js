// blsapplication.js
	var dtCh= "/";
	var minYear=1900;
	var maxYear=2100;
	var waitImage = new Image();
	waitImage.src = "/BertramLibraryServices/img/buttons/10wait.gif";
	var prevImage = new Image();
	var prevButtonHeight = 0;
	var prevButtonWidth = 0;
	var button;
	
	function isInteger(s){
		var i;
	    for (i = 0; i < s.length; i++){   
	        // Check that current character is number.
	        var c = s.charAt(i);
	        if (((c < "0") || (c > "9"))) return false;
	    }
	    // All characters are numbers.
	    return true;
	}
	
	function stripCharsInBag(s, bag){
		var i;
	    var returnString = "";
	    // Search through string's characters one by one.
	    // If character is not in bag, append to returnString.
	    for (i = 0; i < s.length; i++){   
	        var c = s.charAt(i);
	        if (bag.indexOf(c) == -1) returnString += c;
	    }
	    return returnString;
	}
	
	function daysInFebruary (year){
		// February has 29 days in any year evenly divisible by four,
	    // EXCEPT for centurial years which are not also divisible by 400.
	    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
	}
	function DaysArray(n) {
		for (var i = 1; i <= n; i++) {
			this[i] = 31
			if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
			if (i==2) {this[i] = 29}
	   } 
	   return this
	}
	
	function isDate(dtStr){
		var daysInMonth = DaysArray(12)
		var pos1=dtStr.indexOf(dtCh)
		var pos2=dtStr.indexOf(dtCh,pos1+1)
		var strDay=dtStr.substring(0,pos1)
		var strMonth=dtStr.substring(pos1+1,pos2)
		var strYear=dtStr.substring(pos2+1)
		strYr=strYear
		if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
		if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
		for (var i = 1; i <= 3; i++) {
			if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
		}
		month=parseInt(strMonth)
		day=parseInt(strDay)
		year=parseInt(strYr)
		if (pos1==-1 || pos2==-1 || dtStr.length != 10){
			alert("The date format should be : dd/mm/yyyy")
			return false
		}
		
		if (strDay.length<1 || day<1 || day>31){
			alert("Please enter a valid day")
			return false
		}
		if (strMonth.length<1 || month<1 || month>12 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
			alert("Please enter a valid month")
			return false
		}
		if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
			alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
			return false
		}
		if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
			alert("Please enter a valid date")
			return false
		}
	return true
	}

	function trimString (str) {
	  return str.replace(/^\s+/g, '').replace(/\s+$/g, '');
	}

	function validateDate(field){
		var str = trimString((field.value));
		if(str == "") return true;
		if (isDate(str)==false){
			field.focus()
			return false
		}
	    return true
	 }

	function isValidNumberKey(str) {
		if(event.keyCode == 46) return isDecimalValid(str);
		else return numbersonly(str);
	}
	
	function numbersonly(str){
		if ((event.keyCode<48||event.keyCode>57)) return false;
	}
	
	function isDecimalValid(str) {
		var pos=str.indexOf(".");
		return pos < 0;
	}
	
	function isValidDateKey(str) {
		// 47 = /
		if(event.keyCode == 47) return true;
		else return numbersonly(str);
	}

	function openEmail(recipient, subject, body) {
		var emailUrl = "mailto:";

		if( recipient == null ) {
			alert("No recipient supplied for email");
			return;
		}
				
		emailUrl = emailUrl.concat(recipient);
		
		emailUrl = emailUrl.concat("?");
		
		if( subject != null ) {
			emailUrl = emailUrl.concat("subject=");
			emailUrl = emailUrl.concat( subject );
			emailUrl = emailUrl.concat("&");
		}
		if( body != null ) {
			emailUrl = emailUrl.concat("body=");
			emailUrl = emailUrl.concat( body );
		}

		emailUrl = encodeURI( emailUrl );
	
		document.location = emailUrl;	
	}

	function sendEmail(from, recipient, subject, body) {
		var emailForm = document.EmailForm;

		emailForm.fromAddress.value = from;
		emailForm.recipientAddress.value= recipient;
		emailForm.subject.value = subject;
		emailForm.messageBody.value = body;
	
		emailForm.submit();	
	}
	
	
	function pleaseWait(imgButton) {
		imgButton.style.width = "108px";
		imgButton.style.height = "21px";
		imgButton.getElementsByTagName("img")[0].src = waitImage.src;
		document.body.style.cursor = "wait";
		var buttons = document.getElementsByTagName("button");
		for (var i = 0; i < buttons.length; i++) {
			buttons[i].disabled = true;
		}	
	}
	
	function pleaseWaitImg(imageButton) {
		var imgButton = document.getElementById(imageButton);
		imgButton.style.width = "108px";
		imgButton.style.height = "21px";
		imgButton.getElementsByTagName("img")[0].src = waitImage.src;
		document.body.style.cursor = "wait";
		var buttons = document.getElementsByTagName("button");
		for (var i = 0; i < buttons.length; i++) {
			buttons[i].disabled = true;
		}	
	}
	function samePagePleaseWaitImg(imageButton) {
		var imgButton = document.getElementById(imageButton);
		prevImage.src = imgButton.getElementsByTagName("img")[0].src;
		prevButtonHeight = imgButton.style.height;
		prevButtonWidth = imgButton.style.width;
		
		imgButton.style.height = "21px";
		imgButton.style.width = "108px";
		imgButton.getElementsByTagName("img")[0].src = waitImage.src;
		// alert('here');
		document.body.style.cursor = "wait";
		imgButton.disabled = true;
		button = imgButton;
	}
	
	function samePagePleaseWait(imgButton) {
		prevImage.src = imgButton.getElementsByTagName("img")[0].src;
		prevButtonHeight = imgButton.style.height;
		prevButtonWidth = imgButton.style.width;
		
		imgButton.style.height = "21px";
		imgButton.style.width = "108px";
		imgButton.getElementsByTagName("img")[0].src = waitImage.src;
		document.body.style.cursor = "wait";
		imgButton.disabled = true;
		button = imgButton;
	}
	function restoreButton() {
		button.getElementsByTagName("img")[0].src = prevImage.src;
		button.style.height = prevButtonHeight;
		button.style.width = prevButtonWidth;
		button.disabled = false;
		document.body.style.cursor = "default";
	}
	
	
	// Hover Product - Store Cursor Position, then set the div position when called upon
	var posX = 0; var posY = 0; var initposY 
	function StoreCursorPosition(e){
		if(document.all) { 
			posX = event.clientX; 
			posY = event.clientY; 
		} else { 
			posX = e.clientX; 
			posY = e.clientY;
		}
		initposY = posY;
	}	
	
	function SetDivPosition(div) {
		var extraX = 0; var extraY = 0;
		if(self.pageYOffset) {
			extraX = self.pageXOffset;
			extraY = self.pageYOffset;
			}
		else if(document.documentElement && document.documentElement.scrollTop) {
			extraX = document.documentElement.scrollLeft;
			extraY = document.documentElement.scrollTop;
			}
		else if(document.body) {
			extraX = document.body.scrollLeft;
			extraY = document.body.scrollTop;
			}
		posX += extraX; 
		posY += extraY;
		div.style.left = (posX+10) + "px";
		div.style.top = (posY+10) + "px";
	}
	
	function HideProductHover() {
		if (document.getElementById("overProd")) {	
			document.body.removeChild(document.getElementById("overProd"));
		}
		if (document.getElementById("hovprod")) {	
			document.getElementById("hovprod").style.display = "none";
			document.body.removeChild(document.getElementById("hovprod"));
		}
	}
	function ShowProductHover(divId) {
		if(divId.length < 1) { return; }
		var div = document.getElementById(divId);
		SetDivPosition(div);
		div.style.display = "block";
		if ((parseInt(initposY)+parseInt(div.clientHeight)) > (parseInt(document.documentElement.clientHeight)-parseInt(10))) {
			div.style.top = (parseInt(posY)-parseInt(div.clientHeight)-parseInt(20)) + "px";
		}
	}
	function HideAllocHover() {
		if (document.getElementById("overAlloc")) {	
			document.body.removeChild(document.getElementById("overAlloc"));
		}
		if (document.getElementById("hovAlloc")) {	
			document.getElementById("hovAlloc").style.display = "none";
			document.body.removeChild(document.getElementById("hovAlloc"));
		}
	}
	function ShowAllocHover(divId) {
		if(divId.length < 1) { return; }
		var div = document.getElementById(divId);
		div.style.display = "block";
		var cWidth = div.clientWidth;
		SetDivPosition(div);
		var leftPos = div.style.left.toString();
		var noPX = leftPos.replace("px","");
		div.style.left = parseInt(noPX) - parseInt(cWidth) + "px";
		if ((parseInt(initposY)+parseInt(div.clientHeight)) > (parseInt(document.documentElement.clientHeight)-parseInt(10))) {
			div.style.top = (parseInt(posY)-parseInt(div.clientHeight)-parseInt(20)) + "px";
		}
	}
	
	function is_child_of(parent, child) {
		if( child != null ) {			
			while( child.parentNode ) {
				if( (child = child.parentNode) == parent ) {
					return true;
				}
			}
		}
		return false;
	}
	
	function showMultiSelectBox(element) {
		var strSelect = new String(element.id);
		var strPos = strSelect.replace("Select", "Pos");
		var strOptions = strSelect.replace("Select", "Options");
		var strHeight = strSelect.replace("Select", "Height");
		
		document.getElementById(strPos).position = "absolute";
		if (document.getElementById("multiCompatable").value == "true") {
			if (document.getElementById(strHeight).value > 250) {
				document.getElementById(strPos).style.height = 250 + "px";
			}	else {
				document.getElementById(strPos).style.height = (parseInt(document.getElementById(strHeight).value) + parseInt(20)) +  "px";
			}		
		} else {
			document.getElementById(strPos).style.height = (parseInt(document.getElementById(strHeight).value) + parseInt(20)) +  "px";
			document.getElementById(strPos).style.display='inline';
		}	
		document.getElementById(strPos).style.visibility='visible';
		document.getElementById(strPos).style.zIndex=4;
		
		document.getElementById(strOptions).style.height = document.getElementById(strHeight).value +  "px";
		document.getElementById(strOptions).style.visibility='visible';
		document.getElementById(strOptions).style.zIndex=4;
	}
	
	function hideMultiSelectBox(element, event) {

		var hide = false;
		StoreCursorPosition(event);
		var obj = element;	
	    var topValue= 0,leftValue= 0;
	    while(obj){
			leftValue+= obj.offsetLeft;
			topValue+= obj.offsetTop;
			obj= obj.offsetParent;
	    }
		var extraX = 0; var extraY = 0;
		if(self.pageYOffset) {
			extraX = self.pageXOffset;
			extraY = self.pageYOffset;
			}
		else if(document.documentElement && document.documentElement.scrollTop) {
			extraX = document.documentElement.scrollLeft;
			extraY = document.documentElement.scrollTop;
			}
		else if(document.body) {
			extraX = document.body.scrollLeft;
			extraY = document.body.scrollTop;
			}

		var elStr = "";
		if (element.id.indexOf("Select", 1) > 0) {
			elStr = element.id.replace("Select", "Options");
			if (document.getElementById(elStr) != null) {
				element = document.getElementById(elStr);
			} else {
				return;
			}	
		}			
		if (element.id.indexOf("Pos", 1) > 0) {
			elStr = element.id.replace("Pos", "Options");
			if (document.getElementById(elStr) != null) {
				element = document.getElementById(elStr);
			} else {
				return;
			}	
		}			

		var divHeight = element.offsetHeight;		
		var divWidth = element.offsetWidth;		
		if (document.getElementById("multiCompatable").value == "true") {
			if(element.offsetHeight > 252) {;
				divWidth += 20;
				divHeight = 250;
			}	
		}	
		var browserName=navigator.appName; 
		var browserVer=parseInt(navigator.appVersion); 
		if (browserName=="Netscape" || (browserName=="Microsoft Internet Explorer" && browserVer >= 4))
		{
			divWidth -=1;	
		}
		
		if (topValue  > extraY + posY - 3) {
			hide = true;	
		}
		if (leftValue > extraX + posX - 3) {
			hide = true;	
		}
		if (elStr == "") {
			if (topValue + divHeight < extraY + posY + 3) {
				hide = true;	
			}
		}	
		if (leftValue + divWidth < extraX + posX + 3) {
			hide = true;	
		}

		if( hide) {
			hideBox(element);
		}
	}

	function hideBox(element) {

		var strOptions = element.id;
		var strSelect = strOptions.replace("Options", "Select");
		var strPos = strOptions.replace("Options", "Pos");
		var str = strOptions.replace("Options", "");
		document.getElementById(strSelect).innerHTML = "select";
        document.getElementById(strSelect).style.color="black";
		for(var i = 0; i < document.getElementsByName(str).length; i++) {
	    	if(document.getElementsByName(str).item(i).checked) {
	    		document.getElementById(strSelect).innerHTML = "selected";
		        document.getElementById(strSelect).style.color="red";
	    		break;
		    }	
		}
		document.getElementById(strOptions).style.height = "0px";
        document.getElementById(strOptions).style.visibility='hidden';
		document.getElementById(strPos).position = "static";
		document.getElementById(strPos).style.height = "0px";
        document.getElementById(strPos).style.visibility='hidden';
		document.getElementById(strPos).style.zIndex=-1;
		document.getElementById(strOptions).style.zIndex=-1;
		if (document.getElementById("multiCompatable").value == "false") {
			document.getElementById(strPos).style.display='none';
		}	
	}

	// Changes the cursor to an hourglass
	function cursor_wait() {
		document.body.style.cursor = 'wait';
		for (x=0;x<document.images.length;x++){
			document.images[x].style.cursor = 'wait';
		} 
		var aTags = document.getElementsByTagName("a");
		for (var i = 0; i < aTags.length; i++) {
			aTags[i].style.cursor = 'wait';
		}
	}

	function cursor_normal() {
		document.body.style.cursor = 'default';
		for (x=0;x<document.images.length;x++){
			document.images[x].style.cursor = 'pointer';
		} 
		var aTags = document.getElementsByTagName("a");
		for (var i = 0; i < aTags.length; i++) {
			aTags[i].style.cursor = 'pointer';
		}
	}