<#include "/org/alfresco/components/form/controls/common/utils.inc.ftl" />


<#assign optionSeparator=",">
<#assign fieldValue=field.value>

<#if fieldValue?string == "" && field.control.params.defaultValueContextProperty??>
   <#if context.properties[field.control.params.defaultValueContextProperty]??>
      <#assign fieldValue = context.properties[field.control.params.defaultValueContextProperty]>
   <#elseif args[field.control.params.defaultValueContextProperty]??>
      <#assign fieldValue = args[field.control.params.defaultValueContextProperty]>
   </#if>
</#if>

<#if fieldValue?string != "">
   <#assign values=fieldValue?split(",")>
<#else>
   <#assign values=[]>
</#if>

<div class="form-field">
   <#if form.mode == "view">
      <div class="viewmode-field">
         <#if field.mandatory && !(fieldValue?is_number) && fieldValue?string == "">
            <span class="incomplete-warning"><img src="${url.context}/res/components/form/images/warning-16.png" title="${msg("form.field.incomplete")}" /><span>
         </#if>
         <span class="viewmode-label">${field.label?html}:</span>
         <#if fieldValue?string == "">
            <#assign valueToShow=msg("form.control.novalue")>
         <#else>
            <#if field.control.params.options?? && field.control.params.options != "" &&
                 field.control.params.options?index_of(labelSeparator) != -1>
                 <#assign valueToShow="">
                 <#assign firstLabel=true>
                 <#list field.control.params.options?split(optionSeparator) as nameValue>
                    <#assign choice=nameValue?split(labelSeparator)>
                    <#if isSelected(choice[0])>
                       <#if !firstLabel>
                          <#assign valueToShow=valueToShow+",">
                       <#else>
                          <#assign firstLabel=false>
                       </#if>
                       <#assign valueToShow=valueToShow+choice[1]>
                    </#if>
                 </#list>
            <#else>
               <#assign valueToShow=fieldValue>
            </#if>
         </#if>
         <span class="viewmode-value">${valueToShow?html}</span>
      </div>
   <#else>
      <label for="${fieldHtmlId}-entry">${field.label?html}:<#if field.mandatory><span class="mandatory-indicator">${msg("form.required.fields.marker")}</span></#if></label>
      <input class="hidden-input-${fieldHtmlId}" id="${fieldHtmlId}" type="hidden" name="${field.name}" value="${fieldValue?string}" />
		<div class="field-data-${fieldHtmlId}" id="field-data-${fieldHtmlId}"></div>

	<script language="Javascript" type="text/javascript">//<![CDATA[

	    (function() {


		var hiddenInputId = "${fieldHtmlId}";
		var fieldDataDivId = "field-data-${fieldHtmlId}";
		var firstRun = true;


		function WindowLoad() {
			refreshVisible(hiddenInputId, fieldDataDivId);
		}

		function relocatePlus() {

		    var oldPlus = document.querySelector('#plus-${fieldHtmlId}');
		    if (oldPlus) {
                oldPlus.parentNode.removeChild(oldPlus);
            }

            var childDivs = document.querySelector('#field-data-${fieldHtmlId}').getElementsByTagName('div');
            var lastDiv = childDivs[childDivs.length-1];

            var newPlus = document.createElement('img');
            newPlus.setAttribute('class', 'icon plus-icon');
            newPlus.setAttribute('id', 'plus-${fieldHtmlId}');
            newPlus.setAttribute('src', '${url.context}/res/sp/components/form/images/plus-icon.png');
            newPlus.setAttribute('alt', 'Add another');
            newPlus.setAttribute('style', 'vertical-align: middle;margin-left:5px;');

            lastDiv.appendChild(newPlus);

            if (newPlus.addEventListener) {
                newPlus.addEventListener("click", function(){addField('field-data-${fieldHtmlId}', '${fieldHtmlId}');}, false);
            } else {
                newPlus.attachEvent('onclick', function(){addField('field-data-${fieldHtmlId}', '${fieldHtmlId}');} );
            }

		};

		function getCount(divId) {
			var el = document.body.querySelector('#' + divId);
			var matches = el.querySelectorAll('div');
			return matches.length;
		};

		function addField(divName, hiddenInputId) {
			var count = getCount(divName);
			addInput(divName, count, hiddenInputId);

		};


		function deleteField(hiddenInputId, divName, fieldDataDivId) {
			var count = getCount(fieldDataDivId);
			var el = document.getElementById(divName);

			el.parentNode.removeChild(el);

			// Get removed index
			var index = divName.split('___');
			index = index[1];

			refreshHidden(index, count, hiddenInputId);
			refreshVisible(hiddenInputId, fieldDataDivId);

			relocatePlus();

		};
		
		function addInput(divName, index, hiddenInputId, value) {
			var newdiv = document.createElement('div');
			newdiv.setAttribute('id', 'div' + hiddenInputId + '___' + index);
			newdiv.innerHTML = "<select "
					+ "id='txt"
					+ hiddenInputId
					+ index
					+ "'"
					<#if field.control.params.styleClass??>+ " class='${field.control.params.styleClass}'"</#if>
					<#if field.control.params.style??>+ " style='${field.control.params.style}'"<#else>+ " style='margin-bottom: 4px;'"</#if>
					<#if field.control.params.maxLength??>+ " maxlength='${field.control.params.maxLength}'"<#else>+ " maxlength='1024'"</#if>
                    <#if field.control.params.size??>+ " size='${field.control.params.size}'"</#if>
					+ "></select><img class='icon' style='vertical-align: middle;margin-left:5px;' id='minus-"+index+"-${fieldHtmlId}' src='${url.context}/res/sp/components/form/images/minus-icon.png' alt='Delete this input' "
					+ " />";
			document.getElementById(divName).appendChild(newdiv);
			fillOptions${field.id}("txt" + hiddenInputId + index, value);

            // find text field, attach oninput event listener
            var input = document.querySelector('#txt' + hiddenInputId + index);

		    if (input.addEventListener) {
                input.addEventListener("input", function(){refresh(hiddenInputId, divName);}, false);
            } else {
                input.attachEvent('oninput', function(){refresh(hiddenInputId, divName);} );
            };

            if (input.addEventListener) {
                input.addEventListener("keydown", function(e){if (e.keyCode == 188){e.preventDefault();}}, false);
            } else {
                input.attachEvent('onkeydown', function(e){if (e.keyCode == 188){e.preventDefault();}} );
            };



            // find minus button, attach onclick event listener
			var minus = document.querySelector('#minus-'+index+'-${fieldHtmlId}');

			if (minus.addEventListener) {
                minus.addEventListener("click", function(){deleteField(hiddenInputId, "div" + hiddenInputId + '___' + index, divName);}, false);
            } else {
                minus.attachEvent('onclick', function(){deleteField(hiddenInputId, "div" + hiddenInputId + '___' + index, divName);} );
            };

            relocatePlus();

			if (!firstRun) {
				input.focus();
			}
		};


		function refresh(hiddenInputId, fieldDataDivId) {
			var count = getCount(fieldDataDivId);
			refreshHidden(-1, count, hiddenInputId);
		};

		function refreshHidden(excludedIndex, count, hiddenInputId) {
			var cat = "";

			var nonEmptyCounter = 0;
			for (var i = 0; i < count; i++) {
				if (i != excludedIndex) {
					var fieldval = document.getElementById("txt"
							+ hiddenInputId + i).value;
					if (fieldval != "") {
						if (nonEmptyCounter > 0) {
							cat = cat + ",";
						}
						cat = cat + fieldval;
						nonEmptyCounter++;
					}
				}
			}

			document.getElementById(hiddenInputId).value = cat;
		};

		function refreshVisible(hiddenInputId, fieldDataDivId) {
		
			var cat = document.getElementById(hiddenInputId).value;

			if (cat != "") {
			
				blocks = cat.split(",");

				var el = document.body.querySelector('#' + fieldDataDivId);
				var matches = el.querySelectorAll('div');
				for (var j = 0; j < matches.length; j++) {
					matches[j].parentNode.removeChild(matches[j]);
				}

				for (var i = 0; i < blocks.length; i++) {
					addInput(fieldDataDivId, i, hiddenInputId, blocks[i]);
				}
				
			} else {
				addInput(fieldDataDivId, 0, hiddenInputId);
			}

			firstRun = false;
		};

        var reps = 0;

        var checkExist = setInterval(function() {
            if (document.getElementById(hiddenInputId)) {
                clearInterval(checkExist);
                WindowLoad();
            }
            if (reps>=40){
                // give up after a second
                clearInterval(checkExist);
            }
            reps++;
        }, 25);

	} )();//]]></script>


         <@formLib.renderFieldHelp field=field />
         <#if field.control.params.mode?? && isValidMode(field.control.params.mode?upper_case)>
         <select id="${fieldHtmlId}" name="${field.name}" tabindex="0"
               <#if field.description??>title="${field.description}"</#if>
               <#if field.control.params.size??>size="${field.control.params.size}"</#if> 
               <#if field.control.params.styleClass??>class="${field.control.params.styleClass}"</#if>
               <#if field.control.params.style??>style="${field.control.params.style}"</#if>
               <#if field.disabled  && !(field.control.params.forceEditable?? && field.control.params.forceEditable == "true")>disabled="true"</#if>>
         </select>
         </#if>
   </#if>
</div>

<#function isSelected optionValue>
   <#list values as value>
      <#if optionValue == value?string || (value?is_number && value?c == optionValue)>
         <#return true>
      </#if>
   </#list>
   <#return false>
</#function>

<#function isValidMode modeValue>
   <#return modeValue == "OR" || modeValue == "AND">
</#function>

<script type="text/javascript">//<![CDATA[

YAHOO.util.Event.onContentReady("${fieldHtmlId}", function ()
{

      var selects = document.getElementsByTagName('select');
      for (var i = 0; i < selects.length; i++) {
          if (selects[i].id.indexOf("${fieldHtmlId}") > 0) {
              fillOptions${field.id}(selects[i].id);
          }
      }


}, this);

function fillOptions${field.id}(selectId, value) {

  <#if field.control.params.search?? && field.control.params.search == "true">
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?search=true&"+ (new Date().getTime());  
  <#elseif page?? && page.url.templateArgs.site??>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?siteId=${page.url.templateArgs.site!""}&"+ (new Date().getTime());
  <#elseif form?? && form.arguments.itemId?? && form.arguments.itemId?contains("//")>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?nodeRef=${form.arguments.itemId!""}&"+ (new Date().getTime());
  <#elseif page?? && page.url.args.nodeRef??>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?nodeRef=${page.url.args.nodeRef!""}&"+ (new Date().getTime());
  <#elseif args?? && args.destination??>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?nodeRef=${args.destination!""}&"+ (new Date().getTime());
  <#else>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?"+ (new Date().getTime());
  </#if>

   	  Alfresco.util.Ajax.jsonGet({   	  
          url: encodeURI(Alfresco.constants.PROXY_URI + linkTemplate),
          successCallback:
          {
             fn: function loadWebscript_successCallback(response, config)
             {
                 var obj = eval('(' + response.serverResponse.responseText + ')');
                 if (obj)
                 {
                 
                      var select = document.getElementById(selectId);
                      
			          for (var j = 0; j < obj.length; j++) {
	                    	var newOption = document.createElement('option');
	                    	newOption.value = obj[j].code;
	                    	newOption.text = obj[j].value;
	                   	select.options.add(newOption);
			        	  }
			        	  
	                	  // Current value
	                	  if (value) {
	                	      select.value = value;
	                	  }
                 }
             }
          }
	   });

}

//]]></script>