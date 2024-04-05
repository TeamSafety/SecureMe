/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original
const functions = require('firebase-functions');
const admin = require('firebase-admin/app');

const { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');
const{getMessaging} = require('firebase-admin/messaging')
admin.initializeApp();
const db = getFirestore();
exports.sendNotification = functions.firestore
  .document('messages/{groupId1}/messages/{messageId}') // path to the messages collection!
  .onCreate(async (snap, context) => {
    try {
      console.log('New message added:', snap.id);
      
      // Get data from the new message document
      const messageData = snap.data();
      const idFrom = messageData.idFrom;
      const idTo = messageData.idTo;
      const contentMessage = messageData.content;
      
      // Get information about the sender
      const senderSnapshot = await db.collection('Users').doc(idFrom).get();
      if(!senderSnapshot.exists){
        console.log("User doesn't exists"); 
      }
      else{
        const senderData = senderSnapshot.data();

        const senderName = senderData.username; 
        const senderId = senderData.userId; 
        
        // Get information about the receiver
        const receiverSnapshot = await db.collection('Users').doc(idTo).get();
        const receiverData = receiverSnapshot.data();
        const receiverToken = receiverData.token; // Assuming token is the field containing the receiver's FCM token
        const receiverId = receiverData.userId; 

        // Construct the notification payload
        const payload = {
          notification: {
            title: `New message from ${senderName}`,
            body: contentMessage, 
          },
          data:{
            sender: senderId, 
            receiver: receiverId,
          }, 
          token: receiverToken, 
        };
        // Send the notification to the receiver
        await getMessaging().send(payload)
        .then((response) => {
          console.log("Successfully sent Message.", response);
          return;
        })
        .catch((error) => {
          console.log("Error sending message!", error);
        })
        //const response = await admin.messaging().sendToDevice(receiverToken, payload);
        functions.logger.log('Notifications have been sent and tokens cleaned up.');
        console.log('Notification sent successfully');
      }
    } 
     catch (error) {
        console.error('Error sending notification:', error);
      }

  });
