public without sharing class TVEChangePasswordController {
    @AuraEnabled 
    public static string changePasswordLink()
    {
        String changePasswordUrl='';
        User uObj = [Select id,Profile.UserLicense.Name from User where Id=: UserInfo.getUserId()];
        system.debug('user info:'+uObj.Profile.UserLicense.Name);
        String userLicense=uObj.Profile.UserLicense.Name;
        if(userLicense == 'Customer Community Plus Login'){
         changePasswordUrl=RedirectOAuthExt.constructB2CPasswordURL();
         system.debug('changePasswordUrl:'+changePasswordUrl);
        }
        else if (userLicense =='Partner Community')
        {
            changePasswordUrl=[SELECT Partner_Community_URL__c from TVE_AzureB2CAuthProvider__mdt WHERE DeveloperName = 'Ausnet_AzureAD'].Partner_Community_URL__c;
            system.debug('changePasswordUrl:'+changePasswordUrl);
        }
        return changePasswordUrl;
    }

}