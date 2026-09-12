import os

os.environ["DATABASE_URL"] = "sqlite:///test.db"

import pytest  # noqa: E402

from app import app, db  # noqa: E402


@pytest.fixture
def client():
    app.config["TESTING"] = True

    with app.app_context():
        db.drop_all()
        db.create_all()

    with app.test_client() as test_client:
        yield test_client

    with app.app_context():
        db.session.remove()
        db.drop_all()


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.data == b"OK"


def test_index_page_loads(client):
    response = client.get("/")
    assert response.status_code == 200


def test_get_todos_empty_list(client):
    response = client.get("/todos")
    assert response.status_code == 200
    assert response.get_json() == []


def test_create_todo(client):
    response = client.post("/todos", json={"title": "Buy milk"})
    assert response.status_code == 201

    data = response.get_json()
    assert data["title"] == "Buy milk"
    assert data["done"] is False
    assert "id" in data


def test_created_todo_appears_in_list(client):
    client.post("/todos", json={"title": "Task 1"})

    response = client.get("/todos")
    todos = response.get_json()

    assert len(todos) == 1
    assert todos[0]["title"] == "Task 1"


def test_delete_todo(client):
    create_response = client.post("/todos", json={"title": "Temp task"})
    todo_id = create_response.get_json()["id"]

    delete_response = client.delete(f"/todos/{todo_id}")
    assert delete_response.status_code == 200

    todos_after = client.get("/todos").get_json()
    assert todos_after == []


def test_delete_nonexistent_todo_does_not_error(client):
    response = client.delete("/todos/9999")
    assert response.status_code == 200