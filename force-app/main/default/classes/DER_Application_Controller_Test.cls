@isTest
public class DER_Application_Controller_Test {
	@isTest
    public static void testRetrieveNmi() {
    	String result = DER_Application_Controller.retrieveNmi('63050116074');
    	System.assertNotEquals(null, result);
    }

    @isTest
    public static void testRetrieveNmiException() {
    	String result = DER_Application_Controller.retrieveNmi('TestFake');
    	System.assertEquals('None', result);
    }

    @isTest
    public static void testSaveRecords() {
    	DER_Application_Controller.ResultWrapper wrapper = new DER_Application_Controller.ResultWrapper();
    	wrapper.nmi = 'TestNmi';
    	wrapper.meter = 'TestMeter';
    	wrapper.installer = 'TestInstaller';
    	wrapper.agreementStatus = 'Offer Made';
    	wrapper.caseStatus = 'New';
		wrapper.invNum = '12345';
    	wrapper.agreementType = 'Basic Micro EG MSO';
    	wrapper.applicantType = 'Installer';
    	wrapper.resParty = 'Installer';
    	wrapper.installerSalutation = 'Mr.';
    	wrapper.installerFirstName = 'Test';
    	wrapper.installerLastName = 'lastname';
    	wrapper.accreditationType = 'CEC';
    	wrapper.accreditationNumber = '12345';
    	wrapper.installerContactEmail = 'test@abc.com';
    	wrapper.installerContactPhone = '1800123456';
    	wrapper.abn = '1234567890';
    	wrapper.phone = '1800123456';
    	wrapper.shippingStreet = '123 abc street';
    	wrapper.shippingCity = 'test city';
    	wrapper.shippingState = 'test State';
    	wrapper.shippingPostal = '4000';
    	wrapper.shippingCountry = 'Aus';
    	wrapper.mailingStreet = '123 abc street';
    	wrapper.mailingCity = 'test city';
    	wrapper.mailingState = 'test State';
    	wrapper.mailingPostal = '4000';
    	wrapper.mailingCountry = 'Aus';
    	wrapper.repSalutation = 'Mr.';
    	wrapper.repFirstName = 'Test';
    	wrapper.repLastName = 'lastname';
    	wrapper.repEmail = 'test@example.com';
    	wrapper.customerSalutation = 'Mr.';
    	wrapper.customerFirstName = 'Test';
    	wrapper.customerLastName = 'lastname';
    	wrapper.customerEmail = 'test@example.com';
    	wrapper.customerPhone = '1800123456';
    	wrapper.createAgreement = true;
    	wrapper.acceptedDate = Date.today();
    	wrapper.activeDate = Date.today();
    	wrapper.offerMadeDate = Date.today();

    	String result = DER_Application_Controller.saveRecords(wrapper);
    	System.assertNotEquals(null, result);
    }
}