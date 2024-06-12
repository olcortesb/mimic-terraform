# terraform-lambda-signer
POC of AWS lambda Signer with terraform


## Get Starter

- Configure terraform 
    ```bash
    terrafom --version
    # is 1.7.5. You can update by downloading from https://www.terraform.io/downloads.html
    ```
- Configure AWS credentials ([Link](https://gist.github.com/olcortesb/a471797eb1d45c54ad51d920b78aa664))
- Create and configure bucket name 
    ```typescript
    // file terraform-lambda-signer/preferences.tf
    terraform {
    required_version = ">=1.5.0"
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = ">= 4.9"
        }
    }
    backend "s3" {
        key    = "terraform.tfstate"
        bucket = "terraform-lambda-signer" // change the name of bucket
        region = "us-east-1"
    }
    }
    ```

- Terraform init
    ```
    terraform init
    ```


## Deploy

```
terraform plan
terraform apply
```

## Folder structure

```bash
.
├── data.tf
├── lambda_role.tf
├── lambda.tf
├── LICENSE
├── preferences.tf
├── README.md
├── src                # Lambda Folder
│   └── getcost.py     # Lamba Code
├── terraform.tfvars
└── variables.tf
```

## What Is AWS Signer

ref: https://docs.aws.amazon.com/signer/latest/developerguide/Welcome.html

>AWS Signer is a fully managed code-signing service to ensure the trust and integrity of your code. Organizations validate code against a digital signature to confirm that the code is unaltered and from a trusted publisher. With AWS Signer, your security administrators have a single place to define your signing environment, including what AWS Identity and Access Management (IAM) role can sign code and in what Regions. AWS Signer manages the code-signing certificate's public and private keys, and enables central management of the code-signing lifecycle. Integration with AWS CloudTrail helps you track who is generating code signatures and to meet your compliance requirements.

## POC

If the deployment is success, the code of lambda does not show in the console

### Code before configure AWS signer (fea/base branch)

![image](/docs/tf-lambda-signer-1.png)

### Code after configure AWS signer (main branch)

![image](/docs/tf-lambda-signer-2.png)

# References

- https://docs.aws.amazon.com/signer/latest/developerguide/Welcome.html
- https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/v6.1.0/examples/code-signing/main.tf#L95
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning