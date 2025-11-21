<h1 align="center">Test Wordpress in AWS Terraform Project</h1>

This project deploys a test Wordpress instance in AWS, using Terraform.

Deploys three EC2 instances, two running Wordpress, and the third one running
MySQL.

The two Wordpress instances share Wordpress code using EFS. The Wordpress are
behind an Application Load Balancer, serving HTTP on port 80😞.

All EC2 instances run Ubuntu 24.04.

A script for optimizing MySQL tables runs periodically on the DB EC2 instance.
The script is setup as Systemd timer unit, which runs at 2am every Sunday. Its
output could be found in the system log for unit
'optimize_mysql_tables.service'.

## 📚 Usage

Credentials are handled as sensitive Terraform variables, without default values.

Credential Variables:
| Name | Description |
|------|-------------|
| mysql_username |MySQL user name for Wordpress| 
| mysql_password |MySQL user password for Wordpress|
| wordpress_admin_username|Wordpress admin username|
| wordpress_admin_password|Wordpress admin password|
| wordpress_admin_email|Wordpress admin e-mail address|

Other notable variables:
| Name | Description | Value|
|------|-------------||
|wordpress_version|WP Version|6.8.3|


### 🚀 Deploy

```sh
$ terraform init
$ terraform plan
$ terraform apply
```


### Output
| Name | Description |
|------|-------------|
|wp_node1_instance_ip| Public IP address of first Wordpress EC2 instance|
|wp_node2_instance_ip| Public IP address of second Wordpress EC2 instance|
|db_instance_ip|Public IP address of MySQL DB EC2 instance|
|lb_dns_name|The DNS name of the load balancer|


### Access to Wordpress
Please open the DNS name of the load balancer in your browser, using HTTP😞.

### SSH access to EC2 Instances
EC2 instances are accessed with the OpenSSH-compatible private/public key pair,
which should be located at the path, specified in variable "private_key_location".

Please note the code expects the public key to be at the same location as
the private key, but with '.pub' suffix, added to private key path. 


### 💣 Destroy

```sh
$ terraform destroy
``` 


## Issues
- HTTP only 
- Uses Terraform provisioners, which is not best practice (https://developer.hashicorp.com/terraform/language/provisioners)  
- Ubuntu software packages` versions aren't fixed
- Manual resources dependency might be a bit wrong
- MySQL optimization script expects to be run as root
- MySQL optimization script piggy-backs on mysql-server package's mysqlcheck command, which doesn't follow the requirements exactly
- Port 80 is hard-coded in Apache configuration file
- Ubuntu version is hard-coded
- wp-cli version is hard-coded
- MySQL script schedule is hard-coded


## Insipration
- https://numericaideas.com/blog/deploy-wordpress-2-tier-aws-architecture-with-terraform/ / https://github.com/numerica-ideas/community/tree/master/terraform/deploy-wordpress-2tier-aws-architecture-with-terraform
- https://ubuntu.com/tutorials/install-and-configure-wordpress

## References
- https://developer.hashicorp.com/terraform/language
- https://github.com/trackit/terraform-boilerplate
