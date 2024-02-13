/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
// public with sharing class AWSFileService {
//     public AWSFileService() {

//     }
// }

// public class S3FileService {
public class AWSFileService {
   
    public static string ContentType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
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
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static FileData getDocumentUsingFileId(string recordId)
    {
        List<Legacy_Document__c> files=[SELECT Id, S3ServerUrl__c,FileExtension__c,Name FROM Legacy_Document__c 
                                  where Id=:recordId];
        Legacy_Document__c file=files[0];

        System.debug('recordId '+ recordId);

        System.debug('file '+ file);
        try
        {
            string contentType=ContentType(file.FileExtension__c);

            System.debug('filename ' + file.name);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:AWS_Sign_4/'+file.Name);
            req.setMethod('GET');
            req.setHeader('Content-Type', contentType);

            System.debug('req ' + req);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            system.debug(res.getBody());
            system.debug(res.getStatusCode());


           // req.setEndpoint('callout:Amazon_S3_Test/'+file.Name);


            // System.debug('IN 1');
            // HttpRequest req = new HttpRequest();
            // req.setMethod('GET');
            // System.debug('IN 2 ');
            // //req.setEndpoint('callout:Amazon_S3_Test/'+file.Name); //AWSSignature is named credential
            // req.setEndpoint('callout:Amazon_S3_Test/'+file.Name);

            // req.setHeader('Content-Type', ContentType(file.FileExtension__c));

            // System.debug('IN 3 ' +  req);
            // Http http = new Http();
            // HTTPResponse res = http.send(req);

            // system.debug('res.getStatusCode():'+res.getBody());

            if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
            {
                FileData data=new FileData();
                data.Content= EncodingUtil.Base64Encode(res.getBodyAsBlob());
                data.ContentType=ContentType(file.FileExtension__c);
                data.FileName=file.Name;
                system.debug('data ' + data);
                return data;
            }
        }
        catch(Exception ex)
        {
            //throw new BaseException(ex);
        }
        return null;
    }
}
