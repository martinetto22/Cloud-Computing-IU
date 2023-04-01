# -----------------------------------------------------------------------
# -------------- FALTA CREAR EL SEGON LOAD BALANCER!!!! -----------------
# -----------------------------------------------------------------------

provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-2"
  ami = var.ubuntu_ami[local.region]
}

resource "aws_vpc" "main-VPC"{
    cidr_block = "172.0.0.0/16"

    tags = {
      "Name" = "Main VPC"
    }
}

resource "aws_vpc" "secondary-VPCs"{
    count = length(var.secondary-VPCs-cidr_block)

    enable_dns_hostnames = true
    enable_dns_support = true
    cidr_block = var.secondary-VPCs-cidr_block[count.index]

    tags = {
      "Name" = "Secondary -${count.index}"
    }
}

# ---------
# MODULES
# ---------

module "data-security" {
  source = "./modules/data_security"
}

module "networking" {
  source = "./modules/networking"

  vpc-id = aws_vpc.main-VPC.id
  default-rt-id = aws_vpc.main-VPC.default_route_table_id
  region = local.region
  vpc-ids = [for vpc in aws_vpc.secondary-VPCs: vpc.id]
  secondary-VPCs-block = var.secondary-VPCs-cidr_block
}

module "servers" {
  source = "./modules/instances"

  vpc-id = aws_vpc.main-VPC.id
  SSH-server-port = var.SSH-server-port
  HTTP-server-port = var.HTTP-server-port
  instance-type = var.instance-type
  ami-id = local.ami
  servers-map = module.networking.servers
  instance-profile-name = module.ssm.name-instance-profile
  arn-instance-profile = module.ssm.arn-instance-profile
}

module "loadbalancer"{
  source = "./modules/load_balancer"

  vpc-id = aws_vpc.main-VPC.id
  HTTP-server-port = var.HTTP-server-port
  lb-port = var.lb-port
  subnets_ids = module.networking.public-subnets-ids
  instances_ids = module.servers.instances_id
}

module "s3" {
  source = "./modules/s3"

  vpc-id = aws_vpc.main-VPC.id
  private-subnets-rt-id = module.networking.private-subnets-rt-id
}

module "endpoint_s3" {
  source = "./modules/secondary/endpoint_s3"

  vpcs-id = [for vpc in aws_vpc.secondary-VPCs: vpc.id]
  private-subnets-rt-id = module.secondary-networking.private-subnets-rt-ids
}

module "secondary-networking" {
  source = "./modules/secondary/networking"

  main-vpc-id = aws_vpc.main-VPC.id
  vpc-ids = [for vpc in aws_vpc.secondary-VPCs: vpc.id]
  region = local.region
  peering-id = module.networking.peering-connection-id
  default-rt-ids = [for rt in aws_vpc.secondary-VPCs: rt.default_route_table_id]
}

module "secondary_instances" {
  source = "./modules/secondary/instances"

  calculation-instances-map = module.secondary-networking.calculation-servers
  ami-id = local.ami
  #ami-id = "ami-0aaa5410833273cfe"
  instance-type = var.instance-type
  vpc-ids = [for vpc in aws_vpc.secondary-VPCs: vpc.id]
  SSH-server-port = var.SSH-server-port
  instance-profile-name = module.ssm.name-instance-profile
  arn-instance-profile = module.ssm.arn-instance-profile
  private-subnets = module.secondary-networking.subnets-ids
  sg-nlb = module.n-load-balancer.sg
}

module "autoscaling" {
  source = "./modules/secondary/autoscaling"

  subnets-id = module.secondary-networking.subnets-ids
  launch-template-id = [for template in module.secondary_instances.launch-template-id: template.id]
  nlb-arn = module.n-load-balancer.nlb-target-group-arn
}

module "n-load-balancer" {
  #depends_on = [module.autoscaling]
  source = "./modules/secondary/n_load_balancer"

  subnets-id = module.secondary-networking.subnets-ids
  vpc-id = [for vpc in aws_vpc.secondary-VPCs: vpc.id]
  ssh-port = var.SSH-server-port
  autoscaling-id = module.autoscaling.autoscaling-ids
  autoscaling-names = module.autoscaling.autoscaling-names
}

module "route53" {
  source = "./modules/route53"
  lb_dns_name = module.loadbalancer.load-balancer-dns
  lb_zone_id = module.loadbalancer.load-balancer-zone-id
}

module "waf" {
  source = "./modules/waf"
  arn-lb = module.loadbalancer.load-balancer-arn
}

module "inspector" {
  source = "./modules/inspector"
}

module "ssm" {
  source = "./modules/ssm"
}