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

const { GoogleGenAI } = require('@google/genai');

// Use the API key assigned to the Firebase environment, or fallback to an environment variable.
// During deployment, the user needs to set: firebase functions:secrets:set GEMINI_API_KEY
exports.generateRecipe = functions.runWith({ secrets: ["GEMINI_API_KEY"] }).https.onCall(async (data, context) => {
  try {
    const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
    const prompt = data.prompt;
    const conversationHistory = data.conversation || [];

    if (!prompt) {
      throw new functions.https.HttpsError('invalid-argument', 'The function must be called with a "prompt" argument.');
    }

    // Convert the simplified Flutter conversation array into the format expected by the GenAI SDK
    const contents = conversationHistory.map(msg => ({
      role: msg.role === 'assistant' ? 'model' : msg.role, 
      parts: [{ text: msg.content }]
    }));

    // Add the current user prompt to contents
    contents.push({
      role: 'user',
      parts: [{ text: prompt }]
    });

    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: contents,
      config: {
        systemInstruction: "You are a professional chef. You provide clear, well-structured, and easy to follow food recipes using readily available ingredients. Format your responses in Markdown.",
        temperature: 0.7,
      }
    });

    return {
      reply: response.text,
    };

  } catch (error) {
    console.error("Gemini API Error:", error);
    throw new functions.https.HttpsError('internal', 'Failed to generate recipe from AI.', error.message);
  }
});
