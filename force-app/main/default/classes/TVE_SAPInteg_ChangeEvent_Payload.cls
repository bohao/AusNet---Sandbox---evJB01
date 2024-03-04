/*
    @author   harshad.kumbhar@ausnetservices.com.au
    @created  24 Feb 2020
    @Description  Payload response class
    -----------------------------------------------------------------------------------------
    Change log
    -----------------------------------------------------------------------------------------
    Date                  Name                           Description
    -----------------------------------------------------------------------------------------
    NA                    NA                              NA
    -----------------------------------------------------------------------------------------
*/

public with sharing class TVE_SAPInteg_ChangeEvent_Payload {

    public Request request;
	public class Request {
		public String key ;
		public String msgId;
		public String sourceSystem;
		public String targetSystem;
		public String objectName;
		public String dateAndTime;
        public Payload payload;
	}
	public class Payload {
		public String objectName;
		public String objectId;
		public String eventType;
		public String cmId;
		public String constNotiId;
		public String constWOId;
        public String invoiceId;
        public String docId;
        public String cmNum;
        public String sapObject;
		public string fileName;
		public string salesOrderId;
		public string designWorkorder;
		public string cudesignNum;
		public string sfrefno;
	}	
    public String getJSON()
	{
		return JSON.serialize(this);
	}
}