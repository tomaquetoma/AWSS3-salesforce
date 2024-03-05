public with sharing class AWSPresignedURL {

    public static String UriEncode(String input, Boolean encodeSlash) {
        String result = '';
    
        for (Integer i = 0; i < input.length(); i++) {
            String ch = input.substring(i, i + 1);
    
            if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a'
               && ch <= 'z') || (ch >= '0' && ch <= '9') || ch == '_' ||
               ch == '-' || ch == '~' || ch == '.') {
               result += ch;
            } else if (ch == '/') {
               result += encodeSlash ? '%2F' : ch;
            } else {
                String hexValue = EncodingUtil.convertToHex(Blob.valueOf(ch)).toUpperCase();
    
                if (hexValue.length() == 2) {
                    result += '%' + hexValue;
                } else if (hexValue.length() == 4) {
                    result += '%' + hexValue.substring(0, 2) + '%' + hexValue.substring(2);
                }
    
            }
        }
    
       return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getSignedURL(  string recordId) {

        System.debug('START ' + recordId);

        List<Legacy_Document__c> files = [SELECT Id, Name, Document_Revision__c, FileExtension__c FROM Legacy_Document__c WHERE Id = :recordId];

        Legacy_Document__c file = files[0];

        System.debug(file);
        System.debug(file.Document_Revision__c);

        

        Datetime currentDateTime = Datetime.now();
        String dateOnly = currentDateTime.formatGmt('yyyyMMdd');
        String req =  dateOnly + '/us-east-1/s3/aws4_request';
        String xAmzCredentialStr = 'AKIAQDB7BCZEOUZI6AOO/' + req;
        String xAmzDate = currentDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
        String xAmzSignedHeaders = 'host';
        String host = 's3lyon-data.s3.us-east-1.amazonaws.com';

        String contentDisposition = UriEncode('response-content-disposition', true) + '=' + UriEncode('attachment; filename="newfile.ext2"', true);
        
     
        System.debug('1');

        String canonicalRequest =
                'GET\n' +
                '/' + UriEncode(file.Document_Revision__c, false) +'?response-content-disposition=attachment;filename="test.pdf'+'\n' +

                //UriEncode('content-disposition', false) + '=' + UriEncode('attachment; filename="newfile.pdf"', false) + '&' +

                // '/' + UriEncode(file.Document_Revision__c, false) +'\n' +
                
                // 'x-amz-meta-filename*=UTF-8\'' + file.Name + '\n' +
                // UriEncode('response-content-disposition', true) + '=' + UriEncode('attachment; filename="' + file.Name + '"', true) + '&' +
                
                //'/' + 'x-amz-fwd-header-Content-Disposition=' + UriEncode('attachment;filename="test.pdf"', true) + '\n' +

        
                // canonical_querystring += '&response-content-disposition=' + quote('attachment; filename=\"' + document_name + '\"; filename*=UTF-8\'\'' + document_name, safe='')
                // canonical_querystring += '&response-content-type=' + quote(document_type, safe='')


                //UriEncode('response-content-disposition', false) + '=' + UriEncode('attachment; filename="newfile.ext2"', false) + '&' +
                // UriEncode('response-content-type', true) + '=' + UriEncode('application/pdf', true) + '&' +
                //'response-content-type=application/pdf&' +



                UriEncode('X-Amz-Algorithm', true) + '=' + UriEncode('AWS4-HMAC-SHA256', true) + '&' +
                UriEncode('X-Amz-Credential', true) + '=' + UriEncode(xAmzCredentialStr, true) + '&' +
                //UriEncode('x-amz-fwd-header-Content-Disposition', true) + '=' + UriEncode('attachment;filename="test.pdf', true) + '&' +
                UriEncode('X-Amz-Date', true) + '=' + UriEncode(xAmzDate, true) + '&' +
                UriEncode('X-Amz-Expires', true) + '=' + UriEncode(String.valueOf(3600), true) + '&' +
                UriEncode('X-Amz-SignedHeaders', true) + '=' + UriEncode(xAmzSignedHeaders, true) + '\n' +

                //'content-disposition: attachment; filename="newfile.pdf"'+ '\n' +
                //'content-type: application/pdf'+ '\n' +

                
       
                //UriEncode('x-amz-fwd-header-Content-Disposition', true) + '=' + UriEncode('attachment;filename="test.pdf', true) + '&' +

                'host:'+host + '\n\n' +
                // 'response-content-disposition:test.pdf' + '\n\n' +
                'host\n' +
                'UNSIGNED-PAYLOAD';

        System.debug('2 ' + canonicalRequest);
     
        String stringToSign =
                'AWS4-HMAC-SHA256\n'+
                xAmzDate + '\n' +
                req + '\n' +
                EncodingUtil.convertToHex(
                        Crypto.generateDigest('SHA-256', Blob.valueOf(canonicalRequest))
                );
     
        System.debug('3 '+ stringToSign);

        Blob dateKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(dateOnly), Blob.valueOf('AWS4c06TzEV+nVEt870GWrTkJbzzqV4dBthJOLKXTCUr'));
        System.debug('4 '+ dateKey);
        Blob dateRegionKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('us-east-1'), dateKey);
        System.debug('5 '+ dateRegionKey);
        Blob dateRegionServiceKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('s3'), dateRegionKey);
        System.debug('6 '+ dateRegionServiceKey);
        Blob signingKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), dateRegionServiceKey);
        System.debug('6 '+ dateRegionServiceKey);
     
        Blob signature = Crypto.generateMac('hmacSHA256', Blob.valueOf(stringToSign), signingKey);
        String signatureStr = EncodingUtil.convertToHex(signature);
     
        System.debug('END');
        

        String signedUrl = 'https://s3lyon-data.s3.us-east-1.amazonaws.com/' +file.Document_Revision__c+ '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=' + EncodingUtil.urlEncode(xAmzCredentialStr, 'UTF-8') + '&X-Amz-Date=' + xAmzDate + '&X-Amz-Expires=' + String.valueOf(3600) +'&X-Amz-Signature=' + signatureStr + '&X-Amz-SignedHeaders=host';

        // signedUrl += '&response-content-disposition='+ EncodingUtil.urlEncode('attachment; filename="newfile.ext2"', 'UTF-8');
        // signedUrl += '&response-content-type='+ EncodingUtil.urlEncode('application/pdf', 'UTF-8');
                
        return signedUrl;

        //VALID 1614

        //return 'https://s3lyon-data.s3.us-east-1.amazonaws.com/' +file.Document_Revision__c+ '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=' + EncodingUtil.urlEncode(xAmzCredentialStr, 'UTF-8') + '&X-Amz-Date=' + xAmzDate + '&X-Amz-Expires=' + String.valueOf(30) +'&X-Amz-Signature=' + signatureStr + '&X-Amz-SignedHeaders=host';

    }    
}