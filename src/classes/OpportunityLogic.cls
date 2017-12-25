public class OpportunityLogic {

    public static void CreateElapsedRevenue(List<Opportunity__c> opList){
        System.debug('@@@ CreateElapsedRevenue()');
        Set<Id> opIdSet = new Set<Id>();
        for(Opportunity__c op :opList){
            opIdSet.add(op.Id);
        }
        List<OpportunityProrate__c> opProrateWithElapsedRevenuesList = [SELECT Id, SplitTimes__c, Opportunity__c, (SELECT Id FROM ElapsedRevenues__r) FROM OpportunityProrate__c  WHERE Opportunity__c = :opIdSet];
        Set<Id> existErIdSet = new Set<Id>();
        List<ElapsedRevenue__c> erList = new List<ElapsedRevenue__c>();
        Set<Id> cancelOpIdSet = new Set<Id>();
        for(Opportunity__c op :opList){
            if(op.Prorating__c){
                for(OpportunityProrate__c opp :opProrateWithElapsedRevenuesList){
                    if(op.Id == opp.Opportunity__c){
                        System.debug('***opp ' + opp);
                        for (Integer i=0;i<=opp.SplitTimes__c;i++) {
                            ElapsedRevenue__c er = new ElapsedRevenue__c();
                            er.OpportunityProrate__c = opp.Id;
                            er.ProgressMonth__c = i;
                            erList.add(er);
                            System.debug('***er ' + er);
                        }
                    }
                }
            }else{
                for(OpportunityProrate__c opp :opProrateWithElapsedRevenuesList){
                    if(op.Id == opp.Opportunity__c){
                        System.debug('***opp ' + opp);
                        for(ElapsedRevenue__c existEr :opp.ElapsedRevenues__r){
                            System.debug('***existEr ' + existEr);
                            existErIdSet.add(existEr.Id);
                        }
                    }
                }
                cancelOpIdSet.add(op.Id);
            }
        }
        delete [SELECT Id FROM ElapsedRevenue__c WHERE Id = :existErIdSet];
        insert erList;
        List<OpportunityLineItem__c> opliList = [SELECT Id, Opportunity__c, Product2__c FROM OpportunityLineItem__c WHERE Opportunity__c = :cancelOpIdSet];
        if(opliList.size() > 0){
            OpportunityLineItemLogic.CreateOpportunityProrate(opliList);
        }
    }

}