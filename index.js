const { IncomingWebhook } = require('@slack/webhook');
const url = process.env.SLACK_WEBHOOK_URL;

const webhook = new IncomingWebhook(url);

// slackNotifier is the main function called by Cloud Functions
module.exports.slackNotifier = (pubSubEvent, context) => {
  const data = decode(pubSubEvent.data);

  // Send message to Slack.
  const message = createSlackMessage(data, pubSubEvent.attributes);
  webhook.send(message);
};

// decode decodes a pubsub event message from base64.
const decode = (data) => {
  return Buffer.from(data, 'base64').toString();
}

// createSlackMessage creates a message from a data object.
const createSlackMessage = (data, attributes) => {
  // Write the message data and attributes.
  text = `${data}`
  for (var key in attributes) {
    if (attributes.hasOwnProperty(key)) {
      text = text + `\n\t\`${key}: ${attributes[key]}\``
    }
  }
  const message = {
    text: text,
    mrkdwn: true,
  };
  return message;
}
