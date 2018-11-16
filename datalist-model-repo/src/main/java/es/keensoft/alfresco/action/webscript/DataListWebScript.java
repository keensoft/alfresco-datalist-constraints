package es.keensoft.alfresco.action.webscript;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.alfresco.model.ContentModel;
import org.alfresco.repo.security.authentication.AuthenticationUtil;
import org.alfresco.repo.site.SiteServiceImpl;
import org.alfresco.service.cmr.repository.ChildAssociationRef;
import org.alfresco.service.cmr.repository.NodeRef;
import org.alfresco.service.cmr.repository.NodeService;
import org.alfresco.service.cmr.site.SiteInfo;
import org.alfresco.service.cmr.site.SiteService;
import org.alfresco.service.cmr.tagging.TaggingService;
import org.alfresco.service.namespace.RegexQNamePattern;
import org.alfresco.service.transaction.TransactionService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.extensions.webscripts.AbstractWebScript;
import org.springframework.extensions.webscripts.WebScriptRequest;
import org.springframework.extensions.webscripts.WebScriptResponse;

import es.keensoft.alfresco.model.DatalistModel;
import es.keensoft.alfresco.model.DatalistModel.DataListStatus;

public class DataListWebScript extends AbstractWebScript {

    private static final String REPLACE_DESK_MARK = "[REPLACE]";
    private static final String ADD_DESC_MARK = "[ADD]";

    private static final String JSON_CODE = "code";
    private static final String JSON_VALUE = "value";

    private static final String DATALIST_CONTAINER_ID = "dataLists";
    private static final String DATALIST_PRESET = "datalist-site-dashboard";

    private NodeService nodeService;
    private SiteService siteService;
    private TransactionService transactionService;
    private TaggingService taggingService;
    private Boolean dataListOrdered;

    @Override
    public void execute(WebScriptRequest request, WebScriptResponse response) throws IOException {

        String targetedDataListName = request.getExtensionPath();

        // 1. search = sites + dictionary
        // 2. nodeRef = site (if belongs to one)
        // 3. siteId = if exists(site) ? site : dictionary
        // 4. ...... = dictionary

        List<SiteInfo> sites = new ArrayList<SiteInfo>();
        JSONArray objProcess = new JSONArray();

        String search = request.getParameter("search");
        String siteId = request.getParameter("siteId");
        String nodeRef = request.getParameter("nodeRef");
        
        // Everyone should be able to read values from datalists
        AuthenticationUtil.pushAuthentication();
        try {
            AuthenticationUtil.setRunAsUserSystem();
            
            if (search != null && search.toLowerCase().equals("true")) {
    
                sites.addAll(getSitesDataList(targetedDataListName));
    
            } else {
    
                if (nodeRef != null) {
                    SiteInfo siteInfo = siteService.getSite(new NodeRef(nodeRef));
                    if (siteInfo != null) {
                        siteId = siteInfo.getShortName();
                    }
                }
                DataListStatus siteStatus = DataListStatus.NONE;
                if (siteId != null) {
                    siteStatus = existsDatalist(siteId, targetedDataListName);
                    switch(siteStatus) {
                    case NONE: 
                        sites = siteService.listSites(null, DATALIST_PRESET);
                        break;
                    case ADD: 
                        sites = siteService.listSites(null, DATALIST_PRESET);
                        sites.add(siteService.getSite(siteId));
                        break;
                    case REPLACE:
                        sites.add(siteService.getSite(siteId));
                        break;
                    }
                } else {
                    sites = siteService.listSites(null, DATALIST_PRESET);
                }
    
            }
    
            try {
    
                Map<String, String> values = new HashMap<String, String>();
    
                for (SiteInfo site : sites) {
    
                    NodeRef dataListContainer = SiteServiceImpl.getSiteContainer(site.getShortName(), DATALIST_CONTAINER_ID, true, siteService, transactionService, taggingService);
                    List<ChildAssociationRef> dataListsNodes = nodeService.getChildAssocs(dataListContainer);
    
                    for (ChildAssociationRef dataList : dataListsNodes) {
    
                        if (dataList.getTypeQName().isMatch(ContentModel.ASSOC_CONTAINS)) {
    
                            if (nodeService.getProperty(dataList.getChildRef(), ContentModel.PROP_TITLE).toString().equals(targetedDataListName)) {
    
                                List<ChildAssociationRef> itemsNodes = nodeService.getChildAssocs(dataList.getChildRef(), ContentModel.ASSOC_CONTAINS, RegexQNamePattern.MATCH_ALL);
    
                                for (ChildAssociationRef item : itemsNodes) {
    
                                    if (nodeService.getType(item.getChildRef()).isMatch(DatalistModel.DATALIST_MODEL_ITEM_TYPE)) {
                                        // Previous behaviour, include values as they were introduced in Alfresco
                                        if (!dataListOrdered) {
                                            JSONObject obj = new JSONObject();
                                            obj.put(JSON_CODE, nodeService.getProperty(item.getChildRef(), DatalistModel.DATALIST_MODEL_CODE_PROPERTY).toString());
                                            obj.put(JSON_VALUE, nodeService.getProperty(item.getChildRef(), DatalistModel.DATALIST_MODEL_VALUE_PROPERTY).toString());
                                            objProcess.put(obj);
                                        } else {
                                            values.put(nodeService.getProperty(item.getChildRef(), DatalistModel.DATALIST_MODEL_CODE_PROPERTY).toString(),
                                                    nodeService.getProperty(item.getChildRef(), DatalistModel.DATALIST_MODEL_VALUE_PROPERTY).toString());
                                        }
                                    } else {
                                        // Ignore other datalist types
                                        continue;
                                    }
                                }
    
                            }
    
                        }
                    }
    
                }
    
                // Ordered
                if (dataListOrdered) {
                    Map<String, String> sortedValues = sortByComparator(values);
                    for (Map.Entry<String, String> entry : sortedValues.entrySet()) {
                        JSONObject obj = new JSONObject();
                        obj.put(JSON_CODE, entry.getKey());
                        obj.put(JSON_VALUE, entry.getValue());
                        objProcess.put(obj);
                    }
                }
    
            } catch (Exception e) {
                throw new IOException(e);
            }
        
        } finally {
            AuthenticationUtil.popAuthentication();
        }

        String jsonString = objProcess.toString();
        response.setContentEncoding("UTF-8");
        response.getWriter().write(jsonString);

    }

    private static Map<String, String> sortByComparator(Map<String, String> unsortMap) {

        // Convert Map to List
        List<Map.Entry<String, String>> list = 
                new LinkedList<Map.Entry<String, String>>(unsortMap.entrySet());

        // Sort list with comparator, to compare the Map values
        Collections.sort(list, new Comparator<Map.Entry<String, String>>() {
            public int compare(Map.Entry<String, String> o1,
                    Map.Entry<String, String> o2) {
                return (o1.getValue()).compareTo(o2.getValue());
            }
        });

        // Convert sorted map back to a Map
        Map<String, String> sortedMap = new LinkedHashMap<String, String>();
        for (Iterator<Map.Entry<String, String>> it = list.iterator(); it.hasNext();) {
            Map.Entry<String, String> entry = it.next();
            sortedMap.put(entry.getKey(), entry.getValue());
        }
        return sortedMap;
    }

    private DataListStatus existsDatalist(String siteId, String targetedDataListName) {

        NodeRef dataListContainer = SiteServiceImpl.getSiteContainer(siteId, DATALIST_CONTAINER_ID, true, siteService, transactionService, taggingService);
        List<ChildAssociationRef> dataListsNodes = nodeService.getChildAssocs(dataListContainer);
        for (ChildAssociationRef dataList : dataListsNodes) {
            if (dataList.getTypeQName().isMatch(ContentModel.ASSOC_CONTAINS)) {
                if (nodeService.getProperty(dataList.getChildRef(), ContentModel.PROP_TITLE).toString().equals(targetedDataListName)) {
                    Object description = nodeService.getProperty(dataList.getChildRef(), ContentModel.PROP_DESCRIPTION);
                    if (description != null) {
                        if (description.toString().indexOf(ADD_DESC_MARK) > 0) {
                            return DataListStatus.ADD;
                        } else if (description.toString().indexOf(REPLACE_DESK_MARK) > 0) {
                            return DataListStatus.REPLACE;
                        } else {
                            return DataListStatus.REPLACE;
                        }
                    } else {
                        return DataListStatus.REPLACE;
                    }
                }
            }
        }
        return DataListStatus.NONE;

    }

    // TODO Improve performance, as this can be slow when having hundreds of sites
    private List<SiteInfo> getSitesDataList(String targetedDataListName) {

        List<SiteInfo> sites = new ArrayList<SiteInfo>();

        List<SiteInfo> allSites = siteService.listSites(null, null);
        for (SiteInfo site : allSites) {
            NodeRef dataListContainer = SiteServiceImpl.getSiteContainer(site.getShortName(), DATALIST_CONTAINER_ID, true, siteService, transactionService, taggingService);
            List<ChildAssociationRef> dataListsNodes = nodeService.getChildAssocs(dataListContainer);
            for (ChildAssociationRef dataList : dataListsNodes) {
                if (dataList.getTypeQName().isMatch(ContentModel.ASSOC_CONTAINS)) {
                    if (nodeService.getProperty(dataList.getChildRef(), ContentModel.PROP_TITLE).toString().equals(targetedDataListName)) {
                        sites.add(site);
                    }
                }
            }
        }

        return sites;

    }

    public void setNodeService(NodeService nodeService) {
        this.nodeService = nodeService;
    }

    public void setSiteService(SiteService siteService) {
        this.siteService = siteService;
    }

    public void setTransactionService(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    public void setTaggingService(TaggingService taggingService) {
        this.taggingService = taggingService;
    }

    public void setDataListOrdered(Boolean dataListOrdered) {
        this.dataListOrdered = dataListOrdered;
    }

}
