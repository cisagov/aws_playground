# Allow egress anywhere via https
# Needed to pull files from GitHub and external data sources (e.g. usgs.gov)
resource "aws_network_acl_rule" "playground_private_egress_anywhere_via_https" {
  network_acl_id = aws_network_acl.playground_private_acl.id
  egress         = true
  protocol       = "tcp"
  rule_number    = 103
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow ingress from anywhere via ephemeral ports
resource "aws_network_acl_rule" "private_ingress_from_anywhere_via_ephemeral_ports" {
  network_acl_id = aws_network_acl.playground_private_acl.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 104
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow ingress from the bastion via ssh
resource "aws_network_acl_rule" "private_ingress_from_bastion_via_ssh" {
  network_acl_id = aws_network_acl.playground_private_acl.id
  egress         = false
  protocol       = "tcp"
  rule_number    = 110
  rule_action    = "allow"
  cidr_block     = "${aws_instance.playground_bastion.private_ip}/32"
  from_port      = 22
  to_port        = 22
}

# Allow egress to the bastion via ephemeral ports
resource "aws_network_acl_rule" "private_egress_to_bastion_via_ephemeral_ports" {
  network_acl_id = aws_network_acl.playground_private_acl.id
  egress         = true
  protocol       = "tcp"
  rule_number    = 111
  rule_action    = "allow"
  cidr_block     = "${aws_instance.playground_bastion.private_ip}/32"
  from_port      = 1024
  to_port        = 65535
}

