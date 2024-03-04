public without sharing class TVE_ContentDocument_Utility {
        @future
            public static void changeDocumentOwner(Set<Id> contentDocumentIds){
                List<ContentDocument> cdUpdate = new List<ContentDocument>();
                Id Owner = tve_integutility.getIntegrationUserId();
                if(!contentDocumentIds.isEmpty()){
                    for(Contentdocument cd : [select Id,ownerId from ContentDocument where Id IN : contentDocumentIds]){
                        //set Integration user as owner of the content document.
                        If(Owner!=null){
                        cd.OwnerId=Owner;
                        cdUpdate.add(cd);
                        }
                    }
               }
                try{
                    if(cdUpdate.size()>0){
                    database.update(cdUpdate);}
                }
                catch (Exception e){
                    system.debug('Exception'+e.getMessage());
                    
                } 
                
            }
}