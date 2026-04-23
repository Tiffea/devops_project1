#connect lib - flack so the app will answer to our actions

from flask import Flask
app = Flask(__name__)

#create main page
@app.route("/")
def home():
	return "Hi Im alive and CI is working"


@app.route("/health")

def health():
	return "OK", 200

#this part I don't understand
if __name__ == "__main__":
	app.run(host="0.0.0.0", port=5000)

