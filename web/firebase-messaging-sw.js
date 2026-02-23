// web/firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyAJbPzgyaa98sDmYoujVS-v5Nxj8b03ink",
  authDomain: "unitedareechola.firebaseapp.com",
  projectId: "unitedareechola",
  storageBucket: "unitedareechola.appspot.com",
  messagingSenderId: "1016786265689",
  appId: "1:1016786265689:web:b078345a011b94e89c7348"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background Message:', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Ensure you have an icon at this path or change it
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});