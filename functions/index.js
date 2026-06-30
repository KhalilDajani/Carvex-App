// Carvex — Cloud Functions (Firebase Functions v2)
//
// Delivers real cross-device push notifications. The Flutter app only writes
// Firestore documents; a client cannot securely push to another device's FCM
// token, so these functions do the fan-out using the Admin SDK.
//
// Deploy:
//   cd functions && npm install && cd ..
//   firebase deploy --only functions

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Collect FCM tokens for a notification's target.
//  - targetUserId set            -> that single user
//  - targetRole "all"            -> every user
//  - targetRole "buyer"/"seller" -> users with that role
async function tokensForTarget(targetUserId, targetRole) {
  const tokens = [];

  if (targetUserId) {
    const snap = await db.collection("users").doc(targetUserId).get();
    const t = snap.get("fcmToken");
    if (t) tokens.push(t);
    return tokens;
  }

  let query = db.collection("users");
  if (targetRole && targetRole !== "all") {
    query = query.where("role", "==", targetRole);
  }
  const snap = await query.get();
  snap.forEach((d) => {
    const t = d.get("fcmToken");
    if (t) tokens.push(t);
  });
  return tokens;
}

// Push for every notification document the app writes
// (car approval broadcast, "listing approved" to the seller, admin broadcasts,
// rejection notice).
exports.onNotificationCreated = onDocumentCreated(
  "notifications/{id}",
  async (event) => {
    const data = event.data && event.data.data();
    if (!data) return;

    const tokens = await tokensForTarget(
      data.targetUserId || "",
      data.targetRole || ""
    );
    if (!tokens.length) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title: data.title, body: data.message },
      data: { type: String(data.type || "admin_broadcast") },
    });
  }
);

// Push to the *other* participant for each new chat message.
// NOTE: the in-app notification document is created by the app itself
// (ChatService.sendMessage), so this function ONLY sends the FCM push to
// avoid duplicate entries on the Notifications screen.
exports.onChatMessage = onDocumentCreated(
  "chats/{chatId}/messages/{msgId}",
  async (event) => {
    const msg = event.data && event.data.data();
    if (!msg) return;

    const chatSnap = await db.collection("chats").doc(event.params.chatId).get();
    const chat = chatSnap.data();
    if (!chat) return;

    const recipientId = (chat.participants || []).find((p) => p !== msg.senderId);
    if (!recipientId) return;

    const senderName =
      recipientId === chat.buyerId ? chat.sellerName : chat.buyerName;

    // Push to the recipient's device.
    const userSnap = await db.collection("users").doc(recipientId).get();
    const token = userSnap.get("fcmToken");
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: { title: senderName || "New message", body: msg.text },
      data: { type: "chat", chatId: event.params.chatId },
    });
  }
);
