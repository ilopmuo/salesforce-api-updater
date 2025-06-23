/**
 * @description Trigger for Account object operations
 * @author Salesforce Dev Team
 */
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            // Before Insert Logic
            for(Account acc : Trigger.new) {
                if(String.isBlank(acc.Type)) {
                    acc.Type = 'Prospect';
                }
                
                if(String.isBlank(acc.AccountSource)) {
                    acc.AccountSource = 'Web';
                }
            }
        }
        
        if(Trigger.isUpdate) {
            // Before Update Logic
            for(Account acc : Trigger.new) {
                Account oldAccount = Trigger.oldMap.get(acc.Id);
                
                if(acc.AnnualRevenue != oldAccount.AnnualRevenue && acc.AnnualRevenue != null) {
                    if(acc.AnnualRevenue > 1000000) {
                        acc.Rating = 'Hot';
                    } else if(acc.AnnualRevenue > 100000) {
                        acc.Rating = 'Warm';
                    } else {
                        acc.Rating = 'Cold';
                    }
                }
            }
        }
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            // After Insert Logic
            System.debug('Created ' + Trigger.new.size() + ' new accounts');
        }
        
        if(Trigger.isUpdate) {
            // After Update Logic
            Set<Id> updatedAccountIds = new Set<Id>();
            for(Account acc : Trigger.new) {
                Account oldAccount = Trigger.oldMap.get(acc.Id);
                if(acc.BillingAddress != oldAccount.BillingAddress) {
                    updatedAccountIds.add(acc.Id);
                }
            }
            
            if(!updatedAccountIds.isEmpty()) {
                System.debug('Updated billing address for ' + updatedAccountIds.size() + ' accounts');
            }
        }
    }
} 