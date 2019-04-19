# The guacamole AMI
data "aws_ami" "guacamole" {
  filter {
    name = "name"
    values = [
      "guacamole-playground-hvm-*-x86_64-ebs"
    ]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  owners = ["${data.aws_caller_identity.current.account_id}"] # This is us
  most_recent = true
}

# The guacamole EC2 instance
resource "aws_instance" "guacamole" {
  ami = "${data.aws_ami.guacamole.id}"
  instance_type = "t3.micro"
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"

  # This is the private subnet
  subnet_id = "${aws_subnet.playground_private_subnet.id}"
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.playground_private_sg.id}"
  ]

  user_data_base64 = "${data.template_cloudinit_config.ssh_cloud_init_tasks.rendered}"

  tags = "${merge(var.tags, map("Name", "Guacamole"))}"
  volume_tags = "${merge(var.tags, map("Name", "Guacamole"))}"
}

# Provision the guacamole EC2 instance via Ansible
module "playground_gaucamole_ansible_provisioner" {
  source = "github.com/cloudposse/tf_ansible"

  arguments = [
    "--user=${var.remote_ssh_user}",
    "--ssh-common-args='-o StrictHostKeyChecking=no'"
  ]
  envs = [
    "host=${aws_instance.guacamole.private_ip}",
    "bastion_host=${aws_instance.guacamole.public_ip}",
    "host_groups=guacamole"
  ]
  playbook = "../ansible/playbook.yml"
  dry_run = false
}
