@RestResource(urlMapping='/mock/accounts/*')
global with sharing class ThirdPartyMockService {
  public class AccountRequest {
    public String accountId;
    public String name;
    public String rating;
    public String industry;
    public Integer retryCount; // sent by your worker
  }

  public class MockResponse {
    public Boolean success;
    public String message;
    public String errorType; // Permanent or Transient
    public String externalId;
  }

  @HttpPost
  global static void receive() {
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');
    MockResponse out = new MockResponse();

    try {
      String raw = RestContext.request.requestBody.toString();
      AccountRequest req = (AccountRequest) JSON.deserialize(
        raw,
        AccountRequest.class
      );
      Integer attempts = (req.retryCount == null) ? 0 : req.retryCount;

      if (String.isBlank(req.accountId)) {
        // bad request: permanent
        res.statusCode = 400;
        out.success = false;
        out.errorType = 'Permanent';
        out.message = 'accountId is required';
      } else if (req.rating == 'Cold') {
        // your "wrong response" case: permanent, never retry
        res.statusCode = 400;
        out.success = false;
        out.errorType = 'Permanent';
        out.message = 'Cold accounts are not accepted';
      } else if (req.rating == 'Warm' && attempts < 2) {
        // fail twice, then pass: tests your retry
        res.statusCode = 503;
        out.success = false;
        out.errorType = 'Transient';
        out.message = 'Service busy, try again';
      } else {
        res.statusCode = 200;
        out.success = true;
        out.message = 'Account accepted';
        out.externalId = 'EXT-' + req.accountId;
      }
    } catch (Exception e) {
      res.statusCode = 400;
      out.success = false;
      out.errorType = 'Permanent';
      out.message = 'Invalid request body: ' + e.getMessage();
    }

    res.responseBody = Blob.valueOf(JSON.serialize(out));
  }
}
