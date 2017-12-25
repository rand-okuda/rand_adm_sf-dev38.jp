public class OpportunityLineItemLogic {

    public static void CreateOpportunityProrate(List<OpportunityLineItem__c> opliList){
        System.debug('@@@ CreateOpportunityProrate()');
        Set<Id> pdIdSet = new Set<Id>();
        for(OpportunityLineItem__c opliL :opliList){
            pdIdSet.add(opliL.Product2__c);
        }
        Set<Id> opliIdSet = new Set<Id>();
        for(OpportunityLineItem__c opli :opliList){
            opliIdSet.add(opli.Id);
        }
        Set<Id> existOppIdSet = new Set<Id>();
        for(OpportunityProrate__c opp : [SELECT Id, OpportunityLineItem__c FROM OpportunityProrate__c WHERE OpportunityLineItem__c = :opliIdSet]){
            existOppIdSet.add(opp.Id);
        }
        List<Product2__c> pdListWithProrate = [SELECT Id, (SELECT Id FROM Prorates__r) FROM Product2__c WHERE Id = :pdIdSet];
        List<OpportunityProrate__c> opPrList = new List<OpportunityProrate__c>();
        for(OpportunityLineItem__c opli :opliList){
            for(Product2__c pd :pdListWithProrate){
                if(opli.Product2__c == pd.Id){
                    for(Prorate__c pr :pd.Prorates__r){
                        OpportunityProrate__c opPr = new OpportunityProrate__c();
                        opPr.Opportunity__c = opli.Opportunity__c;
                        opPr.Prorate__c = pr.Id;
                        opPr.OpportunityLineItem__c = opli.Id;
                        opPrList.add(opPr);
                        System.debug('***opPr ' + opPr);
                    }
                    break;
                }
            }
        }
        delete [SELECT Id FROM OpportunityProrate__c WHERE Id = :existOppIdSet];
        insert opPrList;
    }

}