



## Introduction
**awsautodns** is a tool that allows AWS EC2 Instances to automatically register their IP address in a Route53 Hosted Zone at startup.

## Configuration
**awsautodns** is configured by creating tags attached with the instance. The available configuration tags are as follows:
- `autodnsdomain` - The full domain name to point to. (ex. `dev.example.com`)
- `autodnshostedzoneid` - The Hosted Zone ID (ex. `Z119WBBTVP5WFX`)

**awsautodus** uses aws-cli to interact with AWS.
It is best practice to create an AMI User for the tool to use with only the required permissions (make sure to save the access key). The required permissions are as follows:
```
{
	"Effect": "Allow",
	"Action": [
		"ec2:DescribeInstances",
                "ec2:DescribeTags"
	],
	"Resource": "*"
},
{
	"Effect": "Allow",
	"Action": "route53:ChangeResourceRecordSets",
	"Resource": "arn:aws:route53:::hostedzone/YOURHOSTEDZONEIDHERE"
}
```

aws-cli must be configured for the root user.
- `sudo aws configure`
- `Default output format` must be set to `json`
## Install
Install all dependencies.
- Ubuntu (net-tools, aws-cli, gcc): 
`sudo apt -y install net-tools && sudo apt -y install gcc`
	- If aws-cli is not already installed, install it.
	```
	sudo apt -y install unzip
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	rm awscliv2.zip
	sudo ./aws/install
	rm -rf aws/
	```

- Amazon Linux 2/RHEL/Fedora (net-tools, aws-cli, gcc):
`sudo yum -y install net-tools && sudo yum -y install aws-cli && sudo yum -y install gcc`

Clone this repo and enter it's directory.
- `sudo git clone https://github.com/walia6/awsautodns.git && cd awsautodns`

Run the install bash file (make sure to run `sudo aws configure` first)
- `sudo bash install.sh`
