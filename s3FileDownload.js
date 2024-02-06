import { LightningElement,api,wire } from 'lwc';
import getFileData from '@salesforce/apex/AWSFileService.getDocumentUsingFileId';

export default class S3FileDownload extends LightningElement {
    @api recordId;
    
    @wire(getFileData, { recordId: '$recordId' })
    //@wire(getFileData, { recordId: 'a2SVC0000000WCn2AM' })
    wiredContent({ error, data }) {
            if (data) {
                var blobData = "data:" + data.ContentType + ";base64," + data.Content;
                
                //Download file automatically
                let a = document.createElement("a");
                a.href = blobData;
                a.download = data.FileName;
                a.click();

            } else if (error) {
                this.error = error;
                console.log('Error:'+ JSON.stringify(error));
            }
    }
}