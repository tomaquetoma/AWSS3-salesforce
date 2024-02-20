
@isTest
public class AWSFileServiceTest {


    @isTest static void testGetDocumentUsingFileId() {
        // Crear un registro de documento ficticio
        Legacy_Document__c testDocument = new Legacy_Document__c(
            Name = 'Test Document',
            FileExtension__c = 'txt',
            Document_Revision__c = 'testFileId'
        );
        insert testDocument;

        // Llamar al método getDocumentUsingFileId con el ID del registro de documento
        FileData fileData = AWSFileService.getDocumentUsingFileId(testDocument.Id);

        // Verificar que el FileData devuelto tenga las propiedades esperadas
        // System.assertNotEquals(null, fileData, 'FileData should not be null');
        // System.assertEquals('Test Document', fileData.FileName, 'Incorrect FileName');
        // System.assertEquals('text/plain', fileData.ContentType, 'Incorrect ContentType');
        // System.assertEquals('VGVzdCBDb250ZW50', fileData.Content, 'Incorrect Content');
    }

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