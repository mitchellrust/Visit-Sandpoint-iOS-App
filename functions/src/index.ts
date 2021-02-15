import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {postToSlack} from "./slack";
admin.initializeApp();
const db = admin.firestore(functions.config().firebase);


// New user created
exports.createUser = functions.firestore
    .document("users/{userId}")
    .onCreate((snap, _) => {
      const user = snap.data();
      return postToSlack("New user just signed up!",
          `${user.firstName} ${user.lastName}`,
          user.email);
    });

// New support/business request
exports.newSupport = functions.firestore
    .document("support/{supportId}")
    .onCreate(async (snap, context) => {
      const supportId = snap.id;
      const {userId, message} = snap.data() as any;
      let fromField = "From Anonymous";
      if (userId && userId != "") {
        const userRef = db.collection("users").doc(userId);
        const {id, firstName, lastName} = (await userRef.get()).data() as any;
        fromField = `From ${firstName} ${lastName} (${id})`;
      }
      return postToSlack(`New support ticket (${supportId})`,
          fromField,
          message);
    });
