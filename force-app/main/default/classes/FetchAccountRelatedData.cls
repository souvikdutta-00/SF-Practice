public with sharing class FetchAccountRelatedData {
  @InvocableMethod(label='Fetch Account Related Data')
  public static List<AccountOutputWrapper> fetchRelatedData(
    List<String> accountNames
  ) {
    List<AccountOutputWrapper> results = new List<AccountOutputWrapper>();

    if (accountNames == null || accountNames.isEmpty()) {
      return results;
    }

    List<Account> accounts = [
      SELECT
        Id,
        Name,
        Type,
        Industry,
        Rating,
        Phone,
        Website,
        AnnualRevenue,
        NumberOfEmployees,
        Owner.Name,
        (
          SELECT Id, Name, Title, Email, Phone
          FROM Contacts
        )
      FROM Account
      WHERE Name IN :accountNames
    ];

    for (Account acc : accounts) {
      // Account output wrapper
      AccountOutputWrapper output = new AccountOutputWrapper();

      output.accountId = acc.Id;
      output.accountName = acc.Name;
      output.accountType = acc.Type;
      output.industry = acc.Industry;
      output.rating = acc.Rating;
      output.phone = acc.Phone;
      output.website = acc.Website;
      output.annualRevenue = acc.AnnualRevenue;
      output.numberOfEmployees = acc.NumberOfEmployees;
      output.ownerName = acc.Owner.Name;

      // Contact items
      List<ContactItem> contactOutput = new List<ContactItem>();

      for (Contact con : acc.Contacts) {
        ContactItem item = new ContactItem();

        item.contactId = con.Id;
        item.contactName = con.Name;
        item.title = con.Title;
        item.email = con.Email;
        item.phone = con.Phone;
        contactOutput.add(item);
      }

      output.contactData = contactOutput;
      results.add(output);
    }

    return results;
  }

  // Account Output Wrapper
  public class AccountOutputWrapper {
    @InvocableVariable
    public String accountId;

    @InvocableVariable
    public String accountName;

    @InvocableVariable
    public String accountType;

    @InvocableVariable
    public String industry;

    @InvocableVariable
    public String rating;

    @InvocableVariable
    public String phone;

    @InvocableVariable
    public String website;

    @InvocableVariable
    public Decimal annualRevenue;

    @InvocableVariable
    public Integer numberOfEmployees;

    @InvocableVariable
    public String ownerName;

    @InvocableVariable
    public List<ContactItem> contactData;
  }

  // Individual Contact Data
  public class ContactItem {
    @InvocableVariable
    public String contactId;

    @InvocableVariable
    public String contactName;

    @InvocableVariable
    public String title;

    @InvocableVariable
    public String email;

    @InvocableVariable
    public String phone;
  }
}
