/**
 * @description       : To fetch the customer details and rental details based on the input first name and last name of the customer.
 * @author            : Souvik Dutta
 * @group             : 
 * @last modified on  : 24-10-2026
 * @last modified by  : Souvik Dutta
**/
public with sharing class ShowCustomerDetails {
    @InvocableMethod(label = 'Show Customer Details' description = 'Show Customer Details')
    public static List<OutputWrapper> showCustomerDetails(List<InputWrapper> inputList) {
        List<OutputWrapper> result = new List<OutputWrapper>();
        if (inputList == null || inputList.isEmpty()) {
            return result;
        }
        String customerFirstName = inputList[0].customerFirstName;
        String customerLastName = inputList[0].customerLastName;

        Customer__c customer = [SELECT Id,First_name__c,Last_name__c,Date_of_Birth__c,Gender__c,Loyalty_Tier__c,Phone__c,Email__c FROM Customer__c WHERE First_name__c = :customerFirstName AND Last_name__c = :customerLastName LIMIT 1];
        List<Rental__c> rentals = [SELECT Id,Name,Movie__r.Name,Rental_Date__c,Rental_Fee__c FROM Rental__c             
        WHERE Customer__c = :customer.Id];

        // Create output wrapper for customer details
        OutputWrapper output = new OutputWrapper();
        output.fResponse = new FinalResponse();
        output.fResponse.customerDetails = new CustomerDetails(customer);
        output.fResponse.rentalDetailsList = new List<RentalDetails>();

        // Create output wrappers for rental details
        for (Rental__c rental : rentals) {
            output.fResponse.rentalDetailsList.add(new RentalDetails(rental));
        }

        result.add(output);
        return result;
    }

    public class InputWrapper{
        @InvocableVariable(label = 'Customer First Name' description = 'Customer First Name' required = true)
        public String customerFirstName;
        @InvocableVariable(label = 'Customer Last Name' description = 'Customer Last Name' required = true)
        public String customerLastName;
    }

    public class OutputWrapper{
        @InvocableVariable(label = 'Final Response' description = 'Final Response')
        public FinalResponse fResponse;
    }

    public class FinalResponse{
        @InvocableVariable(label = 'Customer Details' description = 'Customer details')
        public CustomerDetails customerDetails;

        @InvocableVariable(label = 'Rental Details' description = 'List of rental details')
        public List<RentalDetails> rentalDetailsList;
    }

    public class CustomerDetails {
        @InvocableVariable(label = 'First Name' description = 'First Name')
        public String firstName;
        @InvocableVariable(label = 'Last Name' description = 'Last Name')
        public String lastName;
        @InvocableVariable(label = 'Date of Birth' description = 'Date of Birth')
        public Date dateOfBirth;
        @InvocableVariable(label = 'Gender' description = 'Gender')
        public String gender;
        @InvocableVariable(label = 'Loyalty Points' description = 'Loyalty Points')
        public String loyaltyPoints;
        @InvocableVariable(label = 'Email' description = 'Email')
        public String email;
        @InvocableVariable(label = 'Phone' description = 'Phone')
        public String phone;

        public CustomerDetails(Customer__c customer) {
            this.firstName = customer.First_name__c;
            this.lastName = customer.Last_name__c;
            this.dateOfBirth = customer.Date_of_Birth__c;
            this.gender = customer.Gender__c;
            this.loyaltyPoints = customer.Loyalty_Tier__c;
            this.email = customer.Email__c;
            this.phone = customer.Phone__c;
        }
    }

    public class RentalDetails {
        @InvocableVariable(label = 'Name' description = 'Name')
        public String name;
        @InvocableVariable(label = 'Movie Name' description = 'Movie Name')
        public String movieName;
        @InvocableVariable(label = 'Rental Date' description = 'Rental Date')
        public Date rentalDate;
        @InvocableVariable(label = 'Rental Amount' description = 'Rental Amount')
        public Decimal rentalAmount;

        public RentalDetails(Rental__c rental) {
            this.name = rental.Name;
            this.movieName = rental.Movie__r.Name;
            this.rentalDate = rental.Rental_Date__c;
            this.rentalAmount = rental.Rental_Fee__c;
        }
    }
}