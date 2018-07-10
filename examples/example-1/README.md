## Deploy Cassandra Cluster
This is an example of how to use the terraform_oci_cassandra_cluster module to deploy a Cassandra cluster in OCI.

**Note**: To keep this example as simple as possible, it deploys the Cassandra cluster into your existing VCN and subnets, all of which are publicly accessible. In addition, storage_port and ssl_storage_port should be configured in security list.

### Using this example
Update terraform.tfvars with the required information.

### Deploy the cluster  
Initialize Terraform:
```
$ terraform init
```
View what Terraform plans to do before actually executing it:
```
$ terraform plan
```
Use Terraform to provision resources and Cassandra cluster on OCI:
```
$ terraform apply
```
