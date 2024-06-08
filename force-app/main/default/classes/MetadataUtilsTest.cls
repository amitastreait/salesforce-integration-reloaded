/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@IsTest
public with sharing class MetadataUtilsTest {
    @IsTest
    public static void listMetadataTest(){
        Test.setMock(WebServiceMock.class, new MetadataUtilsMock());
        Test.startTest();
        MetadataUtils.listMetadata();
        Test.stopTest();
    }

    @IsTest
    public static void readMetadataTest(){
        Test.setMock(WebServiceMock.class, new MetadataUtilsMock());
        Test.startTest();
        MetadataUtils.readMetadata();
        Test.stopTest();
    }

    @IsTest
    public static void createObjectTest(){
        Test.setMock(WebServiceMock.class, new MetadataUtilsMock());
        Test.startTest();
        MetadataUtils.createObject('Invoice', 'Invoices');
        Test.stopTest();
    }

    @IsTest
    public static void createFieldsTest(){
        Test.setMock(WebServiceMock.class, new MetadataUtilsMock());
        Test.startTest();
        MetadataUtils.createFields('Account', 'Stripe UUID');
        Test.stopTest();
    }
}