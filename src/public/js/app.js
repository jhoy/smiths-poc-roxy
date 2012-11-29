/**
 * Converts passed XML string into a DOM element.
 * @param xmlStr {String}
 */
function getXmlDOMFromString(xmlStr) {
	if (window.ActiveXObject && window.GetObject) {
		// for Internet Explorer
		var dom = new ActiveXObject('Microsoft.XMLDOM');
		dom.loadXML(xmlStr);
		return dom;
	}
	if (window.DOMParser) { // for other browsers
		return new DOMParser().parseFromString(xmlStr, 'text/xml');
	}
	throw new Error('No XML parser available');
}

//var xmlString = document.getElementById("xmlString").innerHTML;
//var xmlData = getXmlDOMFromString(xmlString);

/**
 * Returns string representation of passed XML object
 */
function getXmlAsString(xmlDom) {
	return (typeof XMLSerializer !== "undefined") ? (new window.XMLSerializer())
			.serializeToString(xmlDom)
			: xmlDom.xml;
}

/**
 * Retrieves non-empty text nodes which are children of passed XML node. 
 * Ignores child nodes and comments. Strings which contain only blank spaces
 * or only newline characters are ignored as well.
 * @param  node {Object} XML DOM object
 * @return jQuery collection of text nodes
 */
function getTextNodes(node) {
	return $(node)
			.contents()
			.filter(function() {
				return (
				// text node, or CDATA node
					((this.nodeName == "#text" && this.nodeType == "3") || this.nodeType == "4") &&
					// and not empty
					($.trim(this.nodeValue.replace("\n", "")) !== ""));
				});
}

/**
 * Retrieves (text) node value
 * @param node {Object}
 * @return {String}
 */
function getNodeValue(node) {
	var textNodes = getTextNodes(node);
	var textValue = (node && isNodeComment(node)) ?
	// isNodeComment is defined above
	node.nodeValue
			: (textNodes[0]) ? $.trim(textNodes[0].textContent) : "";
	return textValue;
}

function setNodeValue(node, value) {
	var textNodes = getTextNodes(node);
	if (textNodes.get(0)) {
		textNodes.get(0).nodeValue = value;
	} else {
		node["textContent"] = value;
	}
}

function loadXML() {
	$.ajax({
		type     : "GET",
		url      : "/path/to/data.xml",
		dataType : "xml",
		success  : function(xmlData){
		var totalNodes = $('*',xmlData).length; // count XML nodes
		alert("This XML file has " + totalNodes);
		},
		error    : function(){
		     alert("Could not retrieve XML file.");
		}
		 });
}

function uploadBox() {
	$.ajax( {
		url : '/upload.xqy',
		data : {
			action : 'upload'
		},
		dataType : 'html',
		success : function(data) {
			$(data).dialog( {
				title : "Upload Box",
				width : 625,
				minWidth : 625,
				height : 230,
				minHeight : 230,
				show : {
					effect : "fold",
					duration : 500
				},
				hide : 'clip',
				close : function(event, ui) {
					$(this).remove();
				}
			});
		}
	});
};