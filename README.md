# Personal Finance Web Application

This is a Flask-based Personal Finance Tracking Web Application. Users can register/login, add daily income and expenses, categorize transactions, and view summaries.

---

## ✅ Features Completed So Far

- Flask backend APIs for:
  - Adding transactions (`POST /transactions`)
  - Listing transactions (`GET /transactions`)
- PostgreSQL integration (RDS on AWS)
- Dockerized backend for containerized development
- `.env` and `config.py` used for environment-specific configuration
- Project structured for future CI/CD and Terraform automation

---

## 📁 Project Directory Structure

personal-finance-app/
│
├── backend/
│ ├── app.py
│ ├── config.py
│ ├── requirements.txt
│ ├── wait-for-postgres.sh
│
├── .env
├── docker-compose.yml
├── Dockerfile
├── README.md


**Notes:**
- `requirements.txt` is in `backend/` as all Python code is inside that folder.
- `Dockerfile` and `docker-compose.yml` are in root for easier container orchestration.

---

## ⚙️ Environment Variables (`.env`)

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=#Rks2751
POSTGRES_DB=postgres
POSTGRES_HOST=personalfinance-db.cluster-xxxxxx.ap-south-1.rds.amazonaws.com
POSTGRES_PORT=5432
FLASK_ENV=development
These are loaded in config.py using python-dotenv.

🐳 Docker Setup

Dockerfile (root):

Builds backend container

Installs Python dependencies

Waits for Postgres to be ready using wait-for-postgres.sh

docker-compose.yml (root):

backend service depends on postgres service

Environment variables are injected via .env

Port mapping: 5000:5000 for Flask, 5432:5432 for Postgres (if running locally)



🛠 Local Testing

Ensure .env is updated with RDS endpoint

Run:

cd backend
docker-compose up --build


Access API at:

http://localhost:5000/

✅ Completed Steps So Far

Created Flask backend with PostgreSQL integration.

Dockerized backend and Postgres (for local testing).

Created .env and config.py to manage environment variables.

Created transactions table in RDS.

Verified Dockerized Flask app can connect to RDS with credentials from .env.

Added wait-for-postgres.sh for smooth container startup.

🛠 Next Steps (Phase 3 – AWS & Terraform)

Modify Terraform scripts to create RDS and EC2 (already partially done).

Test Flask app connecting to AWS RDS.

Add outputs to Terraform for RDS endpoint.

Prepare for deployment on EC2.

---------------------------------------------

# Quick Start – Personal Finance App

## 1️⃣ Clone Repository

```bash
git clone <your-repo-url>
cd personal-finance-app
git checkout phase3
3️⃣ Configure Environment Variables

Create .env in root with your AWS RDS credentials:

POSTGRES_USER=postgres
POSTGRES_PASSWORD=#Rks2751
POSTGRES_DB=postgres
POSTGRES_HOST=personalfinance-db.cluster-xxxxxx.ap-south-1.rds.amazonaws.com
POSTGRES_PORT=5432
FLASK_ENV=development


config.py automatically loads these variables.

4️⃣ Run Locally with Docker
# Ensure backend is in root Docker context
docker-compose up --build


Backend runs on http://localhost:5000/

Flask waits for Postgres to be ready using wait-for-postgres.sh

5️⃣ Test Endpoints

Health Check: GET /

List Transactions: GET /transactions

Add Transaction: POST /transactions with JSON payload:

{
  "amount": 500,
  "category": "Groceries",
  "type": "expense"
}

6️⃣ AWS RDS

Ensure RDS is Publicly Accessible.

Make table transactions exists:

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  amount NUMERIC(10,2),
  category VARCHAR(50),
  type VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

7️⃣ Notes

Dockerfile is in root; requirements.txt is in backend/.

wait-for-postgres.sh ensures backend waits for Postgres availability.

You can test locally with Docker or directly connect to RDS using .env.

Terraform will be added later to automate EC2/RDS provisioning.

8️⃣ Next Steps

Prepare Terraform outputs for RDS endpoint.

Deploy Flask backend to EC2 (Phase 3).

Ensure proper security group and port access for EC2.
