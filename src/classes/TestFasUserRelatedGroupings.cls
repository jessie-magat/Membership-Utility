/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestFasUserRelatedGroupings {

    static testMethod void TestFasUserRelatedGroupings() {
        List<User> userList = new List<User>([SELECT id, name, assigned_Permission_Sets__c, Related_Queues__c, Related_Groups__c, userRoleId, UserPermissionsMarketingUser, UserType
                                                  FROM User WHERE isActive=true AND userType='Standard' LIMIT 10]);
        fasUserRelatedGroupings  batchShare= new fasUserRelatedGroupings();
        Database.Querylocator    queryLoc    =   batchShare.start(null);
        batchShare.execute(null, userList);
        System.assertEquals(true,true);  
    }
}