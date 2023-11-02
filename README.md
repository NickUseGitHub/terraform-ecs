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
