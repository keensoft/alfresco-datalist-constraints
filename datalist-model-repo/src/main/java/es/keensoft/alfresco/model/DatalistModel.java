package es.keensoft.alfresco.model;

import org.alfresco.service.namespace.QName;

public class DatalistModel {
	
	public static final String DATALIST_MODEL_URI = "http://www.alfresco.com/model/datalistmodel/1.0";
	public static final QName DATALIST_MODEL_CODE_PROPERTY = QName.createQName(DATALIST_MODEL_URI, "code");
	public static final QName DATALIST_MODEL_VALUE_PROPERTY = QName.createQName(DATALIST_MODEL_URI, "value");
	public static final QName DATALIST_MODEL_ITEM_TYPE = QName.createQName(DATALIST_MODEL_URI, "optionList");
	
}
