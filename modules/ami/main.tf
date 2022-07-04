data "aws_ami" "ubuntu" {
    most_recent = true

    name_regex = "22.04-amd64-server"

    filter {
        name   = "architecture"
        values = [ "x86_64" ]
    }

    owners = [
        "099720109477" // Ubuntu
    ]
}

data "aws_ami" "linux-2" {
    most_recent = true

    name_regex = "amzn2-ami-hvm"

    filter {
        name   = "architecture"
        values = [ "x86_64" ]
    }

    owners = [
        "137112412989" // Amazon, AWS
    ]
}

data "aws_ami" "centos" {
    most_recent = true

    name_regex = "CentOS Stream"

    filter {
        name   = "architecture"
        values = [ "x86_64" ]
    }

    owners = [
        "125523088429" // Open-Source Foundation
    ]
}

output "ami-identifiers" {
    value = {
        ubuntu = data.aws_ami.ubuntu.id
        linux-2 = data.aws_ami.linux-2.id
        centos = data.aws_ami.centos.id
    }
}