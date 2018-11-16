// Alfresco Share 5.1-
var datalistSiteOption = widgetUtils.findObject(model.sitePresets, "id", "datalist-site-dashboard");
if (datalistSiteOption == null) {
    model.sitePresets.push({
        id: "datalist-site-dashboard",
        name: msg.get("title.datalistSite")
    });
}