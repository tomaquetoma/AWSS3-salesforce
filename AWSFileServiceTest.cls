
@isTest
public class AWSFileServiceTest {
    // public AWSFileServiceTest() {

    // }

        @isTest static void testContentType() {
            
        System.assertEquals('application/vnd.openxmlformats-officedocument.wordprocessingml.document', AWSFileService.ContentType('docx'), 'Incorrect ContentType for docx');
        System.assertEquals('application/vnd.ms-excel', AWSFileService.ContentType('csv'), 'Incorrect ContentType for csv');
        System.assertEquals('audio/wav', AWSFileService.ContentType('wav'), 'Incorrect ContentType for wav');
        System.assertEquals('video/x-ms-wmv', AWSFileService.ContentType('wmv'), 'Incorrect ContentType for wmv');
        System.assertEquals('audio/mpeg', AWSFileService.ContentType('mp3'), 'Incorrect ContentType for mp3');
        System.assertEquals('video/mp4', AWSFileService.ContentType('mp4'), 'Incorrect ContentType for mp4');
        System.assertEquals('image/png', AWSFileService.ContentType('png'), 'Incorrect ContentType for png');
        System.assertEquals('application/pdf', AWSFileService.ContentType('pdf'), 'Incorrect ContentType for pdf');
        System.assertEquals('text/plain', AWSFileService.ContentType('txt'), 'Incorrect ContentType for txt');
        System.assertEquals('image/jpeg', AWSFileService.ContentType('jpg'), 'Incorrect ContentType for jpg');
    }


}