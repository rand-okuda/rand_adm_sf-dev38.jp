trigger OpportunityTrigger on Opportunity__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%OpportunityTrigger isAfter isUpdate');
        List<Opportunity__c> opList = new List<Opportunity__c>();
        for(Opportunity__c opNew :Trigger.New){
            for(Opportunity__c opOld :Trigger.Old){
                if(opNew.Id == opOld.Id){
                    if(opNew.Prorating__c != opOld.Prorating__c){
                        opList.add(opNew);
                        break;
                    }else{
                        break;
                    }
                }
            }
        }
        if(opList.size() > 0){
            OpportunityLogic.CreateElapsedRevenue(opList);
        }
    }

}