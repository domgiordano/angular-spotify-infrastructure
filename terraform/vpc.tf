## VPC Resources

data "aws_vpc" "managed_vpc"{
    filter {
        name = "tag:Name"
        values = ["${var.app_name}-managed"]
    }
}

data "aws_security_group" "lambda_sg"{
    vpc_id = data.aws_vpc.managed_vpc.id
    filter {
        name = "tag:Name"
        values = ["lambda-sg"]
    }
}

data "aws_subnets" "private_subnet"{
    filter {
        name = "tag:Name"
        values = ["use1-az*"]
    }
}

data "aws_subnet" "private_subnets_az" {
    for_each = toset(data.aws_subnets.private_subnet.ids)
    id = each.value
}
