# Cloud Computing IU Project

<p align="center">
 <img src="https://78.media.tumblr.com/a2b1c618a96bc1a7f85c0df0c2becbb8/tumblr_mrowch3MIn1sbav3bo1_500.gif">
</p>

:dart: In this project an AWS infrastructure has been designed using Terraform.
The project has consisted in the creation of an infrastructure for data processing. It is not intended to create a scenario with all the necessary and essential elements, in fact a template is created with the main basic components that we should expect in any platform.
This project does not incorporate elements such as Kinesis, lambda functions, CloudWatch... although it is evident that in some scenarios the use of these resources would be convenient.
A template is generated for future more advanced projects.

:dart: The approach is to create a web application that requires very heavy workloads for a single server, so we have designed a first VPC (main) and a set of secondary VPCs. The idea is that in the main VPC is the web server with which the clients will interact and in the secondary VPCs are the servers responsible for executing the computationally expensive tasks.
In this exercise we try to guarantee a high availability system with the necessary security for the current times.

:information_source: One of the most important aspects in any infrastructure is the robustness of the system, it is necessary that it is resilient, that we are able to design an architecture adaptable to the problems that may arise. It is not so important to predict what the problem might be (as this is extremely complex and often stressing a rigid system results in many different weaknesses. When a problem is solved, it is only a matter of time before it fails again) as much as providing the architecture with enough different solutions to generate an adaptable infrastructure for a changing environment.

:cyclone: That said, let's see what it is about. :coffee:

![diagrama](https://user-images.githubusercontent.com/110245293/229069607-2653953c-22cf-4917-a6d3-04fabbb8911c.png)

:scream_cat: :scream_cat: :scream_cat: :exploding_head:

Yes, when the whole graphic is displayed it's scary, but as with any project, it's just a matter of breaking the whole job down into small parts.

## Starting :rocket:

#### Preparing the laboratory :microscope::coffee::wrench:

:dart: The first thing to do is to prepare the environment. In my case I have worked with [Visual Studio](https://code.visualstudio.com/) code because it is the IDE I am used to, in your case you can use any IDE that allows you to work with [Terraform](https://developer.hashicorp.com/terraform/intro).

:warning: And of course! If you don't have an [AWS](https://aws.amazon.com/) account yet, you absolutely must create one!

The installation process is very well documented for both visual studio code and Terraform so I will not explain the steps here. Once you have installed your IDE and terraform, you should check that the installation has been completed correctly. To do this you only have to enter (in your terminal) `terraform --version`, where you should see something like the following:

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229297703-1e91c8d4-18ce-4534-af1a-f14d1c0adda9.png">
</p>

:dart: Now comes a more delicate step, once you have your AWS account, you must create a user and restrict permissions. The following image shows a quick way to do it (although it is not recommended since we should try to give the minimum permissions).

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229299190-42d9800e-a07d-41cd-aece-1fc9ab49af39.png">
</p>

These are the permissions you can set to avoid problems with the infrastructure we are designing, but it is not recommended. You should restrict the permissions as much as you can.
For resource allocation I have created a group and assigned a new user to this group. So these permissions are defined for the group I have created.
There are different ways to do it, if you decide to do it in another way that is fine too.

:warning: There is a policy defined with the name `DLM_snapshots`. This policy is necessary in order to use the `snapshots.tf` module. Here is the `.json`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dlm:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": [
                "arn:aws:iam::548305448673:role/service-role/AWSDataLifecycleManagerDefaultRole",
                "arn:aws:iam::548305448673:role/service-role/AWSDataLifecycleManagerDefaultRoleForAMIManagement"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:ListRoles",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeRegions",
                "kms:ListAliases",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
```

:dart: Another important aspect is the configuration of the Terraform CLI. [Here you have the official documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

:cyclone: With all this we should already have the environment prepared. So let's jump to the next step.

### And why these services?

:pushpin: **route 53**

Nowadays the use of HTTP on a platform does not make any sense and route53 offers many benefits which you can see in the [official documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html). I am going to expose some of them:

- [x] High availability
- [x] Scalability
- [x] Global reach
- [x] Traffic management
- [x] Cost-effective (like almost everything in AWS)

If you follow the documentation you will find everything you need to buy the domain, register it, obtain the TLS certificate...

:pushpin: **Internet Gateway**

Necessary to have internet connection.

:pushpin: **WAF**

WAF (Web Application Firewall) is a service that provides protection to web applications. As the name indicate it's a firewall so we can specify our own rules but in our case, we will use the [AWS Managed Rules Service](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups.html) to go faster as firewall configuration is not the aim of this project.

I followed the [Configure AWS WAF With Terraform](https://epam.github.io/edp-install/operator-guide/waf-tf-configuration/) tutorial.

:information_source: One thing to mention is that if we do not use route53, we could add another layer of security by implementing AWS Shield, but this service comes by default with the use of route53.

:pushpin: **Application Load Balancer**

With the ALB we achieve high availability to our application. High availability is something we already achieved with the Route 53 service, adding the ALB reinforces this feature.
However, it is important to understand how ALB and Route53 work, because they do not offer high availability in the same way.

:pushpin: **AWS Inspector**

This is a security advisory service. This service has a cost so you should look carefully if you need it. In my case I have implemented it because I consider essential to have a good security system in any infrastructure and as the first 250 monthly assessments are free, you can configure the inspector to be totally free.
In my case I have implemented the inspector in my instances. You have the official documentation [here](https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html).

:pushpin: **S3**

S3 is a storage service that offers several advantages, some of them are:

- [x] Highly Scalability
- [x] Highly Available
- [x] Easy to use

In my case I have implemented it because I find it very simple to work with this service apart from the fact that it can work in parallel with other storage systems, so you can use it or not use it depending on the needs but its use is relatively simple and its price is very good. You can find the documentation [here](https://docs.aws.amazon.com/es_es/AmazonS3/latest/userguide/Welcome.html).

:pushpin: **SSM**

This is a free service that will facilitate the maintenance tasks of some of our resources. Some of the things we can do is to connect directly to our instances even if they are in a private subnet, which facilitates our task as administrators. [Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html).

:pushpin: **Other important aspects of the infrastructure**

In addition to the services mentioned above, there is a peering connection to connect the different VPCs. At the entrance of the secondary VPCs we find an NLB to distribute the traffic between the different servers of the respective subnets. In these subnets there is an autoscaling group, so a load balancer is needed to distribute the traffic.
Finally, we can only comment on the endpoints for the ssm services, ec2messages and ssmmessages, allow us to connect using SSM.

The [peering connection](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) is a necessary component to be able to create direct connections between VPCs, so the fact of allocating different resources between different VPCs (which gives security to the infrastructure), forces us to use a peering for the connection.

Load balancers are necessary for the distribution of traffic between the instances that make up the auto-scaling group (something that provides high availability and therefore strengthens the infrastructure). The [load balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) is defined as network type since the instances of the autoscaling group are not for web services, they are not public, they are designed to do workloads too heavy for a web application.

### Some changes you will have to make 

In the `main.tf` file of the `route53` module you must modify where it says `PUT HERE YOUR DOMAIN NAME` and `DOMAIN NAME HERE` for your domain name.

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229319990-02c8c945-d75b-49f9-9cb4-eef227590dc9.png">
</p>

In the `main.tf` file of the `inspector` module you must modify where it says `YOUR ACCOUNT ID`
 for your account ID.
 
 <p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229320032-e7e4be43-3e18-43cf-a6a2-9d1c1d30444b.png">
</p>
 
In the `main.tf` file of the `modules/instances` and `modules/secondary/instances` modules you must modify where it says `NAME OF YOUR KEY` by the name of the document of your password.

 <p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229320103-c1f7ae64-6d7b-461e-a27a-a4650cbd5a70.png">
</p>

 <p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229320449-b1d583b8-74d3-4531-831a-81d9be156459.png">
</p>

In the `main.tf` of the module `s3`. You must change where it says `Write your bucket name` by the name you want to put in your bucket (this name must be unique).

 <p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229320199-51731785-cf4c-4b82-8589-329d24edcd16.png">
</p>

All the variables are defined by default, so it is not necessary to touch anything in the file t2medium.tfvars but, in case you want to change the default variables you must do it correctly and initialize all the corresponding variables, the ones in the file are as an example.

## Let's look the main VPC

:dart: Before we start, let's see how I have structured my code. I have generated different modules and in each module I have created a `main.tf`, `variables.tf` and `output.tf` file.
Using Visual Studio Code as IDE, you can see the following:

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229103488-686f8e95-cee6-4934-8943-a3f55ad2d30c.png">
</p>

:dart: The structure is very simple, we have a module generated for each resource or for specific themes (network theme, instances...). The fact of naming `secondary` to a part of the whole infrastructure does not mean that it is less important or that there are irrelevant things, simply, when developing the code I felt the need to have two well differentiated parts, the public part and the private part. The private part is the one located in the `secondary` directory. This affects the VPC: 1, 2, 3.
The reason why I have chosen this organizational structure does not obey any special criteria, it is simply the one that seemed simpler to me.

:warning: In addition to the modules shown in the image, there are also 4 files:
- [x] `main.tf`
- [x] `outputs.tf`
- [x] `variables.tf`
- [x] `t2medium.tfvars`

:dart: The `outputs.tf` and `t2medium.tfvars` files are totally subjective, in the case of `outputs.tf` I have nothing and it is just there in case I need to get some information. On the other hand, all variables are already initialized by default in `variables.tf` so `t2medium.tfvars` can be useful in case of initializing the variables with other values but in my case, it is also empty.

:rotating_light: Having said that, let's take a look at the `main.tf` file.

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229074374-0393963e-8e96-4b05-8fee-3b0a3875f1ea.png">
</p>

:dart: There is nothing special, perhaps the only thing that is important to mention is that at this point all the VPCs are created, both the main one and the secondary ones, which are saved in a list.
If we continue down in this file we will find the definition of all the modules of the code. This is where we define the modules and create the *connections* between them.

As there are quite a few modules and I don't intend to give a recipe of how to generate all this template, I will explain the modules following the order in which they appear in my IDE.

:warning: Let's continue, now with the module `data_security`.
### DATA_SECURITY ###
In this case 2 files are defined (yes, I know I said that in all modules there would be 3 files, but in this case no... :sweat_smile:)
- [x] `backup.tf`
- [x] `snapshot.tf`

:dart: It is obvious what they are for. In this case I have taken the code from some pages that I have found. I attach the links, there I am sure that they are much better explained, because after all this code has been made by them. Thank you very much.
- [x] [Backup policies](https://shadabambat1.medium.com/automatically-backup-your-ec2-instances-using-aws-backups-terraform-c06d15e2a9c2)
- [x] [To allow the backup service to restore from snapshot](https://stackoverflow.com/questions/61802628/aws-backup-missing-permission-iampassrole)
- [x] [Backup Plan for EBS Volumes](https://aws.plainenglish.io/aws-backup-plan-for-ebs-volumes-with-terraform-226bdb52160a)
- [x] [Lifecycle Policy](https://www.cloudthat.com/resources/blog/create-aws-lifecycle-policy-using-terraform-for-taking-ebs-snapshots)
- [x] [AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dlm-access-control.html)

### INSPECTOR ###

:dart: In this module there is only one file... it is true that these modules are exceptions. :sweat_smile:
Well, the truth is that to implement inspector it is not necessary to comment anything, you only need to define 2 arguments. I attach the link to the official [HasiCorp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler) documentation.
In my case I have specified that I want an EC2 type inspection.

### INSTANCES ###

:dart: Perfect, at this point we already have more things to comment. The first thing is that now there are the 3 commented files (`main.tf`, `output.tf` and `variables.tf`).

We start with `main.tf`, where there are only 2 resources:
- [x] `aws_instance`
- [x] `aws_security_group`

:rotating_light: Let's see `aws_instance`:

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229116657-411ea356-8af0-41af-8d34-486134c74d7b.png">
</p>

:dart: At this point let's remember that we are in the public vpc (main VPC). Therefore, it is clear that we must assign a public ip. For the rest, some of the attributes are not necessary to comment them although perhaps `iam_instance_profile` is. This attribute allows us to assign an instance profile to the user, so that we can assign a role with the necessary policies so that the SSM agent has the necessary permissions to access our instances.

:stop_sign: We have not reached this point yet but in our infrastructure there is a module to implement the policies and roles to have access to the instances via SSM. In my case I have opted for an ami with the SSM agent preinstalled but it is necessary that if it is not installed, you install it to be able to have connection with System manager.

:warning: Here you have a [link](https://docs.aws.amazon.com/systems-manager/latest/userguide/ami-preinstalled-agent.html) to the official documentation with the amis that have the ssm agent preinstalled.

:rotating_light: `aws_security_group`:

:dart: At this point there is nothing special, only inbound (for HTTPS, icmp and SSH protocols) and outbound (any protocol) rules are defined.

### Let's check the LOAD_BALANCER module ###

:dart: The main VPC is intended for a web server so in this case we will have to work with HTTPS (or HTTP if we want to test and we do not have the TLS certificate), this means working on layer 7 of the OSI model. Therefore, we must specify that we will use an Application load balancer.

in this module, we will find 5 defined resources:
- [x] `aws_lb`
- [x] `aws_security_group`
- [x] `aws_lb_target_group`
- [x] `aws_lb_target_group_attachment`
- [x] `aws_lb_listener`

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229127115-e6aa2f11-465f-427f-aa23-db2a8a3117fa.png">
</p>

:dart: In the security group there is only one inbound rule (from any ip) and one outbound rule (from any ip and any port).
Now, the image shows the definition of the load balancer and the target group. It is important that if you apply HTTPS externally you change the protocol to HTTP within the network, unless you configure it using HTTPS both internally and externally. If you do not take this into account you will have problems.

:dart: The following image is nothing special. It is simply to show the attachment between the main VPC servers with the load balancer.

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229128136-c9f93d05-c1d9-4126-bfbb-0600f30259d6.png">
</p>

### NETWORKING ###

:dart: For all the subnetting part it is important to take into account the distribution of IPs. You have this [link](https://www.dnsstuff.com/subnet-ip-subnetting-guide) (as well as many others) where you can understand how it works, but in any case there are also IP calculators to assign addresses according to your interests.
In this module you will find the following resources:
- [x] aws_subnet
- [x] aws_internet_gateway
- [x] aws_default_route_table
- [x] aws_route_table
- [x] aws_route_table_association
- [x] aws_vpc_peering_connection

:dart: As you can see, there are different tasks here. Remember that we are still talking about the main VPC. In this module we generate the subnets (both public and private), create the internet gateway to have external access, define the routing tables and create the peering connection to connect the different VPCs.

:rotating_light: `aws_default_route_tablep`:

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229135708-ac98ac98-dad9-4179-bd77-a07b0ef5502a.png">
</p>

:dart: Multiple routes are defined, one to the Internet gateway and the others to the peering connection. The `count` loop to create the peering connections is due to the fact that we must define the route from the main VPC to the different secondary VPCs.

### ROUTE53 ###
To use Route53 you need to have a domain and register it with AWS. Route53 is a DNS service.
The implementation with Terraform that I have done is not complex and should be understandable. Here is the [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) to the official documentation.

### S3 ###

:dart: To use a s3 bucket we need to define different resources:
- [x] aws_s3_bucket
- [x] aws_s3_object
- [x] aws_s3_bucket_public_access_block
- [x] aws_vpc_endpoint
- [x] aws_vpc_endpoint_route_table_association

:dart: In my case the defined objects have no other purpose than to leave 2 objects in the bucket so each user must modify this part according to his needs.
For the rest we just have to remember to create the endpoint that gives access to the bucket and assign a path to it.
This part of the code is short and is quite well understood.

### SSM ###
:dart: In order to use this service we must pay attention to the policy we define in our instance profile.
Before continuing it is important to make sure that our iam has the SSM agent installed and running. There are different ways to check this, but if the SSM agent is not running, we will not have any dialog with System Manager.
In the official [AWS documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/ami-preinstalled-agent.html) it says that ami has the agent pre-installed.
:dart: These are the resources needed to have an SSM connection:
- [x] aws_iam_instance_profile
- [x] aws_iam_role
- [x] aws_iam_role_policy_attachment
- [x] aws_iam_policy

:stop_sign: You can see the policy defined in the `aws_iam_policy_document` there are specified all the permissions that the role attached to the instance profile will have.

:rotating_light: In `aws_iam_role` we specify which services can use the role with the permissions:
<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229197760-abdcdf9d-5b88-4b08-bb5a-e75b0a367626.png">
</p>

:dart: Let's take a look at the last service before moving on to the sub-directory resources/services

### WAF ###
:dart: For this service I have taken advantage of the following pages:
- [x] [How to Setup AWS WAF](https://automateinfra.com/2021/05/02/how-to-setup-aws-waf-and-web-acl-using-terraform-on-amazon-cloud/)
- [x] [Configure AWS WAF With Terraform](https://epam.github.io/edp-install/operator-guide/waf-tf-configuration/)

:stop_sign: In fact, after having made a detailed inspection of the code, I have decided to take advantage of the whole of it... :sweat_smile:

## SECONDARY MODULES ##

:dart: The reason why I have divided the infrastructure into a main part and a secondary part does not really make any sense and I could have given it any name. I simply wanted to separate what should be the public part and what should be the private part.
That said, in all the modules defined in this directory, it is true that there are 3 files defined (`main.tf`, `variables.tf` and `output.tf`) except in `endpoint_s3`, where output is not required.

:warning: I will continue commenting the project in the same way, only the main.tf file and in those points where there may be confusion.

### AUTOSCALING ###

:dart: I have left this part very simplified and you could make a much more sophisticated autoscaling group, but I leave it to you, for this first template we have enough with what is in this code.

:warning: It is important to remember that the connection between the autoscaling group and the NLB (Network Load Balancer) must be done from the autoscaling group (it is dynamic and therefore the NLB cannot create the connections), otherwise it will give us problems.

:rotating_light: `aws_autoscaling_group`
<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229203607-c1e13f9a-fd96-47c1-8239-30380f5b07d1.png">
</p>

:stop_sign: In this case the attributes themselves are very descriptive and therefore I think the code is quite well understood by itself. In any case [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) you have the official documentation.

### ENDPOINT_S3 ###

:dart: The only difference that we will see in this resource with respect to the S3 of the main directory is in the count:
<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229219704-07c8d7bc-6744-4a67-a8af-62e52ccccf9c.png">
</p>

:dart: In this piece of code we have to define the endpoint for the 3 private VPCs in order to access the bucket.

### INSTANCES ###
:dart: In this module we create a template for the instances that will be created by the autoscaling groups. The creation of the template itself has no complexity but we must assign the instance profile to be able to use the SSM service in each of the instances created from this template.

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229220845-5f46284c-d9eb-43cc-a3de-50ddeab9cb40.png">
</p>

:stop_sign: Here we also specify the different endpoints to be created for the different services needed for an SSM connection:

- [x] `ssm`

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229221483-8f19efb3-0957-4af6-9b8f-c07002e7a5ec.png">
</p>

- [x] `ssmmessages`

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229221637-59987ea2-2de8-4304-a856-e8474d0f830e.png">
</p>

- [x] `ec2messages`

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229221782-4d93f945-cda4-4c12-bb74-217a71bc7d9a.png">
</p>

:warning: [Here](https://docs.aws.amazon.com/es_es/systems-manager/latest/userguide/systems-manager-setting-up-messageAPIs.html) you can find information regarding the services mentioned here.

### N_LOAD_BALANCER ###
:dart: This part is very similar to what we have already seen in the previous load balancer but there are some differences. The first thing is that this load balancer is no longer an Application Load Balancer, now we have a Network Load Balancer and this changes the operation. We must also remember what we have already mentioned regarding the attchment, it is done from the auto scaling group, not from the load balancer.
When working in layer 4 of the OSI model we no longer work with HTTP/HTTPS protocol, now we will specify protocol: TCP.

:rotating_light: `aws_lb` and `aws_lb_target_group`
<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229224529-6852a494-1af4-4b36-bec9-fd136ab8e89e.png">
</p>
:warning: There are not many changes but if you want to make modifications it is important to remember that there is a change in the operation of the previous load balancer.

### NETWORKING ###

:dart: This module does not define any new concept so I will not comment on it. In case any doubt arises you can look at the networking module of the main VPC, the concepts will be the same only adapted to the secondary VPC.

## Other things to note ##
:dart: We don't have any application running on our servers, that's why when we use the NLB, the target groups will come up as unhealthy. This is because the instances cannot respond to the requests that are requested.

<p align="center">
  <img src="https://user-images.githubusercontent.com/110245293/229232811-1239ded6-f498-4d46-a01d-5917db3df37e.png">
</p>

:stop_sign: This is the error you should see if you have no server or application running.

## Built with 🛠️

* [VSC](https://code.visualstudio.com/)
* [Terraform](https://www.terraform.io/)
* [AWS](https://aws.amazon.com/)
