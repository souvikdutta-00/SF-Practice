/**
 * @description       : Fetches related data for specified Accounts, including their Contacts and Opportunities.
 * @author            : Souvik Dutta
 * @group             : 
 * @last modified on  : 09-05-2026
 * @last modified by  : Souvik Dutta
**/
public with sharing class FetchAccountRelatedData {

    @InvocableMethod(label='Fetch Account Related Data' description='Fetch the related data of Account object')
    public static List<AccountRelatedData> fetchRelatedData(List<String> accountNames) {
        List<AccountRelatedData> result = new List<AccountRelatedData>();

        List<Account> accounts = [
            SELECT Id, Name,
                (SELECT Id, Name FROM Contacts),
                (SELECT Id, Name FROM Opportunities)
            FROM Account
            WHERE Name IN :accountNames
        ];

        for (Account acc : accounts) {
            AccountRelatedData data = new AccountRelatedData();
            data.accountId = acc.Id;
            data.accountName = acc.Name;

            // Flatten Contacts into a comma-separated String
            List<String> contactNames = new List<String>();
            for (Contact c : acc.Contacts) {
                contactNames.add(c.Name);
            }
            data.contactNames = String.join(contactNames, ', ');

            // Flatten Opportunities into a comma-separated String
            List<String> oppNames = new List<String>();
            for (Opportunity o : acc.Opportunities) {
                oppNames.add(o.Name);
            }
            data.opportunityNames = String.join(oppNames, ', ');

            result.add(data);
        }

        return result;
    }

    public class AccountRelatedData {
        @InvocableVariable(label='Account Id' description='Id of the Account')
        public String accountId;

        @InvocableVariable(label='Account Name' description='Name of the Account')
        public String accountName;

        @InvocableVariable(label='Contact Names' description='Comma-separated list of related Contact names')
        public String contactNames;

        @InvocableVariable(label='Opportunity Names' description='Comma-separated list of related Opportunity names')
        public String opportunityNames;
    }
}