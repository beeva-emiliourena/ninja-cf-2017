Cloudformation workshop
=======================

This repo contains some cloudformation templates to be used in a workshop. They are not ment to be used as they are because they are made with the intend of showing as many different ways to do things as possible. It can be used as referende though.

To run this we need awscli and an AWS account where we had enough permissions to run:

```bash
iam:AddRoleToInstanceProfile
iam:AttachGroupPolicy
iam:AttachRolePolicy
iam:CreateInstanceProfile
iam:CreatePolicy
iam:CreateRole
iam:GetInstanceProfile
iam:GetPolicy
iam:GetPolicyVersion
iam:GetRole
iam:GetRolePolicy
iam:PassRole
iam:Put*
iam:List*
cloudformation:*
cloudwatch:*
logs:*
ec2:*
s3:*
elasticloadbalancing:*
autoscaling:*
```

Two scripts are provided to deploy the stacks. One to be used with delegated roles and anwbis (that should be propperly configured) and the other one to be used with AWS keys.

Scripts usage are:

```bash
script.sh cloudformation-layer-name.(json|yaml) environment
```

For the scripts to work we must provide a parameter file stored in parameters directory named as follows:

```bash
cloudformation-layer-name-parameters-environment.json
```
