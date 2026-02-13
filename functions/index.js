const functions = require('firebase-functions');
const admin = require('firebase-admin');
const vision = require('@google-cloud/vision');

admin.initializeApp();

const client = new vision.ImageAnnotatorClient();

exports.visionText = functions.https.onCall(async (data) => {
  const imageBase64 = data && data.imageBase64;
  if (!imageBase64 || typeof imageBase64 !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'imageBase64 is required.'
    );
  }

  try {
    const [result] = await client.textDetection({
      image: {
        content: imageBase64,
      },
    });

    const text =
      (result.fullTextAnnotation && result.fullTextAnnotation.text) || '';

    return {
      text,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      'Vision API failed.',
      error && error.message ? { message: error.message } : undefined
    );
  }
});
