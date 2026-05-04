import os
from flask import Flask, jsonify, request, render_template
from prometheus_flask_exporter import PrometheusMetrics
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Подключение к базе данных
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL',
    'postgresql://postgres:password@db:5432/todos'
)
db = SQLAlchemy(app)

# Модель — описание таблицы в базе данных
class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    done = db.Column(db.Boolean, default=False)

# Создать таблицы при запуске
with app.app_context():
    db.create_all()

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/health")
def health():
    return "OK", 200

@app.route("/todos", methods=["GET"])
def get_todos():
    todos = Todo.query.all()
    return jsonify([{"id": t.id, "title": t.title, "done": t.done} for t in todos])

@app.route("/todos", methods=["POST"])
def create_todo():
    data = request.json
    todo = Todo(title=data["title"])
    db.session.add(todo)
    db.session.commit()
    return jsonify({"id": todo.id, "title": todo.title, "done": todo.done}), 201

@app.route("/todos/<int:id>", methods=["DELETE"])
def delete_todo(id):
    todo = Todo.query.get(id)
    if todo:
        db.session.delete(todo)
        db.session.commit()
    return jsonify({"message": "Deleted"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)