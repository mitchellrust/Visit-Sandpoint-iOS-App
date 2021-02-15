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
      const support = snap.data() as any;
      let title = `New Support Ticket (${supportId})`;
      let message = support.message;
      let fromField = "From Anonymous";
      if (support.userId && support.userId != "") {
        const userRef = db.collection("users").doc(support.userId);
        const {id, firstName, lastName} = (await userRef.get()).data() as any;
        fromField = `From ${firstName} ${lastName} (${id})`;
      }
      if (message == "business_request") {
        title = `New Business Request (${supportId})`;
        message = `Business Name: ${support.businessName}
        Website: ${support.businessURL}
        Requested By Owner: ${support.requestedByOwner}`;
        if (support.requestedByOwner) {
          message += `\nOwner Email: ${support.ownerEmail}`;
        }
      }
      return postToSlack(title, fromField, message);
    });
