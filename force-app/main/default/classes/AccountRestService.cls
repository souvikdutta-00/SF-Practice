@RestResource(urlMapping='/v1/AccountService/*')
global with sharing class AccountRestService {
  // The shape of what we send back
  global class AccountResponse {
    public Boolean success;
    public String message;
    public Integer count;
    public List<Account> accounts;
  }

  // CHANGED: Changed return type from 'void' to 'AccountResponse'
  @HttpGet
  global static AccountResponse getAccounts() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    // Salesforce sets Content-Type to JSON automatically when returning an object,
    // but keeping this line is perfectly safe.
    res.addHeader('Content-Type', 'application/json');
    AccountResponse body = new AccountResponse();

    try {
      // 1. Is there an Id at the end of the URL?
      String lastPart = req.requestURI.substringAfterLast('/');
      // FIXED: Fixed the check to match your /v1/AccountService mapping
      Boolean hasId =
        String.isNotBlank(lastPart) && lastPart != 'AccountService';

      if (hasId) {
        // ---- Single account (with its contacts) ----
        List<Account> result = [
          SELECT
            Id,
            Name,
            Industry,
            Type,
            Phone,
            BillingCity,
            BillingCountry,
            (SELECT Id, Name, Email, Title FROM Contacts)
          FROM Account
          WHERE Id = :lastPart
          WITH USER_MODE
        ];
        if (result.isEmpty()) {
          res.statusCode = 404;
          body.success = false;
          body.message = 'No account found for Id ' + lastPart;
          return body; // CHANGED: Direct object return
        }
        body.accounts = result;
      } else {
        // ---- List of accounts, with optional filters ----
        String industry = req.params.get('industry');
        String name = req.params.get('name');
        Integer maxRows = 10;
        if (req.params.containsKey('limit')) {
          maxRows = Math.min(Integer.valueOf(req.params.get('limit')), 200);
        }

        String soql =
          'SELECT Id, Name, Industry, Type, Phone, BillingCity, BillingCountry ' +
          'FROM Account';
        List<String> conditions = new List<String>();
        Map<String, Object> binds = new Map<String, Object>();

        if (String.isNotBlank(industry)) {
          conditions.add('Industry = :industry');
          binds.put('industry', industry);
        }
        if (String.isNotBlank(name)) {
          conditions.add('Name LIKE :likeName');
          binds.put('likeName', '%' + name + '%');
        }
        if (!conditions.isEmpty()) {
          soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY CreatedDate DESC LIMIT ' + maxRows;

        body.accounts = Database.queryWithBinds(
          soql,
          binds,
          AccessLevel.USER_MODE
        );
      }

      res.statusCode = 200;
      body.success = true;
      body.count = body.accounts.size();
      body.message = 'OK';
    } catch (QueryException e) {
      res.statusCode = 403;
      body.success = false;
      body.message = 'Access or query problem: ' + e.getMessage();
    } catch (Exception e) {
      res.statusCode = 400;
      body.success = false;
      body.message = e.getMessage();
    }

    // CHANGED: Removed manual Blob serialization. Returning the object directly
    // allows the OpenAPI parser to inspect your structure and generate the schema.
    return body;
  }
}
