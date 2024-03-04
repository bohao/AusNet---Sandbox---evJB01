@isTest
public class FnP_electricaldocumentattachmentTest {
static testMethod void invokeMethod(){
    Map<String, Object> m;
        string sr='{"ProjectId\":\"5005P000009B2p0QAC\",\"DocumentsDetails_Residential\":{\"Block_Attachments\":{\"Block_UploadAttachment1\":{\"File_PropertySiteplan\":[{\"PropertySketch/SitePlan\":\"sez\",\"data\":\"0698G000000CsJvQAK\",\"filename\":\"test.png\"}]},\"Block_UploadAttachment2\":{\"File_PlanofSubdivision\":[{\"PlanOfSubdivision\":\"sez\",\"data\":\"0698G000000CsJvQAK\",\"filename\":\"test.png\"}]},\"Block_UploadAttachment3\":{\"File_LoadCalculation\":[{\"LoadCalculation\":\"sez\",\"data\":\"0698G000000CsJvQAK\",\"filename\":\"test.png\"}]},\"Block_UploadAttachment4\":{\"File_DevelopmentPlans\":[{\"DevelopmentPlans\":\"sez\",\"data\":\"0698G000000CsJvQAK\",\"filename\":\"test.png\"}]},\"Block_UploadAttachment5\":{\"File_OtherAttachments\":[{\"Other\":\"testother\",\"data\":\"0698G000000CsJvQAK\",\"filename\":\"test.png\"}]}}}}';
        m = (Map<String, Object>) JSON.deserializeUntyped(sr);
    system.debug('mvalue>>'+m);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=FnP_electricaldocumentattachment.invokeMethod('FnP_uploadattachment',m, outputMap, options);
        Test.stopTest();
    }
}