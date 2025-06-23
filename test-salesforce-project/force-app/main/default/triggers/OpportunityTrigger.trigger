/**
 * @description Trigger for Opportunity object operations
 * @author Sales Team
 */
trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            // Before Insert - Set default values
            for(Opportunity opp : Trigger.new) {
                if(opp.LeadSource == null) {
                    opp.LeadSource = 'Web';
                }
                
                if(opp.Type == null) {
                    opp.Type = 'New Customer';
                }
                
                // Set probability based on stage
                if(opp.StageName == 'Prospecting') {
                    opp.Probability = 10;
                } else if(opp.StageName == 'Qualification') {
                    opp.Probability = 25;
                } else if(opp.StageName == 'Proposal/Price Quote') {
                    opp.Probability = 75;
                }
            }
        }
        
        if(Trigger.isUpdate) {
            // Before Update - Validation logic
            for(Opportunity opp : Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                
                // Prevent moving backwards in sales stages
                if(opp.StageName != oldOpp.StageName) {
                    List<String> stageOrder = new List<String>{'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition', 'Id. Decision Makers', 'Perception Analysis', 'Proposal/Price Quote', 'Negotiation/Review', 'Closed Won', 'Closed Lost'};
                    
                    Integer oldStageIndex = stageOrder.indexOf(oldOpp.StageName);
                    Integer newStageIndex = stageOrder.indexOf(opp.StageName);
                    
                    if(newStageIndex != -1 && oldStageIndex != -1 && newStageIndex < oldStageIndex && !opp.StageName.startsWith('Closed')) {
                        opp.addError('Cannot move opportunity backwards in the sales process');
                    }
                }
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        // After Update - Create tasks for won opportunities
        List<Task> tasksToCreate = new List<Task>();
        
        for(Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
            
            if(opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                Task followUpTask = new Task();
                followUpTask.Subject = 'Follow up on closed opportunity: ' + opp.Name;
                followUpTask.WhatId = opp.Id;
                followUpTask.ActivityDate = Date.today().addDays(7);
                followUpTask.Priority = 'High';
                followUpTask.Status = 'Not Started';
                
                tasksToCreate.add(followUpTask);
            }
        }
        
        if(!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
} 