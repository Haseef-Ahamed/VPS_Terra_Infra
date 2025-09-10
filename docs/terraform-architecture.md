# Terraform Infrastructure Documentation on VPS Platform
## 1.	Project Overview
* This project deploys a multi-container environment using Terraform and Docker on a VPS. The architecture includes:
    •	Load Balancer (LB): NGINX container to distribute traffic to backend app containers.
    •	Application (App): Multiple HTTPD containers serving web apps.
    •	Database (DB): MySQL container for persistent storage.
    •	Network: Public and private Docker networks for container isolation and communication.
