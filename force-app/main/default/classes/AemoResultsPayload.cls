/*
@author  : rohit.middha@ausnetservices.com.au
@created : 20 Sep 2019
@Description : Payload Class for parsing JSON Request Body
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public class AemoResultsPayload{
	public cls_results[] results;
	public class cls_results {
		public String name;	//string
		public cls_acConnections[] acConnections;
		public cls_exceptions[] exceptions;
		public cls_errors[] errors;
	}
	public class cls_acConnections
	{
		public String connectionId;    // number
		public String nspConnectionId; // string
		public String status;          // string
		public cls_devices[] devices;
	}

	public class cls_devices
	{
		public String deviceId;    // number
		public String nspDeviceId; // string
		public String status;      // string
	}

	public class cls_exceptions {
		public String exceptionId;	// number
		public String code;	//number
		public String name;	//string
		public String details;	//string
		public List<String> affectedAttributes;
		public String status;	//string
		public String deviceId;	// number
		public String connectionId;	//number
		public String nspAcknowIedged;	// string
	}
	public class cls_errors {
		public String code;	//string
		public String title;	//string
		public String detail;	//string
		public String source;	//string
	}
	public static AemoResultsPayload parse(String json){
		return (AemoResultsPayload) System.JSON.deserialize(json, AemoResultsPayload.class);
	}
	public String getJSON()
	{
		return JSON.serialize(this);
	}

}