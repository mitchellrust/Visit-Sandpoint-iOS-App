import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
const nodemailer = require('nodemailer');

// The Firebase Admin SDK to access Firestore.
admin.initializeApp();

/**
* Here we're using Gmail to send 
*/
let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'mitchellrust@gmail.com',
        pass: 'yourgmailaccpassword'
    }
});

exports.createUser = functions.firestore
.document('support/{supportId}')
.onCreate((snap, context) => {
// Get an object representing the document
// e.g. {'name': 'Marie', 'age': 66}
const data = snap.data();

// access a particular field as you would any JS property
const name = data.name;

const mailOptions = {
    from: 'Visit Sandpoint iOS Support <mitchellrust@gmail.com>', // Something like: Jane Doe <janedoe@gmail.com>
    to: "mitchellrust@gmail.com",
    subject: 'New support ticket created', // email subject
    html: `<p style="font-size: 16px;">Pickle Riiiiiiiiiiiiiiiick!!</p>
        <br />
        <img src="https://images.prod.meredith.com/product/fc8754735c8a9b4aebb786278e7265a5/1538025388228/l/rick-and-morty-pickle-rick-sticker" />
    ` // email content in HTML
};

// returning result
return transporter.sendMail(mailOptions, (erro, info) => {
    if(erro){
        return res.send(erro.toString());
    }
    return res.send('Sended');
});  
});