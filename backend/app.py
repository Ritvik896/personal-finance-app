from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import SQLALCHEMY_DATABASE_URI
from datetime import datetime

# Initialize Flask app
app = Flask(__name__)

# Configure the database connection from config.py
app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Disable overhead warning

# Initialize SQLAlchemy
db = SQLAlchemy(app)

# Define Transaction model
class Transaction(db.Model):
    __tablename__ = 'transactions'

    id = db.Column(db.Integer, primary_key=True)
    description = db.Column(db.String(200), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(100), nullable=False)
    date = db.Column(db.Date, nullable=False, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "description": self.description,
            "amount": self.amount,
            "category": self.category,
            "date": self.date.strftime("%Y-%m-%d")
        }

# Routes
@app.route('/')
def home():
    return jsonify({"message": "Personal Finance Tracker API is running!"})

@app.route('/transactions', methods=['GET'])
def get_transactions():
    transactions = Transaction.query.all()
    return jsonify([t.to_dict() for t in transactions])

@app.route('/transactions', methods=['POST'])
def add_transaction():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No input data provided"}), 400

    new_txn = Transaction(
        description=data.get("description"),
        amount=data.get("amount"),
        category=data.get("category"),
        date=datetime.strptime(data.get("date"), "%Y-%m-%d")
    )
    db.session.add(new_txn)
    db.session.commit()
    return jsonify({"message": "Transaction added successfully"}), 201


# Run Flask app
if __name__ == '__main__':
    # Ensure tables are created before starting
    with app.app_context():
        db.create_all()

    app.run(host='0.0.0.0', port=5000)
