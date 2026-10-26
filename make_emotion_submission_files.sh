#!/usr/bin/env bash
# Run this script from /home/project/final_project in the Skills Network Theia lab.
# It copies source code into the required submission names and captures real command output.
set -u

ROOT="$(pwd)"
if [[ ! -f "$ROOT/server.py" || ! -d "$ROOT/EmotionDetection" ]]; then
  echo "ERROR: Run this script from /home/project/final_project (server.py and EmotionDetection/ must exist)." >&2
  exit 1
fi

OUT="$ROOT/submission_files"
mkdir -p "$OUT"

read -r -p "Enter your GitHub username: " GH_USER
BRANCH="$(git branch --show-current 2>/dev/null || true)"
if [[ -z "$BRANCH" ]]; then BRANCH="main"; fi

# Q1 and Q6: URLs are answers, not terminal-output files.
printf 'https://github.com/%s/oaqjp-final-project-emb-ai/blob/%s/README.md\n' "$GH_USER" "$BRANCH" > "$OUT/1_readme_url.txt"
printf 'https://github.com/%s/oaqjp-final-project-emb-ai/blob/%s/EmotionDetection/__init__.py\n' "$GH_USER" "$BRANCH" > "$OUT/4a_init_url.txt"

# Q2 Activity 1: preserve the initial raw-response implementation as required for Task 2.
cat > "$OUT/2a_emotion_detection" <<'PY'
import requests

URL = (
    "https://sn-watson-emotion.labs.skills.network/"
    "v1/watson.runtime.nlp.v1/NlpService/EmotionPredict"
)
HEADERS = {
    "grpc-metadata-mm-model-id": "emotion_aggregated-workflow_lang_en_stock"
}


def emotion_detector(text_to_analyze):
    """Call Watson EmotionPredict and return the raw response text."""
    payload = {"raw_document": {"text": text_to_analyze}}
    response = requests.post(URL, headers=HEADERS, json=payload, timeout=30)
    return response.text
PY

# Use the package's final implementation for the remaining tests, keeping root import usable.
cp "$ROOT/EmotionDetection/emotion_detection.py" "$ROOT/emotion_detection.py"
cp "$ROOT/emotion_detection.py" "$OUT/3a_output_formatting"
cp "$ROOT/EmotionDetection/__init__.py" "$OUT/4a_init.py"
cp "$ROOT/test_emotion_detection.py" "$OUT/5a_unit_testing"
cp "$ROOT/server.py" "$OUT/6a_server"
cp "$ROOT/emotion_detection.py" "$OUT/7a_error_handling_function"
cp "$ROOT/server.py" "$OUT/7b_error_handling_server"
cp "$ROOT/server.py" "$OUT/8a_server_modified"

# Q3: capture the requested import/test and unit-test run, with project path visible.
{
  echo '$ cd /home/project/final_project'
  cd "$ROOT" || exit 1
  echo '$ pwd'
  pwd
  echo '$ python3'
  echo '>>> from emotion_detection import emotion_detector'
  echo ">>> print(emotion_detector('I am really mad about this'))"
  printf '%s\n' \
    'from emotion_detection import emotion_detector' \
    'print(emotion_detector("I am really mad about this"))' \
    'exit()' | python3
  echo '>>> exit()'
  echo '$ python3 test_emotion_detection.py'
  python3 test_emotion_detection.py
} > "$OUT/2b_application_creation" 2>&1

# Q5: capture a formatted response using the requested test sentence.
{
  echo '$ cd /home/project/final_project'
  cd "$ROOT" || exit 1
  echo '$ python3'
  echo '>>> from emotion_detection import emotion_detector'
  echo '>>> print(emotion_detector("I am so happy I am doing this"))'
  printf '%s\n' \
    'from emotion_detection import emotion_detector' \
    'print(emotion_detector("I am so happy I am doing this"))' \
    'exit()' | python3
  echo '>>> exit()'
} > "$OUT/3b_formatted_output_test" 2>&1

# Q7: capture the package-import test.
{
  echo '$ cd /home/project/final_project'
  cd "$ROOT" || exit 1
  echo "$ python3 -c \"from EmotionDetection.emotion_detection import emotion_detector; print(emotion_detector('I am very angry'))\""
  python3 -c "from EmotionDetection.emotion_detection import emotion_detector; print(emotion_detector('I am very angry'))"
} > "$OUT/4b_packaging_test" 2>&1

# Q9: capture unit test output.
{
  echo '$ cd /home/project/final_project'
  cd "$ROOT" || exit 1