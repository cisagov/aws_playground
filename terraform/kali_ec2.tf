# The kali AMI
data "aws_ami" "kali" {
  filter {
    name = "name"
    values = [
      "kali-playground-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners      = [data.aws_caller_identity.current.account_id] # This is us
  most_recent = true
}

# The kali EC2 instance
resource "aws_instance" "kali" {
  ami           = data.aws_ami.kali.id
  instance_type = "t2.medium"

  # This is the private subnet
  subnet_id                   = aws_subnet.playground_private_subnet.id
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 25
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    aws_security_group.playground_private_sg.id,
  ]

  user_data_base64 = data.template_cloudinit_config.ssh_cloud_init_tasks.rendered

  tags = merge(
    var.tags,
    {
      "Name" = "Kali"
    },
  )
  volume_tags = merge(
    var.tags,
    {
      "Name" = "Kali"
    },
  )
}

# Provision the Kali EC2 instance via Ansible
module "kali_ansible_provisioner" {
  source = "github.com/cloudposse/tf_ansible"

  arguments = [
    "--user=${var.remote_ssh_user}",
    "--ssh-common-args='-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -o StrictHostKeyChecking=no -q ${var.remote_ssh_user}@${aws_instance.playground_bastion.public_ip}\"'",
  ]
  envs = [
    "host=${aws_instance.kali.private_ip}",
    "bastion_host=${aws_instance.kali.public_ip}",
    "host_groups=kali",
  ]
  playbook = "../ansible/playbook.yml"
  dry_run  = false
}

