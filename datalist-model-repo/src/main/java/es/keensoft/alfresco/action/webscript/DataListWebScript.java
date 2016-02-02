package es.keensoft.alfresco.action.webscript;

import java.io.IOException;
import java.util.List;

import org.alfresco.model.ContentModel;
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

public class DataListWebScript extends AbstractWebScript {
	
	private static final String JSON_CODE = "code";
	private static final String JSON_VALUE = "value";
	
	private static final String DATALIST_CONTAINER_ID = "dataLists";
	private static final String DATALIST_PRESET = "datalist-site-dashboard";
	
	private NodeService nodeService;
	private SiteService siteService;
	private TransactionService transactionService;
	private TaggingService taggingService;

	@Override
	public void execute(WebScriptRequest request, WebScriptResponse response) throws IOException {
		
		String targetedDataListName = request.getExtensionPath(); 
		
    	JSONArray objProcess = new JSONArray();
		
    	try {
    		
    		List<SiteInfo> sites = siteService.listSites(null, DATALIST_PRESET);
    		
    		for (SiteInfo site : sites) {
    		
				NodeRef dataListContainer = SiteServiceImpl.getSiteContainer(site.getShortName(), DATALIST_CONTAINER_ID, true, siteService, transactionService, taggingService);
				List<ChildAssociationRef> dataListsNodes = nodeService.getChildAssocs(dataListContainer);
				
				for (ChildAssociationRef dataList : dataListsNodes) {
					
					if (dataList.getTypeQName().isMatch(ContentModel.ASSOC_CONTAINS)) {
						
						if (nodeService.getProperty(dataList.getChildRef(), ContentModel.PROP_TITLE).toString().equals(targetedDataListName)) {
							
						    List<ChildAssociationRef> itemsNodes = nodeService.getChildAssocs(dataList.getChildRef(), ContentModel.ASSOC_CONTAINS, RegexQNamePattern.MATCH_ALL);
						    
						    for (ChildAssociationRef item : itemsNodes) {
						    	
						    	if (nodeService.getType(item.getChildRef()).isMatch(DatalistModel.DATALIST_MODEL_ITEM_TYPE)) {
						            JSONObject obj = new JSONObject();
						    		obj.put(JSON_CODE, nodeService.getProperty(item.getChildRef(), DatalistModel.DATALIST_MODEL_CODE_PROPERTY).toString());
						    		obj.put(JSON_VALUE, nodeService.getProperty(item.getChildRef(), DatalistModel.DATALIST_MODEL_VALUE_PROPERTY).toString());
					    			objProcess.put(obj);
						    	} else {
						    		// Ignore other datalist types
						    		continue;
						    	}
			                }
							
						}
						
					}
				}
				
			}
			
    	} catch (Exception e) {
    		throw new IOException(e);
    	}
    	
    	String jsonString = objProcess.toString();
    	response.setContentEncoding("UTF-8");
    	response.getWriter().write(jsonString);

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

}
