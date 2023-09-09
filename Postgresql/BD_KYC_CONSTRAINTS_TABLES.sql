-- CATALOGS
ALTER TABLE KYC_SERVICES ADD PRIMARY KEY(ID);
ALTER TABLE KYC_PAYMENT_METHODS ADD PRIMARY KEY(ID);
ALTER TABLE KYC_CHANNEL ADD PRIMARY KEY(ID);
ALTER TABLE KYC_SERVICE_STATUS ADD PRIMARY KEY(ID);
ALTER TABLE KYC_STATES_COUNTRY ADD PRIMARY KEY(ID);
ALTER TABLE KYC_TRANSACTION_STATUS ADD PRIMARY KEY(ID);
ALTER TABLE KYC_PAYMENT_STATUS ADD PRIMARY KEY (ID);
ALTER TABLE KYC_USER_TYPE ADD PRIMARY KEY(ID);
ALTER TABLE KYC_BATCH_ID ADD PRIMARY KEY(ID);
ALTER TABLE KYC_REPORT_TYPE ADD PRIMARY KEY(ID);
ALTER TABLE KYC_STATUS_OFFER ADD PRIMARY KEY(ID);
ALTER TABLE KYC_OFFICE ADD PRIMARY KEY(ID);

--- PARAMETERS
ALTER TABLE KYC_PARAMETERS ADD PRIMARY KEY(ID);

-- CUSTOMERS
ALTER TABLE KYC_CUSTOMER ADD PRIMARY KEY (ID);

ALTER TABLE KYC_CUSTOMER_ADDRESS ADD CONSTRAINT FK_KYC_CUSTOMER_ADDRESS_ID_CUSTOMER
FOREIGN KEY (ID_CUSTOMER) REFERENCES KYC_CUSTOMER(ID) ON DELETE CASCADE;

ALTER TABLE KYC_CUSTOMER ADD CONSTRAINT KYC_CUSTOMER_ID_USER
FOREIGN KEY (ID_USER) REFERENCES KYC_USER(ID) ON DELETE CASCADE;

-- EXECUTIVES
ALTER TABLE KYC_EXECUTIVE ADD PRIMARY KEY(ID);

ALTER TABLE KYC_EXECUTIVE ADD CONSTRAINT KYC_EXECUTIVE_ID_USER
FOREIGN KEY (ID_USER) REFERENCES KYC_USER(ID) ON DELETE CASCADE;

ALTER TABLE KYC_EXECUTIVE ADD CONSTRAINT KYC_EXECUTIVE_ID_BRANCH
FOREIGN KEY (ID_BRANCH) REFERENCES KYC_OFFICE(ID) ON DELETE SET NULL;

--- USERS
ALTER TABLE KYC_USER ADD PRIMARY KEY(ID);
ALTER TABLE KYC_LOGIN_HISTORIC ADD PRIMARY KEY(ID);
ALTER TABLE KYC_LOGIN_USER_INFO ADD PRIMARY KEY(ID_USER);

ALTER TABLE KYC_LOGIN_HISTORIC ADD CONSTRAINT FK_KYC_LOGIN_HISTORIC_ID_USER
FOREIGN KEY (ID_USER) REFERENCES KYC_USER(ID) ON DELETE CASCADE;

ALTER TABLE KYC_LOGIN_USER_INFO ADD CONSTRAINT FK_KYC_LOGIN_USER_INFO_ID_USER
FOREIGN KEY (ID_USER) REFERENCES KYC_USER(ID) ON DELETE CASCADE;

ALTER TABLE KYC_LOGIN_HISTORIC ADD CONSTRAINT FK_KYC_LOGIN_HISTORIC_ID_CHANNEL
FOREIGN KEY (ID_CHANNEL) REFERENCES KYC_CHANNEL(ID) ON DELETE CASCADE;

ALTER TABLE KYC_USER ADD CONSTRAINT KYC_USER_USER_TYPE
FOREIGN KEY (USER_TYPE) REFERENCES KYC_USER_TYPE(ID) ON DELETE CASCADE;

--- CAMPAIGNS
ALTER TABLE KYC_TEMP_OFFERS ADD PRIMARY KEY(ID);
ALTER TABLE KYC_OFFERS ADD PRIMARY KEY(ID);
ALTER TABLE KYC_CAMPAIGN ADD PRIMARY KEY(ID);
ALTER TABLE KYC_TEMP_OFFERS_ERRORS ADD PRIMARY KEY(ID);

ALTER TABLE KYC_OFFERS ADD CONSTRAINT FK_KYC_OFFERS_ID_CAMPAIGN
FOREIGN KEY (ID_CAMPAIGN) REFERENCES KYC_OFFERS(ID) ON DELETE CASCADE;

ALTER TABLE KYC_OFFERS ADD CONSTRAINT FK_STATUS
FOREIGN KEY (STATUS) REFERENCES KYC_STATUS_OFFER(ID) ON DELETE CASCADE;

ALTER TABLE KYC_TEMP_OFFERS_ERRORS ADD CONSTRAINT FK_ID_TEMP_OFFER
FOREIGN KEY(ID_TEMP_OFFER) REFERENCES KYC_TEMP_OFFERS(ID) ON DELETE CASCADE;

--- REPORTS
ALTER TABLE KYC_RECORD_REPORTS ADD PRIMARY KEY(ID);

ALTER TABLE KYC_RECORD_REPORTS ADD CONSTRAINT FK_REPORT_TYPE_ID FOREIGN KEY(REPORT_TYPE_ID)
REFERENCES KYC_REPORT_TYPE(ID) ON DELETE SET NULL;

ALTER TABLE KYC_RECORD_REPORTS ADD CONSTRAINT FK_RECORD_REPORTS_ID_CUSTOMER FOREIGN KEY(ID_CUSTOMER)
REFERENCES KYC_CUSTOMER(ID) ON DELETE CASCADE;