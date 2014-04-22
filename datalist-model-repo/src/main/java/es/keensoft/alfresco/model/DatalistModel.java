package es.keensoft.alfresco.model;

import org.alfresco.service.namespace.QName;

public class DatalistModel {
	
	public static final String DATALIST_MODEL_URI = "http://www.alfresco.com/model/datalistmodel/1.0";
	public static final QName DATALIST_MODEL_CODE_PROPERTY = QName.createQName(DATALIST_MODEL_URI, "code");
	public static final QName DATALIST_MODEL_VALUE_PROPERTY = QName.createQName(DATALIST_MODEL_URI, "value");
	public static final QName DATALIST_MODEL_ITEM_TYPE = QName.createQName(DATALIST_MODEL_URI, "optionList");
	
	public static final String CUSTOM_MODEL_URI = "http://www.alfresco.com/model/keensoft/1.0";
	public static final QName CUSTOM_MODEL_SAMPLE_ASPECT = QName.createQName(CUSTOM_MODEL_URI, "sample");
	public static final QName CUSTOM_MODEL_OPTION_PROPERTY = QName.createQName(CUSTOM_MODEL_URI, "option");
	public static final QName CUSTOM_MODEL_ANOTHER_OPTION_PROPERTY = QName.createQName(CUSTOM_MODEL_URI, "anotherOption");

}
