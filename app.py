from prometheus_flask_exporter import PrometheusMetrics
from flask import Flask, jsonify, request, render_template
app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Хранилище задач в памяти
todos = []
counter = 1
@app.route("/")
def index():
    return render_template("index.html")

@app.route("/health")
def health():
    return "OK", 200

@app.route("/todos", methods=["GET"])
def get_todos():
    return jsonify(todos)

@app.route("/todos", methods=["POST"])
def create_todo():
    global counter
    data = request.json
    todo = {
        "id": counter,
        "title": data["title"],
        "done": False
    }
    todos.append(todo)
    counter += 1
    return jsonify(todo), 201

@app.route("/todos/<int:id>", methods=["DELETE"])
def delete_todo(id):
    global todos
    todos = [t for t in todos if t["id"] != id]
    return jsonify({"message": "Deleted"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)