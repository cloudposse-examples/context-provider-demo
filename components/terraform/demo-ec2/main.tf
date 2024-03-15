locals {
  enabled = data.context_config.this.enabled
}

# Get the context so we can read properties (enabled) from it
data "context_config" "this" {}

# Create a label based on the context
data "context_label" "name" {
  count = local.enabled ? 1 : 0
  values = {
    "name" = "demo"
  }
}

# Create tags based on the context. Add the value of the name label to the tags
data "context_tags" "this" {
  count = local.enabled ? 1 : 0

  values = {
    "name" = data.context_label.name[0].rendered
  }
}

# Lookup the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  count       = local.enabled ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Deply an EC@ instance and set the tags based on the context
resource "aws_instance" "demo" {
  count         = local.enabled ? 1 : 0
  ami           = data.aws_ami.ubuntu[0].id
  instance_type = "t3.micro"

  tags = data.context_tags.this[0].tags
}
