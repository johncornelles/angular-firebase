/**
 * Cloud Functions for Smart Waste Collection Alert System
 * 
 * Handles:
 * - Push notifications on schedule updates
 * - Topic-based messaging to zones
 */

const { onDocumentUpdated, onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

// Initialize Firebase Admin
initializeApp();

const db = getFirestore();
const messaging = getMessaging();

/**
 * Trigger when a schedule is updated
 * Sends push notification to the affected zone
 */
exports.onScheduleUpdate = onDocumentUpdated('schedules/{scheduleId}', async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();
  
  // Only notify if status changed
  if (beforeData.status === afterData.status) {
    return null;
  }
  
  const zoneId = afterData.zoneId;
  const topic = `zone_${zoneId}`;
  
  // Create notification message based on status
  let title = 'Schedule Update';
  let body = '';
  let type = 'info';
  
  switch (afterData.status) {
    case 'On Time':
      title = '✅ Collection On Schedule';
      body = `Your waste collection for ${afterData.pickupTime} is on time.`;
      type = 'info';
      break;
    case 'Delayed':
      title = '⚠️ Collection Delayed';
      body = afterData.message || `Your scheduled pickup at ${afterData.pickupTime} has been delayed.`;
      type = 'admin_alert';
      break;
    case 'Cancelled':
      title = '❌ Collection Cancelled';
      body = afterData.message || 'Today\'s waste collection has been cancelled.';
      type = 'critical';
      break;
    case 'Completed':
      title = '✓ Collection Complete';
      body = 'Waste collection for your zone has been completed.';
      type = 'system';
      break;
    default:
      title = 'Schedule Update';
      body = `Status changed to: ${afterData.status}`;
  }
  
  // Send FCM notification to topic
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      scheduleId: event.params.scheduleId,
      zoneId: zoneId,
      status: afterData.status,
      type: type,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    topic: topic,
  };
  
  try {
    await messaging.send(message);
    console.log(`Notification sent to topic: ${topic}`);
    
    // Also save notification to Firestore for in-app display
    await db.collection('notifications').add({
      title: title,
      body: body,
      type: type,
      zoneId: zoneId,
      scheduleId: event.params.scheduleId,
      createdAt: new Date(),
      isRead: false,
    });
    
    console.log('Notification saved to Firestore');
    return null;
  } catch (error) {
    console.error('Error sending notification:', error);
    return null;
  }
});

/**
 * Trigger when a new schedule is created
 * Sends notification to the affected zone
 */
exports.onScheduleCreated = onDocumentCreated('schedules/{scheduleId}', async (event) => {
  const data = event.data.data();
  const zoneId = data.zoneId;
  const topic = `zone_${zoneId}`;
  
  // Get zone name
  let zoneName = 'your zone';
  try {
    const zoneDoc = await db.collection('zones').doc(zoneId).get();
    if (zoneDoc.exists) {
      zoneName = zoneDoc.data().zoneName;
    }
  } catch (e) {
    console.log('Could not fetch zone name');
  }
  
  const title = '📅 New Schedule Added';
  const body = `A new waste collection has been scheduled for ${zoneName} on ${data.pickupTime}.`;
  
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      scheduleId: event.params.scheduleId,
      zoneId: zoneId,
      type: 'info',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    topic: topic,
  };
  
  try {
    await messaging.send(message);
    console.log(`New schedule notification sent to topic: ${topic}`);
    
    // Save to notifications collection
    await db.collection('notifications').add({
      title: title,
      body: body,
      type: 'info',
      zoneId: zoneId,
      scheduleId: event.params.scheduleId,
      createdAt: new Date(),
      isRead: false,
    });
    
    return null;
  } catch (error) {
    console.error('Error sending new schedule notification:', error);
    return null;
  }
});

/**
 * Scheduled function to send reminder notifications
 * Runs daily at 6 AM to remind residents of upcoming pickups
 */
// exports.dailyPickupReminder = onSchedule('every day 06:00', async (event) => {
//   const today = new Date();
//   today.setHours(0, 0, 0, 0);
//   const tomorrow = new Date(today);
//   tomorrow.setDate(tomorrow.getDate() + 1);
  
//   // Get all schedules for today
//   const schedules = await db.collection('schedules')
//     .where('date', '>=', today)
//     .where('date', '<', tomorrow)
//     .get();
  
//   for (const doc of schedules.docs) {
//     const data = doc.data();
//     const topic = `zone_${data.zoneId}`;
    
//     await messaging.send({
//       notification: {
//         title: '🚛 Pickup Reminder',
//         body: `Waste collection scheduled for today at ${data.pickupTime}. Please ensure bins are curbside.`,
//       },
//       topic: topic,
//     });
//   }
  
//   console.log(`Sent ${schedules.size} reminder notifications`);
// });
