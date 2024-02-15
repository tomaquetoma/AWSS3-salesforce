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

        List<Legacy_Document__c> files=[SELECT Id, Name, Document_Revision__c, FileExtension__c FROM Legacy_Document__c WHERE Id = :recordId];

        Legacy_Document__c file = files[0];

        System.debug('recordId '+ recordId);

        System.debug('file '+ file);

        try {
            string contentType = ContentType(file.FileExtension__c);

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
}
