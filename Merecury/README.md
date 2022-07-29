# **Merecury - AMD Project**

**Application Name:** Merecury

**Application Type:** Web-based

**Application Goal:** To fully demonstarte Postgresql database handling.
***
## **Getting Started**

In order to successfully run the application please follow the steps below.
***

>**Step 1:** Run the following commands from the _**server**_ directory
```sh

npm init -y

npm install express ejs pg cors

npm install method-override

npm install cookie-parser express-session serve-favicon

npm install --save-dev nodemon

```

>**Step 2:** Add the below lines in "package.json"
```json
 "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "nodemon"
  },
```

>**Step 3:** Postgresql Database

Download and install a PostgreSQL server. For instructions, refer to the PostgreSQL documentation on [Postgresql](www.postgresql.org "Postgresql").
1. After setting up postgresql server use the **"MerecuryDatabase.sql"** file inside **source** folder to import all the tabels and dummy data.

2. The sql file consists of all create tabels and insert tabels queries.

3. It also consists of queries to create all required functions and procedures.

>**Step 4:** Start the app
```sh
npm start
```