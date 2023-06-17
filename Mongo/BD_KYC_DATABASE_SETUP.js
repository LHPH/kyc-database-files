db.createUser({
    user: "mongoadmin",
    pwd: "mongoadmin",
    roles: [{role: "userAdminAnyDatabase", db: "admin"}]
});

db.getSiblingDB('kyc_database');

db.createUser({
    user: "kyc_user",
    pwd: "kyc_pass",
    roles: [{role: "dbOwner", db: "kyc_database"}]
});

db.auth('kyc_user','kyc_pass')

db.createCollection('executives_track')

db.createCollection('customers_track')