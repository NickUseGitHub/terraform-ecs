# ECS with terraform

## Init project

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

### Set IAM for Terraform user
Config Policy with these
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:*",
				"s3-object-lambda:*",
				"ec2:*",
				"elasticloadbalancing:*",
				"ecs:*",
				"iam:Get*",
				"iam:List*",
				"iam:AttachRolePolicy",
				"iam:CreateRole",
				"iam:CreatePolicy",
				"iam:DeletePolicy",
				"iam:DeleteRole",
				"iam:DetachRolePolicy",
				"iam:PassRole",
				"iam:PutRolePolicy"
			],
			"Resource": "*"
		}
	]
}
```

## Ref
You can follow how to create ECS walkthrough with this web
[https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/](https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/)

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

### ECS's task cannot pull image
> Ref: [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)