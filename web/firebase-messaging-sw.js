// Firebase Messaging Service Worker
// This service worker handles background push notifications

// Import Firebase scripts for service worker
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
// The configuration will be set by the main app
let messaging = null;

try {
  // Try to initialize Firebase messaging
  messaging = firebase.messaging();
} catch (error) {
  console.log('Firebase messaging not available in service worker:', error);
}

// Handle background messages
if (messaging) {
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);
    
    const notificationTitle = payload.notification?.title || 'BED Support App';
    const notificationOptions = {
      body: payload.notification?.body || 'You have a new message',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      tag: 'bed-support-notification',
      requireInteraction: true,
      actions: [
        {
          action: 'open',
          title: 'Open App'
        },
        {
          action: 'dismiss',
          title: 'Dismiss'
        }
      ]
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
  });
}

// Handle notification click
self.addEventListener('notificationclick', function(event) {
  console.log('Notification clicked: ', event);
  
  event.notification.close();
  
  if (event.action === 'open') {
    // Open the app
    event.waitUntil(
      clients.openWindow('/')
    );
  } else if (event.action === 'dismiss') {
    // Just close the notification
    return;
  } else {
    // Default action - open the app
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// Handle notification close
self.addEventListener('notificationclose', function(event) {
  console.log('Notification closed: ', event);
});

// Fallback: Handle push messages even without Firebase messaging
self.addEventListener('push', function(event) {
  console.log('Push message received: ', event);
  
  if (event.data) {
    const data = event.data.json();
    const notificationTitle = data.notification?.title || 'BED Support App';
    const notificationOptions = {
      body: data.notification?.body || 'You have a new message',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      tag: 'bed-support-notification',
      requireInteraction: true
    };

    event.waitUntil(
      self.registration.showNotification(notificationTitle, notificationOptions)
    );
  }
});
