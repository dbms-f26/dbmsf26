from flask import Flask, request, render_template_string
import psycopg2

app = Flask(__name__)

def get_conn():
    return psycopg2.connect(host="db", dbname="coursedb", user="student", password="student")

FORM_TEMPLATE = '''
<h2>Add New Customer</h2>
{% if message %}<p style="color:{{ 'green' if success else 'red' }}">{{ message }}</p>{% endif %}
<form method="post">
  Customer ID (5 chars): <input name="customer_id" maxlength="5" required><br>
  Company Name: <input name="company_name" required><br>
  Contact Name: <input name="contact_name"><br>
  <button type="submit">Add Customer</button>
</form>
'''

@app.route("/customers/new", methods=["GET", "POST"])
def new_customer():
    message = None
    success = False

    if request.method == "POST":
        customer_id = request.form["customer_id"].strip().upper()
        company_name = request.form["company_name"].strip()
        contact_name = request.form.get("contact_name", "").strip()

        conn = get_conn()
        cur = conn.cursor()

        cur.execute(
            "SELECT customer_id FROM northwind.customers WHERE customer_id = %s OR LOWER(company_name) = LOWER(%s)",
            (customer_id, company_name)
        )
        existing = cur.fetchone()

        if existing:
            message = f"A customer with that ID or company name already exists (ID: {existing[0]})."
        else:
            cur.execute(
                "INSERT INTO northwind.customers (customer_id, company_name, contact_name) VALUES (%s, %s, %s)",
                (customer_id, company_name, contact_name)
            )
            conn.commit()
            message = f"Customer '{company_name}' added successfully."
            success = True

        cur.close()
        conn.close()

    return render_template_string(FORM_TEMPLATE, message=message, success=success)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
