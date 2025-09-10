# Terraform Infrastructure Documentation on VPS Platform
## 1.	Project Overview
> * This project deploys a multi-container environment using Terraform and Docker on a VPS. The architecture includes:
>>    * Load Balancer (LB): NGINX container to distribute traffic to backend app containers.
>>    * Application (App): Multiple HTTPD containers serving web apps.
>>    * Database (DB): MySQL container for persistent storage.
>>    * Network: Public and private Docker networks for container isolation and communication.

## 2.	Architecture Diagram

> ![Architecture Diagram](image.png)

## 3.	Terraform Modules

> ![alt text](image-1.png)

## 4.	Key Terraform Concepts
> * Providers: kreuzwerker/docker is used for Docker container management.
> * Backend: Local backend (terraform.tfstate) stores state file on the VPS.
> * Absolute Paths: Required for Docker volume mounts.
> * Networks: Containers communicate using Docker networks (private_net_id and public_net_id).
> * Outputs:
>>    * lb_access_url: URL to access the NGINX load balancer.
>>    * app_ips: IP addresses of app containers.
>>    * db_endpoint: Database connection endpoint.

## 5.	File Structure

> ![File Structure](image-2.png)

## 6.	Root Configuration (main.tf)
<ins> Providers and Backend </ins>

> ![Providers](image-3.png)
>> * Uses the Docker provider to manage Docker resources on your VPS.
>> * Stores Terraform state locally (terraform.tfstate).

<ins>Modules</ins>

**Network Module**

> ![Network](image-4.png)
>> * Creates public and private Docker networks.
>> * Output: public_net_id, private_net_id.

**Compute Module**

> ![compute](image-5.png)
>> * Deploys multiple app containers (httpd:latest) on private network.
>> * Output: app_ips.

**Database Module**

> ![Database](image-6.png)
>> * Deploys MySQL container on private network.
>> * Output: db_endpoint.

<ins>Load Balancer</ins>

> ![Load_Balancer](image-7.png)
>> * Nginx container bridges public and private networks.
>> * Uses nginx.conf to route traffic to app containers.
>> * Exposes port 8082 on VPS.

## 7.	Modules Explained
> **a.	Network Module**
>> ![alt text](image-8.png)
>>> * public network allows external access.
>>> * private network is internal only for apps and DB communication.

> **b.	Compute Module**
>> ![alt text](image-9.png)
>>> * Deploys var.app_count HTTP app containers. 
>>> * Connected to the private network.
>>> * count = var.app_count  -> number of app containers.
>>> * Outputs IPs for LB to use.

> **c.	Database Module**
>> ![alt text](image-10.png)
>>> * MySQL container on private network.
>>> * Environment variables configure DB credentials.
>>> * Exposes external port 3307 for optional access.

## 8.	Outputs
> * lb_access_url → Access load balancer via VPS public IP.
> * db_endpoint → DB IP:port for internal or external access.
> * pp_ips → List of all app container IPs in private network.

## 9.	Nginx Config
> ![Nginx](image-11.png)
>> * Routes traffic from public network to private app containers.

## 10.	Step-by-Step Workflow
> **a.	Initialize Terraform**
>> ![Initialize](image-12.png)
>>> * Downloads Docker provider (kreuzwerker/docker).
>>> * Prepares local backend (terraform.tfstate).

> **b.	Check What Will Happen**
>> ![alt text](image-13.png)
>>> Terraform simulates what it will create:
>>>> * Networks → public & private
>>>> * App containers → 2 by default
>>>> * Database container
>>>> * Nginx load balancer
>>> It’s like drawing a blueprint before building.

> **c.	Apply Terraform**
>> $ terraform apply
>> ![alt text](image-14.png)
>>> * Terraform actually creates the resources.

> **d.	Check Outputs**
>> ![alt text](image-15.png)
>>> * Open browser → http://194.164.151.129:8082 → traffic is routed to one of the app containers.
>>> * Use mysql -h 172.23.0.4 -P 3306 -u root -p → connect to DB (inside private network).
>>>> ![alt text](image-16.png)

## **Verify the Containers status:**
> ![alt text](image-17.png)

> ![alt text](image-18.png)

## 11.	Buggs  and Solution
> **A.	Terraform Provider Issue**
>> Problem:
>>> * When running terraform init, you got:
>>>> ![alt text](image-19.png)

>> Cause:
>>> * Terraform was trying to use the wrong provider (hashicorp/docker) which does not exist in the registry.
>>> * Your modules were implicitly depending on hashicorp/docker.

>> Solution:
>>> * Explicitly specify the correct provider in terraform block:
>>>> ![alt text](image-20.png)

> **B.	Unsupported Arguments in docker_container**
>> Problem:
>>> * Running terraform plan gave errors:
>>> ![alt text](image-21.png)

>> Cause:
>>> * kreuzwerker/docker provider v3+ does not use cpu_count.
>>> * volumes { type, source, target } was the old syntax from hashicorp/docker.

>> Solution:
>>> * Use the current provider syntax:
>>>> ![alt text](image-22.png)
>>> * Remove unsupported fields (cpu_count, type, source, target).

> **C.	Path Issue for Volume Mount**
>> Problem:
>>> ![alt text](image-23.png)

>> Cause:
>>> * Docker provider requires absolute paths for host volume mounts.

>> Solution:
>>> * Use abspath():
>>>> ![alt text](image-24.png)

> **D.	LB Container Exited Immediately**
>> Problem:
>>> * Even after terraform apply, LB container kept crashing.
>>>> ![alt text](image-25.png)

>> Cause:
>>> * Your nginx.conf included:
>>>> ![alt text](image-26.png)
>>> * When mounted to /etc/nginx/conf.d/default.conf, the extra http {} caused nested http blocks, which NGINX rejects.
>>> * Also, LB might not have been on the same network as app containers, so dev-app-1/dev-app-2 could not be resolved.

>> Solution:
>>> * •	Correct nginx.conf:
>>>> ![alt text](image-27.png)
>>> * Mount to /etc/nginx/conf.d/default.conf.
>>> * Ensure LB is connected to the same private network as app containers.

> **E.	App Not Accessible in Browser**
>> Problem:
>>> * Containers were running, but visiting http:// 194.164.151.129:8082 returned nothing.

>> Cause:
>>> * NGINX LB was failing to start (due to nginx.conf errors).
>>> * App containers were on private network, LB was not able to resolve them.

>> Solution:
>>> * Fixed nginx.conf as above.
>>> * LB connected to both private and public networks:
>>>> ![alt text](image-28.png)
>>> * Exposed LB port 8082 to VPS.




