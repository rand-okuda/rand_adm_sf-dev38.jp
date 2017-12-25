<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DunningMailAlert</fullName>
        <description>督促社内メールアラート</description>
        <protected>false</protected>
        <recipients>
            <field>SalesPersonMail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ProratedSalesManagement/EmailTemplate20171018a</template>
    </alerts>
</Workflow>
