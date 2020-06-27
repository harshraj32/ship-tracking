const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().functions);

const db = admin.firestore();
const fcm = admin.messaging();

var newData;
 
exports.sendNotification = functions.firestore.document('users/{userId}/orders/{orderId}').onUpdate(async (snapshot, context) => {
   
 
    if (snapshot.empty) {
        console.log('No Devices');
        return;
    }
 
    newData = snapshot.after.data();
 
    const deviceIdTokens = await admin
        .firestore()
        .collection('users/{userId}/profile')
        .get();
 
    var tokens = ['feXhTOQcLjk:APA91bEaOGPJ27WPAlqknWXg-OxDzTn7qtwNhb_E-hb5SJn9E0a5-xyPQaFKC5qrF-PZtajEHXZnfkRx8MKfSUUSQsjyyZB4u_TtTc8iQDxP8rRsn7pLkknfF2SQZTUmP8dsX5wXh-1D'];
 
    // for (var token of deviceIdTokens.docs) {
    //     tokens.push(token.data().pushToken);
    // }
    var payload = {
        notification: {
            title: 'Your SR Number',
            body: newData.Tyres,
            sound: 'default',
        },
        data: {
            push_key: 'Push Key Value',
            key1: 'key value',
        },
    };
 
    try {
        const response = await admin.messaging().sendToDevice(tokens, payload);
        console.log('Notification sent successfully');
    } catch (err) {
        console.log(err);
    }
});