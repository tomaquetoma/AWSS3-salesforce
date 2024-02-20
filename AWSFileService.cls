/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class AWSFileService {

    public static string ContentType(string fileType) {
        switch on fileType.toLowerCase() {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when 'txt' {
                return 'text/plain';
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static FileData getDocumentUsingFileId(string recordId) {

        List<Legacy_Document__c> files = [SELECT Id, Name, Document_Revision__c, FileExtension__c FROM Legacy_Document__c WHERE Id = :recordId];

        Legacy_Document__c file = files[0];

        System.debug('recordId '+ recordId);

        System.debug('file '+ file);

        try {
            string contentType = ContentType(file.FileExtension__c);

            System.debug('contentType ' + contentType);

            System.debug('file.Document_Revision__c ' + file.Document_Revision__c);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:AWS_Lyon/'+file.Document_Revision__c);
            req.setMethod('GET');
            req.setHeader('Content-Type', contentType);

            System.debug('req ' + req);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            system.debug(res.getBody());
            system.debug(res.getStatusCode());

            if (res.getStatusCode() == 200 || res.getStatusCode()==201) {
                FileData data = new FileData();
                data.Content = EncodingUtil.Base64Encode(res.getBodyAsBlob());
                data.ContentType = ContentType(file.FileExtension__c);
                data.FileName = file.Name;
                system.debug('data ' + data);

                return data;
            }
        }
        catch(Exception ex) {
            //throw new BaseException(ex);
        }

        return null;
    }


    // @future(callout=true)
    // public static void uploadToOpportunityAttachment(String legacyDocumentId) {
    //     Legacy_Document__c legacyDocument = [SELECT Id, Name, Document_Revision__c, FileExtension__c, Opportunity__c FROM Legacy_Document__c WHERE Id = :legacyDocumentId];
        
    //     if (legacyDocument != null && legacyDocument.Opportunity__c != null) {
    //         String contentType = ContentType(legacyDocument.FileExtension__c);
            
    //         HttpRequest req = new HttpRequest();
    //         req.setEndpoint('callout:AWS_Lyon/' + legacyDocument.Document_Revision__c);
    //         req.setMethod('GET');
    //         req.setHeader('Content-Type', contentType);
            
    //         Http http = new Http();
    //         HttpResponse res = http.send(req);
            
    //         if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
    //             Attachment attachment = new Attachment();
    //             attachment.Name = legacyDocument.Name;
    //             attachment.Body = res.getBodyAsBlob();
    //             attachment.ContentType = contentType;
    //             attachment.ParentId = legacyDocument.Opportunity__c;
                
    //             insert attachment;
    //         }
    //     }
    // }

    // @future(callout=true)
    // public static void uploadToOpportunityContentDocument(String legacyDocumentId) {

    //     System.debug('1');
        
    //     Legacy_Document__c legacyDocument = [SELECT Id, Name, Document_Revision__c, FileExtension__c, Opportunity__c FROM Legacy_Document__c WHERE Id = :legacyDocumentId];
    
    //     System.debug('2');

    //     if (legacyDocument != null && legacyDocument.Opportunity__c != null) {

    //         System.debug('3');

    //         String contentType = ContentType(legacyDocument.FileExtension__c);
            
    //         HttpRequest req = new HttpRequest();
    //         req.setEndpoint('callout:AWS_Lyon/' + legacyDocument.Document_Revision__c);
    //         req.setMethod('GET');
    //         req.setHeader('Content-Type', contentType);
            
    //         Http http = new Http();
    //         HttpResponse res = http.send(req);

    //         System.debug('req ' + req);
            
    //         if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {

    //             System.debug('IN');
    //             // Crear ContentVersion
    //             ContentVersion contentVersion = new ContentVersion();
    //             contentVersion.Title = legacyDocument.Name;
    //             contentVersion.PathOnClient = legacyDocument.Name;
    //             contentVersion.VersionData = res.getBodyAsBlob();
    //             contentVersion.FirstPublishLocationId = legacyDocument.Opportunity__c;
                
    //             insert contentVersion;
                
    //             // Relacionar el ContentVersion con el ContentDocument
    //             // ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
    //             // contentDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
    //             // contentDocumentLink.LinkedEntityId = legacyDocument.Opportunity__c;
    //             // contentDocumentLink.ShareType = 'V';
    //             // contentDocumentLink.Visibility = 'AllUsers';
    //             // insert contentDocumentLink;

    //             System.debug('OUT ' + contentVersion.Id);
    //         }
    //     }
    // }
}