var siteService = widgetUtils.findObject(model.jsonModel, "id", "SITE_SERVICE");
if (siteService && siteService.config)
{
   siteService.config.additionalSitePresets = [{ label: "Dictionary", value: "datalist-site-dashboard" } ];
}