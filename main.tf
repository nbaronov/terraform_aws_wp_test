data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "wp_node1_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.first_public_subnet.id
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  availability_zone      = var.wp_nodes_availability_zone[0]

  depends_on = [
    aws_efs_mount_target.efs_mount_target_1
  ]


  key_name = aws_key_pair.instances_ssh_key.key_name

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    destination = "/tmp/setup_apache_and_nfs.sh"
    content = templatefile(
      "template/setup_apache_and_nfs.tftpl",
      {
        efs_dir   = var.efs_dir,
        efs_mount = aws_efs_mount_target.efs_mount_target_1.ip_address
      }
    )
  }

  provisioner "file" {
    destination = "/tmp/wordpress.conf"
    content = templatefile(
      "template/wordpress_apache.tftpl",
      {
        wordpress_dir = var.wordpress_dir
      }
    )
  }

  provisioner "file" {
    destination = "/tmp/default_post_content.txt"
    content     = <<-EOT
Namespaces are a feature of the Linux kernel that partitions kernel resources such that one set of processes sees one set of resources while another set of processes sees a different set of resources. The feature works by having the same namespace for these resources in the various sets of processes, but those names referring to distinct resources. Examples of resource names that can exist in multiple spaces, so that the named resources are partitioned, are process IDs, hostnames, user IDs, file names, and some names associated with network access, and interprocess communication.

Namespaces are a fundamental aspect of containers on Linux.

The term "namespace" is often used for a type of namespace (e.g. process ID) as well for a particular space of names.

A Linux system starts out with a single namespace of each type, used by all processes. Processes can create additional namespaces and join different namespaces.

EOT
  }

  provisioner "file" {
    destination = "/tmp/setup_wordpress.sh"
    content     = <<-EOT
   mkdir -p ${var.bin_dir}
   mkdir -p ${var.wordpress_dir}
   curl -L -o ${var.bin_dir}/wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar
   php ${var.bin_dir}/wp-cli.phar --path='${var.wordpress_dir}' core download --version=${var.wordpress_version}
   php ${var.bin_dir}/wp-cli.phar --path='${var.wordpress_dir}' config create --dbname=${var.mysql_database_name} --dbuser=${var.mysql_username} --dbpass=${var.mysql_password} --dbhost=${aws_instance.db_instance.private_ip}
   php ${var.bin_dir}/wp-cli.phar --path='${var.wordpress_dir}' core install --admin_user=${var.wordpress_admin_username} --admin_password=${var.wordpress_admin_password} --admin_email='${var.wordpress_admin_email}' --title='${var.wordpress_title}' --url='http://${aws_lb.application_loadbalancer.dns_name}'
   php ${var.bin_dir}/wp-cli.phar --path='${var.wordpress_dir}' post update 1 --post_title='Linux namespaces' /tmp/default_post_content.txt
EOT
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh -e /tmp/setup_apache_and_nfs.sh",
      "sudo -u www-data sh -e /tmp/setup_wordpress.sh"
    ]
    on_failure = fail
  }

  tags = {
    Name = "Wordpress Node 1 Instance"
  }
}

resource "aws_instance" "wp_node2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.second_public_subnet.id
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  availability_zone      = var.wp_nodes_availability_zone[1]

  key_name = aws_key_pair.instances_ssh_key.key_name

  depends_on = [
    aws_instance.wp_node1_instance,
    aws_efs_mount_target.efs_mount_target_2
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    destination = "/tmp/wordpress.conf"
    content = templatefile(
      "template/wordpress_apache.tftpl",
      {
        wordpress_dir = var.wordpress_dir
      }
    )
  }

  provisioner "file" {
    destination = "/tmp/setup_apache_and_nfs.sh"
    content = templatefile(
      "template/setup_apache_and_nfs.tftpl",
      {
        efs_dir   = var.efs_dir,
        efs_mount = aws_efs_mount_target.efs_mount_target_2.ip_address
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh -e /tmp/setup_apache_and_nfs.sh",
    ]
  }

  tags = {
    Name = "Wordpress Node 2 Instance"
  }
}

resource "aws_instance" "db_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.db_public_subnet.id
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  availability_zone      = var.db_node_availability_zone

  key_name = aws_key_pair.instances_ssh_key.key_name

  provisioner "file" {
    destination = "/tmp/setup_mysql.sh"
    content     = <<-EOT
  set -e
  sudo apt update -qq
  sudo apt install -qq -y mysql-server
  echo 'bind-address            = ${self.private_ip}' | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
  sudo systemctl restart mysql

EOT
  }

  provisioner "file" {
    destination = "/tmp/create_wordpress_database_and_user.sql"
    content     = <<-EOT

  CREATE DATABASE ${var.mysql_database_name};
  CREATE USER '${var.mysql_username}' IDENTIFIED BY '${var.mysql_password}';
  GRANT ALL ON ${var.mysql_database_name}.* to '${var.mysql_username}';
  FLUSH PRIVILEGES;

EOT
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.private_key_location)
  }

  provisioner "remote-exec" {
    inline = [
      "sh -e -x /tmp/setup_mysql.sh",
      "sudo mysql < /tmp/create_wordpress_database_and_user.sql"
    ]
  }

  tags = {
    Name = "DB Instance"
  }
}

resource "aws_key_pair" "instances_ssh_key" {
  key_name   = "instances_ssh_key"
  public_key = file("${var.private_key_location}.pub")
}

resource "aws_efs_file_system" "efs_volume" {
  creation_token = "efs_volume"
}

resource "aws_efs_mount_target" "efs_mount_target_1" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = aws_subnet.first_public_subnet.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "efs_mount_target_2" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = aws_subnet.second_public_subnet.id
  security_groups = [aws_security_group.efs_sg.id]
}
