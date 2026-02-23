const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

admin.initializeApp();


exports.sendSubcriptionNotification=onDocumentCreated("/notification/{documentId}", async (event)=>{
      
      const messageData = event.data.data();
      const usersSnapshot = await admin.firestore().collection("Members").get();
      const usertokens = [];
      usersSnapshot.forEach((doc) => {
        const token = doc.data().token;
        console.log("tokens",token)
        if (token) usertokens.push(token);
      });    
      console.log("messagedata",messageData)  
      const payload = {
        notification: {
          title: messageData.title,
          body: messageData.body,
        },
        data: {
          "title": messageData.title,
          "body": messageData.body,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "sound": "default",
          "status": "done",
        },
        tokens: usertokens,
      };
      try {
        const response = await
        admin.messaging().sendEachForMulticast(payload);
        console.log("Notification sent to device:");
        
        return response;
      } catch (er) {
        console.log("================error================");
        
      }
    });
