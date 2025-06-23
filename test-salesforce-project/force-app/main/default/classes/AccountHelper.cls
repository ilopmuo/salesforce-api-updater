/**
 * @description Helper class for Account operations
 * @author Test Developer
 * @date 2024-06-20
 */
public class AccountHelper {
    
    // Helper constants
    private static final String DEFAULT_TYPE = 'Customer';
    private static final String DEFAULT_INDUSTRY = 'Technology';
    
    /**
     * @description Creates a new Account with default values
     * @param accountName The name for the new account
     * @return Account The created account record
     */
    public static Account createAccount(String accountName) {
        Account newAccount = new Account();
        newAccount.Name = accountName;
        newAccount.Type = DEFAULT_TYPE;
        newAccount.Industry = DEFAULT_INDUSTRY;
        
        insert newAccount;
        return newAccount;
    }
    
    /**
     * @description Updates account billing information
     * @param accountId The ID of the account to update
     * @param billingCity The new billing city
     */
    public static void updateBilling(Id accountId, String billingCity) {
        Account acc = [SELECT Id, BillingCity FROM Account WHERE Id = :accountId LIMIT 1];
        acc.BillingCity = billingCity;
        update acc;
        
        System.debug('Updated account billing city to: ' + billingCity);
    }
    
    /**
     * @description Gets all accounts with recent opportunities
     * @return List<Account> List of accounts with opportunities
     */
    public static List<Account> getAccountsWithOpportunities() {
        return [
            SELECT Id, Name, (SELECT Id, Name FROM Opportunities) 
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE CreatedDate = LAST_30_DAYS)
            LIMIT 100
        ];
    }
} 