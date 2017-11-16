Cloudformation stacks and templates examples
============================================

Example stacks to run in the workshop.

They can be modified in the parameters section so each person can create a new VPC to use during the workshop. You can change 10.10.10.0/23 to another range and projectname to whatever you want as long as it does not match with other people's project names.

```json
  {
    "ParameterKey": "Project",
    "ParameterValue": "projectbar"
  },
  {
    ...
  },
  {
    "ParameterKey": "VPCSubnetCidrBlock",
    "ParameterValue": "10.10.25.0/23"
  },
```

Note that we are using /26 for the subnets and we must modify them accordly with the VPC subnet we've chosen before. And yes, we don't use 63 ip's... this is just an example. Feel free to add the fourth subnet to use the whole range if you want.

As mentioned before, two scripts are provided to deploy the stacks. One to be used with delegated roles and anwbis (that should be propperly configured) and the other one to be used with AWS keys.

Scripts usage are:

```bash
script.sh cloudformation-layer-name.(json|yaml) environment
```

For the scripts to work we must provide a parameter file stored in parameters directory named as follows:

```bash
cloudformation-layer-name-parameters-environment.json
```
