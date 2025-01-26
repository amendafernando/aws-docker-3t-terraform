# aws-docker-3t-terraform
Terraform block for aws docker 3 tier web application

Creation of VPCs, Web Servers, ECR via IaaC 

## Terraform folder structure

```
├── network/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── webapp/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Install Terraform with `yum`

 - Install `yum-config-manager` to manage your repositories.

`sudo yum install -y yum-utils`

- Use `yum-config-manager` to add the official HashiCorp Linux repository.

`sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`

- Install Terraform from the new repository.

`sudo yum -y install terraform`




