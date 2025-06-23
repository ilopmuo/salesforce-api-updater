/**
 * @description Manager class for Opportunity operations
 * @author Salesforce Team
 * @version 1.0
 */
public class OpportunityManager {
    
    public static final Decimal DEFAULT_PROBABILITY = 25.0;
    private static final Integer DAYS_TO_CLOSE = 30;
    
    /**
     * @description Creates new opportunities with default settings
     * @param accountIds List of account IDs for opportunity creation
     * @param opportunityName Base name for opportunities
     * @return List<Opportunity> Created opportunities
     */
    public static List<Opportunity> createOpportunities(List<Id> accountIds, String opportunityName) {
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        
        for(Id accountId : accountIds) {
            Opportunity newOpp = new Opportunity();
            newOpp.Name = opportunityName + ' - ' + Date.today().format();
            newOpp.AccountId = accountId;
            newOpp.StageName = 'Prospecting';
            newOpp.CloseDate = Date.today().addDays(DAYS_TO_CLOSE);
            newOpp.Probability = DEFAULT_PROBABILITY;
            newOpp.Amount = 10000;
            
            opportunitiesToCreate.add(newOpp);
        }
        
        if(!opportunitiesToCreate.isEmpty()) {
            insert opportunitiesToCreate;
            System.debug('Created ' + opportunitiesToCreate.size() + ' opportunities');
        }
        
        return opportunitiesToCreate;
    }
    
    /**
     * @description Updates opportunity stage and probability
     * @param oppId The opportunity ID to update
     * @param newStage The new stage name
     * @param newProbability The new probability percentage
     */
    public static void updateOpportunityStage(Id oppId, String newStage, Decimal newProbability) {
        Opportunity opp = new Opportunity(Id = oppId);
        opp.StageName = newStage;
        opp.Probability = newProbability;
        
        update opp;
        
        System.debug('Updated opportunity ' + oppId + ' to stage: ' + newStage);
    }
    
    /**
     * @description Calculates total pipeline value for an account
     * @param accountId The account ID to calculate pipeline for
     * @return Decimal Total pipeline value
     */
    public static Decimal calculatePipelineValue(Id accountId) {
        AggregateResult result = [
            SELECT SUM(Amount) totalAmount 
            FROM Opportunity 
            WHERE AccountId = :accountId 
            AND IsClosed = false
        ];
        
        Decimal totalPipeline = (Decimal)result.get('totalAmount');
        return totalPipeline != null ? totalPipeline : 0;
    }
    
    /**
     * @description Gets opportunities closing this quarter
     * @return List<Opportunity> Opportunities closing in current quarter
     */
    public static List<Opportunity> getOpportunitiesThisQuarter() {
        return [
            SELECT Id, Name, Amount, StageName, CloseDate, Account.Name
            FROM Opportunity 
            WHERE CloseDate = THIS_QUARTER
            AND IsClosed = false
            ORDER BY CloseDate ASC
        ];
    }
} 