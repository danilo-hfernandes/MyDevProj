@isTest
public class CertificateComponentControllerTest {
    @isTest
    static void createOppTest(){
        Certificate__c objcertificate = new Certificate__c();
        objcertificate.Certificate_ID__c = 'HCP-101';
        objcertificate.Coupon_Type__c = 'Hawaii Collection Plus Extension Certificates';
        insert objcertificate;
        
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        insert objAcc;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 objprod = new Product2();
        objprod.Name = 'Hawaii Collection Plus TC';
        insert objprod;
        
        CertificateComponentController.validateCertificateId(objcertificate.Certificate_ID__c);
        CertificateComponentController.createOpportunity(objAcc.Id,'',objcertificate.Id);
    }
	@isTest
    static void createOppTest1(){
        Certificate__c objcertificate = new Certificate__c();
        objcertificate.Certificate_ID__c = 'HCP-101';
        objcertificate.Coupon_Type__c = 'HC MX National SPA';
        insert objcertificate;
        
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        objAcc.Email__c = 'test@gail.com';
        insert objAcc;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 objprod = new Product2();
        objprod.Name = 'Advantage Getaway Voucher';
        insert objprod;
        
        CertificateComponentController.validateCertificateId(objcertificate.Certificate_ID__c);
        CertificateComponentController.createOpportunity(objAcc.Id,'',objcertificate.Id);
    }
	@isTest
    static void createOppTest2(){
        Certificate__c objcertificate = new Certificate__c();
        objcertificate.Certificate_ID__c = 'HCP-101';
        objcertificate.Coupon_Type__c = 'HCP RW Cert';
        insert objcertificate;
        
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        objAcc.Email__c = 'test@gail.com';
        insert objAcc;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 objprod = new Product2();
        objprod.Name = 'Hawaii Collection Plus RW Cert';
        insert objprod;
        
        CertificateComponentController.validateCertificateId(objcertificate.Certificate_ID__c);
        CertificateComponentController.createOpportunity(objAcc.Id,'',objcertificate.Id);
    }

                
                
}