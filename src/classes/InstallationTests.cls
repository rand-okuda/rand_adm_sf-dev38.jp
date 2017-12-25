@isTest
private class InstallationTests {

    @testSetup
    static void setup() {
        createMasterDatas(10,5);
    }

    @isTest
    static void InstallTest010() {
        System.debug('###InstallTest010');
        //OpportunityLineItemTrigger & OpportunityLineItemLogic
        createOpportunityDatas(10, -365, 21);
        Test.startTest();
        createOpportunityLineItemDatas(99);
        Test.stopTest();
    }

    @isTest
    static void InstallTest011() {
        System.debug('###InstallTest011');
        //OpportunityLineItemTrigger & OpportunityLineItemLogic
        createOpportunityDatas(10, -365, 21);
        createOpportunityLineItemDatas(99);
        List<OpportunityLineItem__c> opliList = [SELECT Id, Product2__c FROM OpportunityLineItem__c];
        for(OpportunityLineItem__c opli : opliList){
            opli.TotalPrice__c	 = 999;
        }
        Test.startTest();
        update opliList;
        Test.stopTest();
    }

    @isTest
    static void InstallTest020() {
        System.debug('###InstallTest020');
        //OpportunityTrigger & OpportunityLogic
        createOpportunityDatas(10, -365, 21);
        createOpportunityLineItemDatas(99);
        List<Opportunity__c> opList = [SELECT Id FROM Opportunity__c];
        for(Opportunity__c op : opList){
            op.Prorating__c = true;
        }
        Test.startTest();
        update opList;
        Test.stopTest();
    }

    @isTest
    static void InstallTest021() {
        System.debug('###InstallTest021');
        //OpportunityTrigger & OpportunityLogic
        createOpportunityDatas(1, -365, 365);
        createOpportunityLineItemDatas(99);
        List<Opportunity__c> opList = [SELECT Id FROM Opportunity__c];
        for(Opportunity__c op : opList){
            op.CloseDate__c = System.today();
        }
        Test.startTest();
        update opList;
        Test.stopTest();
    }

    @isTest
    static void InstallTest022() {
        System.debug('###InstallTest022');
        //OpportunityTrigger & OpportunityLogic
        createOpportunityDatas(1, -365, 150);
        createOpportunityLineItemDatas(1);
        List<Opportunity__c> opList = [SELECT Id FROM Opportunity__c];
        opList[0].Prorating__c = true;
        update opList[0];
        opList[0].Prorating__c = false;
        Test.startTest();
        update opList[0];
        Test.stopTest();
    }

    @isTest
    static void InstallTest023() {
        System.debug('###InstallTest023');
        //OpportunityTrigger & OpportunityLogic
        createOpportunityDatas(1, -365, 150);
        createOpportunityLineItemDatas(1);
        List<Opportunity__c> opList = [SELECT Id FROM Opportunity__c];
        List<OpportunityProrate__c> oppList = [SELECT Id FROM OpportunityProrate__c];
        ElapsedRevenue__c er = new ElapsedRevenue__c();
        er.OpportunityProrate__c = oppList[0].Id;
        insert er;
        opList[0].Prorating__c = true;
        Test.startTest();
        update opList[0];
        Test.stopTest();
    }

    static void createMasterDatas(Integer numAcc, Integer numPr){
        System.debug('###createMasterDatas');
        // Setup Testing Datas

        Profile testProfile = [SELECT Id FROM Profile WHERE Name LIKE '%カスタム Platform ユーザ%']; 
        User testUser01 = new User (Alias = 'rdok3801', Email='rand.okuda+38@gmail.com', LastName='randokuda01', ProfileId = testProfile.Id, LocaleSidKey='ja_JP', LanguageLocaleKey='ja', EmailEncodingKey='ISO-2022-JP', TimeZoneSidKey='Asia/Tokyo', UserName='rand.okuda.201711131221.01@gmail.com');
        insert testUser01;
        User testUser02 = new User (Alias = 'rdok3802', Email='rand.okuda+38@gmail.com', LastName='randokuda02', ProfileId = testProfile.Id, LocaleSidKey='ja_JP', LanguageLocaleKey='ja', EmailEncodingKey='ISO-2022-JP', TimeZoneSidKey='Asia/Tokyo', UserName='rand.okuda.201711131221.02@gmail.com');
        insert testUser02;

        List<Account> accList = new List<Account>();
        for (Integer i=0;i<numAcc;i++) {
            Account acc = new Account();
            acc.Name = 'ACC-' + i;
            System.debug('###acc ' + acc);
            accList.add(acc);
        }
        insert accList;
        
        List<String> ServiceTypeList = new List<String>();
        Schema.DescribeFieldResult serviceTypeListFidldResult = Product2__c.ServiceType__c.getDescribe();
        List<Schema.PicklistEntry> serviceTypeListPicklistEntrys = serviceTypeListFidldResult.getPicklistValues();
        Integer numStp = serviceTypeListPicklistEntrys.size() - 1;
        for (Schema.PicklistEntry serviceTypeListPicklistEntry : serviceTypeListPicklistEntrys) {
            System.debug('###serviceTypeListPicklistEntry ' + serviceTypeListPicklistEntry);
            if(serviceTypeListPicklistEntry.isActive()){
                ServiceTypeList.add(String.valueOf(serviceTypeListPicklistEntry.getValue()));
            }
        }
        List<Product2__c> pdList = new List<Product2__c>();
        Integer j = 0;
        for (Integer i=0;i<numPr;i++) {
            Product2__c pd = new Product2__c();
            pd.Name = 'PD-' + i;
            pd.ServiceType__c = ServiceTypeList[j];
            pd.ServiceYears__c = 1;
            pdList.add(pd);
            System.debug('###pd ' + pd);
            if(j == numStp){
                j = 0;
            }else{
                j++;
            }
        }
        insert pdList;

        List<Prorate__c> prList = new  List<Prorate__c>();
        Integer splitEndMonthNum = 1;
        for (Product2__c pd : pdList){
            Prorate__c pr = new Prorate__c();
            if (splitEndMonthNum > 12){
                splitEndMonthNum = 1;
            }
            pr.SplitEndMonth__c = splitEndMonthNum;
            pr.SplitYears__c = 1;
            pr.Product2__c = pd.Id;
            pr.AmountRatio__c = 100;
            prList.add(pr);
            System.debug('###pr ' + pr);
            splitEndMonthNum ++;
        }
        insert prList;

    }

    static void createOpportunityDatas(Integer numOpp, Integer numDay, Integer numSpan){
        System.debug('###createOpportunityDatas');
        // Setup Testing Datas

        List<Account> aList = [SELECT Id FROM Account];
        List<User> uList = [SELECT Id, Region__c FROM User WHERE Region__c != null];
        List<Opportunity__c> opList = new List<Opportunity__c>();
        for(Account a :aList){
            if(numOpp == 0){
                break;
            }
            for (Integer i=0;i<=2;i++) {
                if(numOpp == 0){
                    break;
                }
                for(User u :uList){
                    Opportunity__c op = new Opportunity__c();
                    op.Account__c = a.Id;
                    op.SalesPerson__c = u.Id;
                    op.Attribute__c = '3';
                    op.CloseDate__c = System.today().addDays(numDay);
                    opList.add(op);
                    System.debug('###op ' + op);
                    numDay = numDay + numSpan;
                    numOpp -= 1;
                    if(numOpp == 0){
                        break;
                    }
                }
            }
        }
        insert opList;

    }

    static void createOpportunityLineItemDatas(Integer numSp){
        System.debug('###createOpportunityLineItemDatas');
        // Setup Testing Datas

        List<Opportunity__c> opList = [SELECT Id FROM Opportunity__c];
        List<Product2__c> pdList = [SELECT Id FROM Product2__c];
        List<OpportunityLineItem__c> opliList = new List<OpportunityLineItem__c>();
        Integer numPd = 0;
        for(Opportunity__c op :opList){
            for (Integer i=0;i<=1;i++) {
                OpportunityLineItem__c opli = new OpportunityLineItem__c();
                opli.Product2__c = pdList[numPd].Id;
                opli.Opportunity__c = op.Id;
                if(opliList.size() <= numSp){
                    opliList.add(opli);
                    System.debug('###opli ' + opli);
                }
                if(numPd == pdList.size()-1){
                    numPd = 0;
                }else{
                    numPd ++;
                }
            }
        }
        insert opliList;

    }

}