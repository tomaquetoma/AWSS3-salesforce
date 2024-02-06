/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class FileData
{
    @AuraEnabled
    public string Content{get;set;}
    @AuraEnabled
    public blob ContentBlob{get;set;}
    @AuraEnabled
    public string ContentType{get;set;}

    // Add For AWSFileService
    @AuraEnabled
    public string FileName{get;set;}
}       