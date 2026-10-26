import requests
import json


def emotion_detector(text_to_analyze):
    """
    Analyze text using the Watson NLP EmotionPredict API
    and return the five emotion scores and dominant emotion.
    """

    url = (
        "https://sn-watson-emotion.labs.skills.network/"
        "v1/watson.runtime.nlp.v1/NlpService/EmotionPredict"
    )

    headers = {
        "grpc-metadata-mm-model-id":
            "emotion_aggregated-workflow_lang_en_stock"
    }

    input_json = {
        "raw_document": {
            "text": text_to_analyze
        }
    }

    response = requests.post(
        url,
        headers=headers,
        json=input_json
    )

    # Convert the response text into a Python dictionary.
    formatted_response = json.loads(response.text)

    # Extract the emotion scores.
    emotions = formatted_response[
        "emotionPredictions"
    ][0]["emotion"]

    anger_score = emotions["anger"]
    disgust_score = emotions["disgust"]
    fear_score = emotions["fear"]
    joy_score = emotions["joy"]
    sadness_score = emotions["sadness"]

    # Identify the emotion with the highest score.
    dominant_emotion = max(emotions, key=emotions.get)

    # Return the required output format.
    return {
        "anger": anger_score,
        "disgust": disgust_score,
        "fear": fear_score,
        "joy": joy_score,
        "sadness": sadness_score,
        "dominant_emotion": dominant_emotion
    }