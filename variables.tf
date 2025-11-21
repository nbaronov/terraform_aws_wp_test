variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = list(string)
  description = "List of all cidrs for subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "application_port" {
  type    = string
  default = "80"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "wp_nodes_availability_zone" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "db_node_availability_zone" {
  type    = string
  default = "eu-north-1a"
}

variable "efs_dir" {
  description = "EFS root directory"
  type        = string
  default     = "/app"
}

variable "wordpress_dir" {
  description = "WP directory"
  type        = string
  default     = "/app/wordpress"
}

variable "bin_dir" {
  description = "Additional tools directory"
  type        = string
  default     = "/app/bin"
}

variable "wordpress_version" {
  description = "WP Version"
  type        = string
  default     = "6.8.3"
}

variable "wordpress_title" {
  description = "WP Site Title"
  type        = string
  default     = "Test Wordpress Instance"
}

variable "private_key_location" {
  description = "Location of the private key"
  type        = string
}


variable "mysql_database_name" {
  description = "Name of MySQL database for WP"
  type        = string
  default     = "wp"
}

# Credentials

variable "mysql_username" {
  description = "MySQL username for WP"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL user password for WP"
  type        = string
  sensitive   = true
}

variable "wordpress_admin_username" {
  description = "WP admin username"
  type        = string
  sensitive   = true
}

variable "wordpress_admin_password" {
  description = "WP admin password"
  type        = string
  sensitive   = true
}

variable "wordpress_admin_email" {
  description = "WP admin e-mail address"
  type        = string
  sensitive   = true
}
