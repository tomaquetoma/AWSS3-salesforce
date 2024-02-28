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
    public static String getSignedURL(String accessKey, String secretKey, String bucketName, String bucketRegion, String location, String file, Integer expires) {

        System.debug('START');

        Datetime currentDateTime = Datetime.now();
        String dateOnly = currentDateTime.formatGmt('yyyyMMdd');
        String req =  dateOnly + '/'+ bucketRegion +'/s3/aws4_request';
        String xAmzCredentialStr = accessKey + '/' + req;
        String xAmzDate = currentDateTime.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
        String xAmzSignedHeaders = 'host';
        String host = bucketName + '.s3.'+ bucketRegion +'.amazonaws.com';
     
        System.debug('1');

        String canonicalRequest =
                'GET\n' +
                '/' + UriEncode(file, false) + '\n' +
                UriEncode('X-Amz-Algorithm', true) + '=' + UriEncode('AWS4-HMAC-SHA256', true) + '&' +
                UriEncode('X-Amz-Credential', true) + '=' + UriEncode(xAmzCredentialStr, true) + '&' +
                UriEncode('X-Amz-Date', true) + '=' + UriEncode(xAmzDate, true) + '&' +
                UriEncode('X-Amz-Expires', true) + '=' + UriEncode(String.valueOf(expires), true) + '&' +
                UriEncode('X-Amz-SignedHeaders', true) + '=' + UriEncode(xAmzSignedHeaders, true) + '\n' +
                'host:'+host + '\n\n' +
                'host\n' +
                'UNSIGNED-PAYLOAD';

        System.debug('2');
     
        String stringToSign =
                'AWS4-HMAC-SHA256\n'+
                xAmzDate + '\n' +
                req + '\n' +
                EncodingUtil.convertToHex(
                        Crypto.generateDigest('SHA-256', Blob.valueOf(canonicalRequest))
                );
     
        System.debug('3');

        Blob dateKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(dateOnly), Blob.valueOf('AWS4' + secretKey));
        Blob dateRegionKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(bucketRegion), dateKey);
        Blob dateRegionServiceKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('s3'), dateRegionKey);
        Blob signingKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), dateRegionServiceKey);
     
        Blob signature = Crypto.generateMac('hmacSHA256', Blob.valueOf(stringToSign), signingKey);
        String signatureStr = EncodingUtil.convertToHex(signature);
     
        System.debug('END');
        
        return location + '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=' + EncodingUtil.urlEncode(xAmzCredentialStr, 'UTF-8') + '&X-Amz-Date=' + xAmzDate + '&X-Amz-Expires=' + String.valueOf(expires) +'&X-Amz-Signature=' + signatureStr + '&X-Amz-SignedHeaders=host';
    }
}