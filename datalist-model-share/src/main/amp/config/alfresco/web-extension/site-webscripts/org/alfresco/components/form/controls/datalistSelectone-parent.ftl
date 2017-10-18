<#include "/org/alfresco/components/form/controls/common/utils.inc.ftl" />

<#--
This control will hide the dependent controls injected via the
control parameters in the form config by hiding the div {field.name}-control
-->
<#assign hideProperties=field.control.params.hideProperties>


<#assign hideOnValue=field.control.params.hideOnValue>

<#if field.control.params.optionSeparator??>
   <#assign optionSeparator=field.control.params.optionSeparator>
<#else>
   <#assign optionSeparator=",">
</#if>
<#if field.control.params.labelSeparator??>
   <#assign labelSeparator=field.control.params.labelSeparator>
<#else>
   <#assign labelSeparator="|">
</#if>

<#assign fieldValue=field.value>

<#if fieldValue?string == "" && field.control.params.defaultValueContextProperty??>
   <#if context.properties[field.control.params.defaultValueContextProperty]??>
      <#assign fieldValue = context.properties[field.control.params.defaultValueContextProperty]>
   <#elseif args[field.control.params.defaultValueContextProperty]??>
      <#assign fieldValue = args[field.control.params.defaultValueContextProperty]>
   </#if>
</#if>

<#if fieldValue?string == "${hideOnValue}">
	<#assign hide=true>
<#else>
	<#assign hide=false>
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
            <#assign valueToShow=fieldValue>
            <#if field.control.params.options?? && field.control.params.options != "">
               <#list field.control.params.options?split(optionSeparator) as nameValue>
                  <#if nameValue?index_of(labelSeparator) == -1>
                     <#if nameValue == fieldValue?string || (fieldValue?is_number && fieldValue?c == nameValue)>
                        <#assign valueToShow=nameValue>
                        <#break>
                     </#if>
                  <#else>
                     <#assign choice=nameValue?split(labelSeparator)>
                     <#if choice[0] == fieldValue?string || (fieldValue?is_number && fieldValue?c == choice[0])>
                        <#assign valueToShow=msgValue(choice[1])>
                        <#break>
                     </#if>
                  </#if>
               </#list>
            </#if>
         </#if>
         <span class="viewmode-value">${valueToShow?html}</span>
      </div>
   <#else>
      	 <label for="${fieldHtmlId}">${field.label?html}:<#if field.mandatory><span class="mandatory-indicator">${msg("form.required.fields.marker")}</span></#if></label>
         <select id="${fieldHtmlId}" name="${field.name}" tabindex="0" onchange="checkValue()"
               <#if field.description??>title="${field.description}"</#if>
               <#if field.control.params.size??>size="${field.control.params.size}"</#if> 
               <#if field.control.params.styleClass??>class="${field.control.params.styleClass}"</#if>
               <#if field.control.params.style??>style="${field.control.params.style}"</#if>
               <#if field.disabled  && !(field.control.params.forceEditable?? && field.control.params.forceEditable == "true")>disabled="true"</#if>>
         </select>
         <input id="${fieldHtmlId}-entry-tohide" type="hidden" name="-" value="${hideProperties}" /> 
   </#if>
</div>

<script type="text/javascript">//<![CDATA[

		YAHOO.util.Event.onContentReady("${fieldHtmlId}", function ()
		{
			
		   	  
  <#if field.control.params.search?? && field.control.params.search == "true">
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?search=true&"+ (new Date().getTime());  
  <#elseif page?? && page.url.templateArgs.site??>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?siteId=${page.url.templateArgs.site!""}&"+ (new Date().getTime());
  <#elseif args?? && args.destination??>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?nodeRef=${args.destination!""}&"+ (new Date().getTime());
  <#elseif page?? && page.url.args.nodeRef??>
      var linkTemplate="/keensoft/datalist/${field.control.params.itemType}?nodeRef=${page.url.args.nodeRef!""}&"+ (new Date().getTime());
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
		                 
					          for (i = 0; i < obj.length; i++) {
		                    	var newOption = document.createElement('option');
		                    	newOption.value = obj[i].code;
		                    	newOption.text = obj[i].value;
		                   	    YAHOO.util.Dom.get("${fieldHtmlId}").options.add(newOption);
				        	  }
				        	  
							  // Current value
							  var sp = document.getElementById("${fieldHtmlId}");
							  sp.value = "${field.value}";
					   	  	
					   	  	  <#if hide>
					   	  			ENIModel.Util.HideDependentControls("${fieldHtmlId}", "${args.htmlid}");
							  </#if>		   	  
				        	  
		                 }
		             }
		          }
			   });
		
		}, this);


   	  function checkValue() {
   	  		var value = document.getElementById("${fieldHtmlId}").value
   	  		if(value == "${hideOnValue}")
   	  		{
   	  			ENIModel.Util.HideDependentControls("${fieldHtmlId}", "${args.htmlid}");
   	  		}
   	  		else
   	  		{
   	  			ENIModel.Util.DisplayDependentControls("${fieldHtmlId}", "${args.htmlid}");
   	  		}
   	  }   	  

//]]></script>