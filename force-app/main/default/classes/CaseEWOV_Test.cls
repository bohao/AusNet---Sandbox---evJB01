@isTest
public class CaseEWOV_Test {
    @isTest
    static void testNewAssistedReferralEmailVariation1() {
        String subject='New Assisted Referral 2021/5674 Mr John Jones';
        String description='Electricity Case: 2021/5674'+'\n';
        description+='Dear AusNet Services'+'\n';
        description+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        description+='Customer name:'+'\n';
        description+='Mr John Jones'+'\n';
        description+='Postal address:'+'\n';
        description+='144 Brysons Rd' +'\n';
        description+='WONGA PARK VIC 3115' +'\n';
        description+='Mobile phone:' +'\n';
        description+='0428 699 104' +'\n';
        description+='Email:' +'\n';
        description+='johnwjones@yahoo.com.invalid' +'\n';
        description+='Pref. Contact Method:' +'\n';
        description+='Email only' +'\n';
        description+='NMI / MIRN:' +'\n';
        description+='63056610014' +'\n';
        description+='Customer statement' +'\n';
        description+='1. He is dissatisfied with AusNet Services (ANS) in relation to loss.' +'\n';
        description+='2. On 27 August 2020 there was a high voltage power surge that damaged his some of his appliances.' +'\n';
        description+='3. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='4. He submitted a claim to ANS for compensation for lost appliances and length of time off supply, however, it has been rejected.' +'\n';
        description+='5. ANS has advised that in the absence of negligence on its part it is unable to accept liability and suggested he contact his insurance provider.' +'\n';
        description+='' +'\n';
        description+='Resolution sought' +'\n';
        description+='1. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';       
        description+='' +'\n';
        description+='What AusNet Services needs to do next' +'\n';
        description+='This is an Assisted Referral, so please:' +'\n';
        description+='call or write to the customer to discuss their concerns by 17 May 2021' +'\n';
        description+='work with the customer to resolve their concerns by 2 June 2021.' +'\n';
        description+='When AusNet Services has completed the Assisted Referral' +'\n';
        
        System.debug('***Email body:'+description);
        
        
        Case newAssistedRefCase=new Case();
        newAssistedRefCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        newAssistedRefCase.Subject=subject;
        newAssistedRefCase.Description=description;
        insert newAssistedRefCase;               
        
        Case c=[Select dcp_EWOV_Case_Number__c, dcp_EWOV_Level__c, dcp_Assisted_Referral_Date__c, SuppliedName, SuppliedPhone from Case where id=:newAssistedRefCase.id];        
                
        System.assertEquals('2021/5674', c.dcp_EWOV_Case_Number__c, 'Check if EWOV Reference is assigned correctly');
        System.assertEquals('Assisted Referral', c.dcp_EWOV_Level__c, 'Check if EWOV level is assigned correctly');
        System.assertEquals(Date.today(), c.dcp_Assisted_Referral_Date__c, 'Check if Assisted Referral Date is assigned correctly');
        System.assertEquals('John Jones', c.SuppliedName, 'Check if Name is assigned correctly');
        System.assertEquals('0428 699 104', c.SuppliedPhone, 'Check if Phone is assigned correctly');		
    }
    @isTest
    static void testNewAssistedReferralEmailVariation2() {
        String subject='New Assisted Referral 2021/5674 Mr John Jones';
        String description='Electricity Case: 2021/5674'+'\n';
        description+='Dear AusNet Services'+'\n';
        description+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        description+='Customer name:'+'\n';
        description+='Mr John Jones'+'\n';
        description+='Postal address:'+'\n';
        description+='144 Brysons Rd, WONGA PARK VIC 3115' +'\n';        
        description+='Mobile phone:' +'\n';
        description+='0428 699 104' +'\n';
        description+='Email:' +'\n';
        description+='johnwjones@yahoo.com.invalid' +'\n';
        description+='Pref. Contact Method:' +'\n';
        description+='Email only' +'\n';
        description+='NMI / MIRN:' +'\n';
        description+='63056610014' +'\n';
        description+='Customer statement' +'\n';
        description+='1. He is dissatisfied with AusNet Services (ANS) in relation to loss.' +'\n';
        description+='2. On 27 August 2020 there was a high voltage power surge that damaged his some of his appliances.' +'\n';
        description+='3. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='4. He submitted a claim to ANS for compensation for lost appliances and length of time off supply, however, it has been rejected.' +'\n';        
        description+='' +'\n';
        description+='Resolution sought' +'\n';
        description+='1. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';   
        description+='2. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';
        description+='' +'\n';
        description+='What AusNet Services needs to do next' +'\n';
        description+='This is an Assisted Referral, so please:' +'\n';
        description+='call or write to the customer to discuss their concerns by 17 Nov 2021' +'\n';
        description+='work with the customer to resolve their concerns by 2 June 2021.' +'\n';
        description+='When AusNet Services has completed the Assisted Referral' +'\n';
        
        System.debug('***Email body:'+description);
        
        Case newAssistedRefCase=new Case();
        newAssistedRefCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        newAssistedRefCase.Subject=subject;
        newAssistedRefCase.Description=description;
        insert newAssistedRefCase;                        
        
        Case c=[Select dcp_EWOV_Case_Number__c, dcp_EWOV_Level__c, dcp_Assisted_Referral_Date__c, SuppliedName, SuppliedPhone from Case where id=:newAssistedRefCase.id];        
               
        System.assertEquals('2021/5674', c.dcp_EWOV_Case_Number__c, 'Check if EWOV Reference is assigned correctly');
        System.assertEquals('Assisted Referral', c.dcp_EWOV_Level__c, 'Check if EWOV level is assigned correctly');
        System.assertEquals(Date.today(), c.dcp_Assisted_Referral_Date__c, 'Check if Assisted Referral Date is assigned correctly');
        System.assertEquals('John Jones', c.SuppliedName, 'Check if Name is assigned correctly');
        System.assertEquals('0428 699 104', c.SuppliedPhone, 'Check if Phone is assigned correctly');
    }
    @isTest
    static void testNewAssistedReferralEmailVariation3() {
        String subject='New Assisted Referral 2021/5674 Mr John Jones';
        String description='Electricity Case: 2021/5674'+'\n';
        description+='Dear AusNet Services'+'\n';
        description+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        description+='Customer details'+'\n';
        description+='Customer name:'+'\n';
        description+='Mr John Jones'+'\n';
        description+='Postal address:'+'\n';
        description+='144 Brysons Rd' +'\n';
        description+='WONGA' +'\n';
        description+='WONGA PARK VIC 3115' +'\n';
        description+='Mobile phone:' +'\n';
        description+='0428 699 104' +'\n';
        description+='Email:' +'\n';
        description+='johnwjones@yahoo.com.invalid' +'\n';
        description+='Pref. Contact Method:' +'\n';
        description+='Email only' +'\n';
        description+='NMI / MIRN:' +'\n';
        description+='63056610014' +'\n';
        description+='Customer statement' +'\n';
        description+='1. He is dissatisfied with AusNet Services (ANS) in relation to loss.' +'\n';
        description+='2. On 27 August 2020 there was a high voltage power surge that damaged his some of his appliances.' +'\n';
        description+='3. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='4. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='5. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='6. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='7. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='8. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';               
        description+='' +'\n';
        description+='Resolution sought' +'\n';
        description+='1. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';  
        description+='2. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';
        description+='3. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';
        description+='' +'\n';
        description+='What AusNet Services needs to do next' +'\n';
        description+='This is an Assisted Referral, so please:' +'\n';
        description+='call or write to the customer to discuss their concerns by 17 December 2021' +'\n';
        description+='work with the customer to resolve their concerns by 2 December 2021.' +'\n';
        description+='When AusNet Services has completed the Assisted Referral' +'\n';
        
        System.debug('***Email body:'+description);
        
        Case newAssistedRefCase=new Case();
        newAssistedRefCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        newAssistedRefCase.Subject=subject;
        newAssistedRefCase.Description=description;
        insert newAssistedRefCase;      
        
        Case c=[Select dcp_EWOV_Case_Number__c, dcp_EWOV_Level__c, dcp_Assisted_Referral_Date__c, SuppliedName, SuppliedPhone from Case where id=:newAssistedRefCase.id];        
               
        System.assertEquals('2021/5674', c.dcp_EWOV_Case_Number__c, 'Check if EWOV Reference is assigned correctly');
        System.assertEquals('Assisted Referral', c.dcp_EWOV_Level__c, 'Check if EWOV level is assigned correctly');
        System.assertEquals(Date.today(), c.dcp_Assisted_Referral_Date__c, 'Check if Assisted Referral Date is assigned correctly');
        System.assertEquals('John Jones', c.SuppliedName, 'Check if Name is assigned correctly');
        System.assertEquals('0428 699 104', c.SuppliedPhone, 'Check if Phone is assigned correctly');
    }
     @isTest
    static void testUpgradeStage3ReferralEmailVariation1() {
        String subject='New Assisted Referral 2021/5674 Mr John Jones';
        String description='Electricity Case: 2021/5674'+'\n';
        description+='Dear AusNet Services'+'\n';
        description+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        description+='Customer name:'+'\n';
        description+='Mr John Jones'+'\n';
        description+='Postal address:'+'\n';
        description+='144 Brysons Rd' +'\n';
        description+='WONGA PARK VIC 3115' +'\n';
        description+='Mobile phone:' +'\n';
        description+='0428 699 104' +'\n';
        description+='Email:' +'\n';
        description+='johnwjones@yahoo.com.invalid' +'\n';
        description+='Pref. Contact Method:' +'\n';
        description+='Email only' +'\n';
        description+='NMI / MIRN:' +'\n';
        description+='63056610014' +'\n';
        description+='Customer statement' +'\n';
        description+='1. He is dissatisfied with AusNet Services (ANS) in relation to loss.' +'\n';
        description+='2. On 27 August 2020 there was a high voltage power surge that damaged his some of his appliances.' +'\n';
        description+='3. Power was restored on 30 August 2020 to the area except his house as his meter required replacement.' +'\n';
        description+='4. He submitted a claim to ANS for compensation for lost appliances and length of time off supply, however, it has been rejected.' +'\n';
        description+='5. ANS has advised that in the absence of negligence on its part it is unable to accept liability and suggested he contact his insurance provider.' +'\n';
        description+='' +'\n';
        description+='Resolution sought' +'\n';
        description+='1. Consider compensation for the appliances damaged by the high voltage power surge.' +'\n';       
        description+='' +'\n';
        description+='What AusNet Services needs to do next' +'\n';
        description+='This is an Assisted Referral, so please:' +'\n';
        description+='call or write to the customer to discuss their concerns by 17 May 2021' +'\n';
        description+='work with the customer to resolve their concerns by 2 June 2021.' +'\n';
        description+='When AusNet Services has completed the Assisted Referral' +'\n';
        
        System.debug('***Email body:'+description);
        
        
        Case newAssistedRefCase=new Case();
        newAssistedRefCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        newAssistedRefCase.Subject=subject;
        newAssistedRefCase.Description=description;
        insert newAssistedRefCase;               
        
        Case c=[Select dcp_EWOV_Case_Number__c, dcp_EWOV_Level__c, dcp_Assisted_Referral_Date__c, SuppliedName, SuppliedPhone from Case where id=:newAssistedRefCase.id];        
        
        System.assertEquals('2021/5674', c.dcp_EWOV_Case_Number__c, 'Check if EWOV Reference is assigned correctly');
        System.assertEquals('Assisted Referral', c.dcp_EWOV_Level__c, 'Check if EWOV level is assigned correctly');
        System.assertEquals(Date.today(), c.dcp_Assisted_Referral_Date__c, 'Check if Assisted Referral Date is assigned correctly');
        System.assertEquals('John Jones', c.SuppliedName, 'Check if Name is assigned correctly');
        System.assertEquals('0428 699 104', c.SuppliedPhone, 'Check if Phone is assigned correctly');
        
        String ugSubject='New Stage 2 2021/5674 Mr John Jones';
        String ugDescription='Electricity Case: 2021/5674'+'\n';
        ugDescription+='Dear AusNet Services'+'\n';
        ugDescription+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        ugDescription+='New Stage 2 Complaint'+'\n';      
        ugDescription+='What AusNet Services needs to do next' +'\n';
        ugDescription+='This is an Assisted Referral, so please:' +'\n';
        ugDescription+='call or write to the customer to discuss their concerns by 17 May 2021' +'\n';
        ugDescription+='work with the customer to resolve their concerns by 2 June 2021.' +'\n';
        ugDescription+='When AusNet Services has completed the Assisted Referral' +'\n';

        Case upgradeRefCase=new Case();
        upgradeRefCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        upgradeRefCase.Subject=ugSubject;
        upgradeRefCase.Description=ugDescription;
        insert upgradeRefCase; 
        
        String ugfSubject='Further information request 2021/5674 Mr John Jones';
        String ugfDescription='Electricity Case: 2021/5674'+'\n';
        ugfDescription+='Dear AusNet Services'+'\n';
        ugfDescription+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        ugfDescription+='Further information'+'\n';      
        ugfDescription+='What AusNet Services needs to do next' +'\n';
        ugfDescription+='This is an Assisted Referral, so please:' +'\n';
        ugfDescription+='call or write to the customer to discuss their concerns by 17 May 2021' +'\n';
        ugfDescription+='work with the customer to resolve their concerns by 2 June 2021.' +'\n';
        ugfDescription+='When AusNet Services has completed the Assisted Referral' +'\n';

        Case upgradeRefCase2=new Case();
        upgradeRefCase2.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        upgradeRefCase2.Subject=ugfSubject;
        upgradeRefCase2.Description=ugfDescription;
        insert upgradeRefCase2;
        
        String ugs3Subject='Upgrade notification 2021/5674 Mr John Jones';
        String ugs3Description='Electricity Case: 2021/5674'+'\n';
        ugs3Description+='Dear AusNet Services'+'\n';
        ugs3Description+='Mr John Jones has contacted EWOV about an issue that remains unresolved. Please work with Mr John Jones to resolve the complaint.'+'\n';
        ugs3Description+='Upgrade to Stage 3'+'\n';      
        ugs3Description+='What AusNet Services needs to do next' +'\n';
        ugs3Description+='This is an Assisted Referral, so please:' +'\n';
        ugs3Description+='call or write to the customer to discuss their concerns by 17 May 2021' +'\n';
        ugs3Description+='work with the customer to resolve their concerns by 2 June 2021.' +'\n';
        ugs3Description+='When AusNet Services has completed the Assisted Referral' +'\n';

        Case upgradeRefCase3=new Case();
        upgradeRefCase3.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        upgradeRefCase3.Subject=ugs3Subject;
        upgradeRefCase3.Description=ugs3Description;
        insert upgradeRefCase3;
    }
}