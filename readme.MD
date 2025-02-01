# Plugins required to install:

    Pipeline Utility Steps
    Pipeline Stage view
    AWS Credentials
    AWS steps
    Rebuilder
    AnsiColor

# Expense Project Folder structure and list of pipeline jobs

    00-vpc: it triggers pipeline, based on ACTION we selected. it will create resources using terraform script like vpc, subnets, routtables, routes, igw, nat_getway.
    10-sg: it will create security groups and ingress rules for bastion, eks cluster, rds, acm, alb... using 10-sg module 
    20-bastion: creates 