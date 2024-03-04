public class TVE_CreateCMArtResponse {
	public String status {get;set;} 
	public String statusMessage {get;set;} 
	public Payload payload {get;set;} 
    
    public TVE_CreateCMArtResponse(){
        String status;
		String statusMessage; 
		Payload payload;
    }

	public TVE_CreateCMArtResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'status') {
						status = parser.getText();
					} else if (text == 'statusMessage') {
						statusMessage = parser.getText();
					} else if (text == 'payload') {
						payload = new Payload(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'TVE_CreateCMArtResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class d {
		//public _metadata x__metadata {get;set;} // in json: __metadata
		public String SapObject {get;set;} 
		public String ObjectId {get;set;} 
		public String ArcDocId {get;set;} 
		public String ArObject {get;set;} 
		public String Filename {get;set;} 
		public String FileContent {get;set;} 
		public String FileDesc {get;set;} 
		public String MimeType {get;set;} 
		public String OriginalUrl {get;set;} 
		public String Url {get;set;} 
		public String ThumbnailUrl {get;set;} 
		public String FileSize {get;set;} 
		public Object CreatedDate {get;set;} 
		public String Creator {get;set;} 
		public String ImageResize {get;set;} 

		public d(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						/*if (text == '__metadata') {
							x__metadata = new _metadata(parser);
						} else*/ if (text == 'SapObject') {
							SapObject = parser.getText();
						} else if (text == 'ObjectId') {
							ObjectId = parser.getText();
						} else if (text == 'ArcDocId') {
							ArcDocId = parser.getText();
						} else if (text == 'ArObject') {
							ArObject = parser.getText();
						} else if (text == 'Filename') {
							Filename = parser.getText();
						} else if (text == 'FileContent') {
							FileContent = parser.getText();
						} else if (text == 'FileDesc') {
							FileDesc = parser.getText();
						} else if (text == 'MimeType') {
							MimeType = parser.getText();
						} else if (text == 'OriginalUrl') {
							OriginalUrl = parser.getText();
						} else if (text == 'Url') {
							Url = parser.getText();
						} else if (text == 'ThumbnailUrl') {
							ThumbnailUrl = parser.getText();
						} else if (text == 'FileSize') {
							FileSize = parser.getText();
						} else if (text == 'CreatedDate') {
							CreatedDate = parser.readValueAs(Object.class);
						} else if (text == 'Creator') {
							Creator = parser.getText();
						} else if (text == 'ImageResize') {
							ImageResize = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'd consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Payload {
		public d d {get;set;} 

		public Payload(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'd') {
							d = new d(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Payload consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
/*	
	public class _metadata {
		public String id {get;set;} 
		public String uri {get;set;} 
		public String type_Z {get;set;} // in json: type
		public String content_type {get;set;} 
		public String media_src {get;set;} 

		public _metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'uri') {
							uri = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'content_type') {
							content_type = parser.getText();
						} else if (text == 'media_src') {
							media_src = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, '_metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	*/
	
	public static TVE_CreateCMArtResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new TVE_CreateCMArtResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

}