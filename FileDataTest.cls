@isTest
public class FileDataTest {
    @isTest static void testFileData() {

        FileData fileData = new FileData();
        

        fileData.Content = 'Hello, World!';
        fileData.ContentBlob = Blob.valueOf('Hello, World!');
        fileData.ContentType = 'text/plain';
        fileData.FileName = 'testFile.txt';
        

        System.assertEquals('Hello, World!', fileData.Content);
        System.assertEquals('Hello, World!', fileData.ContentBlob.toString());
        System.assertEquals('text/plain', fileData.ContentType);
        System.assertEquals('testFile.txt', fileData.FileName);
    }
}