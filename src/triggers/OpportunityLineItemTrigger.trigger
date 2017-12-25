trigger OpportunityLineItemTrigger on OpportunityLineItem__c (after insert, after update) {

    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('%%%OpportunityLineItemTrigger isAfter isInsert');
        List<OpportunityLineItem__c> opliList = new List<OpportunityLineItem__c>();
        for(OpportunityLineItem__c opliL :Trigger.New){
            opliList.add(opliL);
        }
        if(opliList.size() > 0){
            OpportunityLineItemLogic.CreateOpportunityProrate(opliList);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%OpportunityLineItemTrigger isAfter isUpdate');
        List<OpportunityLineItem__c> opliList = new List<OpportunityLineItem__c>();
        for(OpportunityLineItem__c opliLNew :Trigger.New){
            for(OpportunityLineItem__c opliLOld :Trigger.Old){
                if(opliLNew.Id == opliLOld.Id){
                    if(opliLOld.TotalPrice__c != null && opliLNew.TotalPrice__c != opliLOld.TotalPrice__c || opliLNew.Product2__c != opliLOld.Product2__c){
                        opliList.add(opliLNew);
                    }
                }
            }
        }
        if(opliList.size() > 0){
            OpportunityLineItemLogic.CreateOpportunityProrate(opliList);
        }
    }

}