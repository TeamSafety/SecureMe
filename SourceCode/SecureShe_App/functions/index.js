/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.

// The Firebase Admin SDK to access Firestore.
// const {initializeApp} = require("firebase-admin/app");

// initializeApp();
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

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
      const senderSnapshot = await admin.firestore().collection('Users').doc(idFrom).get();
      const senderData = senderSnapshot.data();
      const senderName = senderData.username; 
      
      // Get information about the receiver
      const receiverSnapshot = await admin.firestore().collection('Users').doc(idTo).get();
      const receiverData = receiverSnapshot.data();
      const receiverToken = receiverData.token; // Assuming token is the field containing the receiver's FCM token

      // Construct the notification payload
      const payload = {
        notification: {
          title: `New message from ${senderName}`,
          body: contentMessage,
        },
      };

      // Send the notification to the receiver
      await admin.messaging().sendToDevice(receiverToken, payload);
      
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
