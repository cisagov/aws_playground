# Allow HTTPS egress anywhere
resource "aws_security_group_rule" "private_https_egress_to_anywhere" {
  security_group_id = "${aws_security_group.playground_private_sg.id}"
  type = "egress"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
}

# Allow SSH ingress from the bastion
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
