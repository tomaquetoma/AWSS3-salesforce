import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import AWSSDK from '@salesforce/resourceUrl/AWSSDK';
import { getRecord } from 'lightning/uiRecordApi';
import LegacyDocumentName from "@salesforce/schema/Legacy_Document__c.Name";
import LegacyDocumentRevision from "@salesforce/schema/Legacy_Document__c.Document_Revision__c";
import { CloseActionScreenEvent } from 'lightning/actions';

const fields = [LegacyDocumentName, LegacyDocumentRevision];

export default class s3FileDownload extends LightningElement {
    @api recordId;
    fileName;
    key;
    legacyDocument;

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredRecord(result) {
        this.legacyDocument = result;
    }    

    connectedCallback() {

        if (!window.AWS) {
            // console.log("LOADINGGG AWS SDK");
            loadScript(this, AWSSDK)
                .then(() => {
                    // console.log("AWS SDK loaded");
                    this.downloadFile();
                    this.closeQuickAction();                  
                })
                .catch(error => {
                    console.error("Error loading AWS SDK: ", error);
                });
        } 
        else {
            // console.log("AWS SDK already LOADEDDDDDD");
            new Promise((resolve, reject) => {
                const interval = setInterval(() => {
                    if (this.recordId) {
                        clearInterval(interval);
                        resolve();
                    }
                }, 1000);
            })
            .then(() => {
                this.downloadFile();
                this.closeQuickAction();
            })
            .catch(error => {
                console.error("Error loading AWS SDK: ", error);
            });
        }

    }

    downloadFile() {

        if (this.legacyDocument.data) {
            this.fileName = this.legacyDocument.data.fields.Name.value;
            this.key = this.legacyDocument.data.fields.Document_Revision__c.value;

            const AWS = window.AWS;
            AWS.config.update({ accessKeyId: "AKIAQDB7BCZELX3JHESU", secretAccessKey: atob("SWJTUXYxbHZMUDIxVEh2THVIVEMxWTd4QnAxa1o3cGFLMlYrbFZxWQ==") });
            let s3 = new AWS.S3();
            let params = {
                Bucket: "s3lyon-data",
                Key: this.key,
                Expires: 3600,
                ResponseContentDisposition: `attachment; filename="${this.fileName}"`
            };
            let url = s3.getSignedUrl("getObject", params);
            //console.log(url);
            window.open(url);
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}

// https://s3lyon-data.s3.amazonaws.com/000011d0-f260-11ec-80cb-067d538c0c10?
// AWSAccessKeyId=AKIAQDB7BCZELX3JHESU&
// Expires=1709648020&
// Signature=ayb2nebqSrjGfkJQHRPyOmgGINs%3D&
// response-content-disposition=attachment%3B%20filename%3D%226MB%20file.pdf%22


// import { LightningElement,api,wire } from 'lwc';
// import getFileData from '@salesforce/apex/AWSFileService.getDocumentUsingFileId';

// export default class S3FileDownload extends LightningElement {
//     @api recordId;
    
//     @wire(getFileData, { recordId: '$recordId' })
//     wiredContent({ error, data }) {
//             if (data) {
                
//                 var blobData = "data:" + data.ContentType + ";base64," + data.Content;
           
//                 let a = document.createElement("a");
//                 a.href = blobData;
//                 a.download = data.FileName;
//                 a.click();

//             } else if (error) {
//                 this.error = error;
//                 console.log('Error:'+ JSON.stringify(error));
//             }
//     }
// }

// import { LightningElement, api, wire } from 'lwc';
// import getSignedURL from '@salesforce/apex/AWSPresignedURL.getSignedURL';



// export default class S3FileDownload extends LightningElement {

//     @api recordId;

//     signedUrl;

//     @wire(getSignedURL, { recordId: '$recordId' })
//     wiredContent({ error, data }) {
//             if (data) {
                
//                 // this.descargarConExtension(data, 'pdf');

//                 this.signedUrl = data;


//             } else if (error) {
//                 this.error = error;
//                 console.log('Error:'+ JSON.stringify(error));
//             }
//     }

//     // descargarConExtension(fileUrl, fileExtension) {
        
//     //     // var a = document.createElement('a');
//     //     // a.href = fileUrl;
        
//     //     // a.download = 'nombre_archivo.' + extension;
 
//     //     // a.style.display = 'none';

//     //     // document.body.appendChild(a);

//     //     // a.click();

//     //     // document.body.removeChild(a);

//     //     fetch(fileUrl)
//     //         .then(response => response.blob()) // Convertir la respuesta en un objeto Blob
//     //         .then(blob => {
//     //             // Crear un enlace para descargar el archivo
//     //             var url = window.URL.createObjectURL(blob);
//     //             var a = document.createElement('a');
//     //             a.href = url;
//     //             a.download = 'fileName.' + fileExtension; // Asignar el nombre del archivo con la extensión
//     //             // Simular un clic en el enlace para iniciar la descarga
//     //             document.body.appendChild(a);
//     //             a.click();
//     //             // Limpiar
//     //             window.URL.revokeObjectURL(url);
//     //             document.body.removeChild(a);
//     //         })
//     //         .catch(error => {
//     //             console.error('Error al descargar el archivo:', error);
//     //         });

//     // }
    
// }





