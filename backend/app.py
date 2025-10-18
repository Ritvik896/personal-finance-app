from flask import Flask, request, jsonify
import psycopg2
from config import DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME

app = Flask(__name__)

def get_connection():
    return psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )

@app.route("/")
def home():
    return "Personal Finance App is running!"

@app.route("/transactions", methods=["GET"])
def list_transactions():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM transactions;")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify(rows)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/transactions", methods=["POST"])
def add_transaction():
    print("POST request received!")
    data = request.get_json()
    print("Payload:", data)
    amount = data.get("amount")
    category = data.get("category")
    t_type = data.get("type")
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO transactions (amount, category, type) VALUES (%s, %s, %s);",
            (amount, category, t_type)
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "Transaction added successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)