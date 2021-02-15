// firebase functions:config:set slack.url="webhook URL"
// firebase functions:config:set slack.channel="#channel-name"
import * as functions from "firebase-functions";
import * as request from "request";

const SLACK_URL = functions.config().slack.url;

/**
 * Post a message to slack as the bot.
 * @param {string} text Message text
 * @param {string} title Message title
 * @param {string} subtitle Message subtitile
 * @return {null} Nothing
 */
export async function postToSlack(text: string,
    title?: string,
    subtitle?: string) {
  // only send an attachment when title and subtitle are provided
  const attachments = [];
  if (title && subtitle) {
    attachments.push({
      fields: [{
        title: title,
        value: subtitle,
      }],
    });
  }

  // generate the slack message
  const message: any = {
    text: text,
    attachments: attachments,
  };

  // log and post the message to slack
  console.log("Posting the following to slack: ", message);
  console.log("Using this URL: ", SLACK_URL);
  return request.post(SLACK_URL, {json: message});
}
