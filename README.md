# ACME cusotmer module

This is a customer module for ACME bank demo project

## Installing ACME unlocked package using a Scratch Org (Production ready)

1. Authorize your hub org and provide it with an alias 

    ```
    sfdx auth:web:login -a myhuborg
    ```

2. Clone the repository:

    ```
    git clone https://github.com/manisfdcsfdx/acme-bank-customer-module.git
    cd acme-bank-customer-module
    ```

3. Create a scratch org and provide it with an alias 

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a acme -v myhuborg
    ```

4. Install the app to your scratch org:

    ```
    sfdx force:package:install -p customer-module@1.0.0-1 -w 30 -r 
    ```

5. Assign the **ACME** permission set to the default user:

    ```
    sfdx force:user:permset:assign -n ACME
    ```

7. Open the scratch org:

    ```
    sfdx force:org:open
    ```

8.  In App Launcher, select the **ACME** app.

## Deploy ACME cusotmer module using a Scratch Org (Production ready)


1. Authorize your hub org and provide it with an alias 

    ```
    sfdx auth:web:login -a myhuborg
    ```

2. Clone the repository:

    ```
    git clone https://github.com/manisfdcsfdx/acme-bank-customer-module
    cd acme-bank-customer-module
    ```

3. Create a scratch org and provide it with an alias 

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a acme -v myhuborg
    ```

4. Push the app to your scratch org:

    ```
    sfdx force:source:push
    ```

5. Assign the **ACME** permission set to the default user:

    ```
    sfdx force:user:permset:assign -n ACME
    ```

7. Open the scratch org:

    ```
    sfdx force:org:open
    ```

8.  In App Launcher, select the **ACME** app.


## Test the ACME app

1. Create a Test user with with Readonly profile
2. Assign the **ACME** permission set to the test user
3. Login as test user
4. In App Launcher, select the **ACME** app.
5. Create Account and Financial Account
6. Use workbench to Subscribe CustomerDataSync__e platform and motiner the Account creation events
7. Test apex rest service `/services/apexrest/accounttransaction/` using below sample

``` 
{
    "abid": "<abid from any newly created Account>",
    "accountNumber": <abid from any newly created Financial Account>,
    "amount": 125.68,
    "currency": "AUD",
    "date": "2020/01/01",
    "merchantABN": 12345678912,
    "merchantBSB": 123456,
    "merchantName": "Beau Flowers",
    "time": "17:32:25",
    "type": "debit"
}
```

## Project Implementation Details
1. Person accounts Enabled to store customer details as a person
2. ABID id is populated on Account creation
3. CustomerDataSync__e platform event is published on Account creation
4. Account number populated on Financial account creation
5. Account Balance in financial account is calculated on every financial transaction
6. An apex rest service `/services/apexrest/accounttransaction/` is exposed for a external system to notify salesforce on financial transaction