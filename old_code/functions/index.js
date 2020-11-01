const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();


exports.onCreateActivityFeedItem = functions.firestore
    .document("/users/{userId}/notifications/{notificationItem}")
    .onCreate(async (notifSnapshot, context) => {
        console.log("notification item created", notifSnapshot.data());

        // 1) Get user connected to the feed
        const userId = context.params.userId;

        //const user = await admin.firestore().doc(`users/${userId}`).get();
        await admin.firestore().collection(`users/${userId}/token`).get().then(
            snapshot => {
                snapshot.forEach(doc => {
                    const androidNotificationToken = doc.data().token;
                    const createdActivityFeedItem = notifSnapshot.data();
                    if (androidNotificationToken) {
                        sendNotification(androidNotificationToken, createdActivityFeedItem);
                    } else {
                        console.log("No token for user, cannot send notification");
                    }

                })
                return console.log("Successfully sent notification");
            }).catch(error => {
                return console.log("error", error);
            });

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;

            // 3) switch body value based off of notification type
            switch (activityFeedItem.type) {
                case 1: //comment
                    title = `${activityFeedItem.commenterFirstName} ${activityFeedItem.commenterLastName}`;
                    body = `replied: ${
                        activityFeedItem.commentContent
                        }`;
                    break;
                case 0: // like
                    title = `${activityFeedItem.likerFirstName} ${activityFeedItem.likerLastName}`
                    body = `liked your post`;
                    break;
                case 2:
                    title = `${activityFeedItem.followerFirstName} ${activityFeedItem.followerLastName}`
                    body = `started following you`;
                    break;
                default:
                    break;
            }

            // 4) Create message for push notification
            const message = {
                notification: { title: title, body: body },
                token: androidNotificationToken,
                data: { recipient: userId, click_action: 'FLUTTER_NOTIFICATION_CLICK' }
            };

            // 5) Send message with admin.messaging()
            admin
                .messaging()
                .send(message)
                .then(response => {
                    // Response is a message ID string
                    return console.log("Successfully sent message", response);
                })
                .catch(error => {
                    return console.log("Error sending message", error);
                });
        }
    });