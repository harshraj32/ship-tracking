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
    const userId = context.params.userId;
 
    const deviceIdTokens = await admin
        .firestore()
        .collection('users').doc(userId).collection('profile')
        .get();
 
    var tokens = [];
 
    for (var token of deviceIdTokens.docs) {
        tokens.push(token.data().pushToken);
    }

    var payload = {
        notification: {
            title: 'Your Truck Details',
            body:  "truck no.:"+newData.TruckNumber+ "  "+"Sr no:"+newData.sr_no+"  "+"Tyres:"+newData.Tyres,
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