# Allow HTTPS egress anywhere
resource "aws_security_group_rule" "private_https_egress_to_anywhere" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "egress"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
}

# Allow SSH ingress from the guacamole
resource "aws_security_group_rule" "private_ssh_ingress_from_bastion" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.playground_bastion.private_ip}/32"
  ]
  from_port = 22
  to_port = 22
}

# Allow guacamole ingress to kali
resource "aws_security_group_rule" "private_ssh_ingress" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.guacamole.private_ip}/32",
  ]
  from_port = 22
  to_port = 22
}

# Allow kali egress to guacamole
resource "aws_security_group_rule" "private_ssh_egress" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "egress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.kali.private_ip}/32"
  ]
  from_port = 22
  to_port = 22
}

# Allow guacamole ingress to kali
resource "aws_security_group_rule" "private_vnc_ingress" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.guacamole.private_ip}/32",
  ]
  from_port = 5901
  to_port = 5901
}

# Allow kali egress to guacamole
resource "aws_security_group_rule" "private_vnc_egress" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "egress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.kali.private_ip}/32"
  ]
  from_port = 5901
  to_port = 5901
}

# Allow guacamole ingress from the guacamole instance
resource "aws_security_group_rule" "private_guacamole_ingress_from_bastion" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.playground_bastion.private_ip}/32"
  ]
  from_port = 8080
  to_port = 8080
}

resource "aws_security_group_rule" "private_guacd_ingress_from_bastion" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "ingress"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.playground_bastion_sg.id}"
  from_port = 4822
  to_port = 4822
}

# Allow webd egress of webd
resource "aws_security_group_rule" "private_guacd_egress_to_guacui" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "egress"
  protocol = "tcp"
  cidr_blocks = [
    "${aws_instance.guacamole.private_ip}/32"
  ]
  from_port = 4822
  to_port = 4822
}
