# Init project

### Set up environment
- first install terraform via brew
```
$ brew install terraform
```
- Then create file name `backend.conf` which content as below
```
bucket     = "<YOUR_BUCKET_NAME>"
key        = "<YOUR_BUCKET_PATH_TO_STORE_TF_STATE>"
region     = "<YOUR_AWS_REGION>"
access_key = "<YOUR_ACCESS_KEY>"
secret_key = "<YOUR_SECRET_KEY>"
```

### Set up environment

- run init command
```
$ terraform init
```

## Issues on this project

### Init backend.conf with S3 but not put terraform.tfstate on S3
> Fix on: [https://stackoverflow.com/a/69664785](https://stackoverflow.com/a/69664785)

### Terraform S3 Backend does not recognize multiple AWS credentials
> Run command with prefix command `AWS_PROFILE=<YOUR_AWS_PROFILE>`

```
# Example
$ AWS_PROFILE=<YOUR_AWS_PROFILE> terraform <TERRAFORM_COMMAND>
```

> Ref: [https://github.com/hashicorp/terraform/issues/18774#issuecomment-625947639](https://github.com/hashicorp/terraform/issues/18774#issuecomment-625947639)
