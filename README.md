Autism Rocks Rest Service
=========================

Exposes all the Autism Rocks functionality via a Rest API.


Technical Details
=================

Configurations
--------------
Before you can run the application, all the configuration files need to be created and made available under `.config` directory.

    mkdir .config
    cp config_samples/* .config/
    
All the configuration files are self explanatory and should be adjusted to match your local configurations.


Dependencies
------------
Install the application dependencies

    npm install
    
Update Database
---------------
The application uses Flyway to manage the schema upgrades.

    npm run db_migrate 
    
Running the service
-------------------   

    npm start
    
    
Deployment to GCP App Engine
----------------------------

    gcloud app deploy --project autism-rocks