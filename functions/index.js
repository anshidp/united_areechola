const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationToAll = functions.https.onRequest(async (req, res) => {
  try {
    const {title, body} = req.body;

    if (!title || !body) {
      return res.status(400).send("Missing title or body");
    }

    
    const usersSnapshot = await admin.firestore().collection("Members").get();
    const tokens = [];

    usersSnapshot.forEach((doc) => {
      const token = doc.data().token;
      if (token) tokens.push(token);
    });

    if (tokens.length === 0) {
      return res.status(404).send("No tokens found");
    }

   
    const message = {
      notification: {title, body},
      tokens: tokens,
    };

    
    const response = await admin.messaging().sendMulticast(message);

    return res.status(200).send({
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  } catch (error) {
    console.error("Error sending notification:", error);
    res.status(500).send("Internal Server Error");
  }
});

