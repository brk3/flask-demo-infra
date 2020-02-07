Overview
--------
This terraform module allows you to deploy a working webapp via Azure App Service. In addition to
the app service it includes the following features:

* Container Registry (ACR)
* Backup enabled
* Logging / app insights
* Azure SQL Database

Prerequisites
-------------
* Terraform: https://www.terraform.io/downloads.html
* Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

Usage
-----
Deploy the infrastructure:
```
terraform init
terraform apply -var prefix=$RANDOM
```

The app will start automatically once the image is pushed to ACR. The associated flask-demo app
contains a script to do this using ACR Tasks (acr-build.sh). Alternatively, commits to the repo will
be built and deployed using CircleCI.
