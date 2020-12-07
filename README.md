
# Provisioning with Terraform @ aws
This folder contains source code for Terraform using the AWS provider, and a Terratest in the test folder.
You need to set the ~/.aws/credentials before running Terraform.

## Testing
To run the tests, you need TFLINT, shellcheck and the Go-language environment.

### Management IPs
You **must** set management IP-adresses inside `variables.tf` before running the tests,
as SSH otherwise will be blocked
