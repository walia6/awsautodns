

## Introduction
**awsautodns** is a tool that allows an AWS EC2 Instance to automatically register it's IP address in a Route53 Hosted Zone at startup. The install script creates a oneshot service, `awsautodns.service`, and sets it to start at boot, by installing it to `multi-user.target`.

**awsautodns** is useful for avoiding fees associated with using an elastic IP address.
## Compatibility
**awsautodns** has been tested to work with the following Linux distros:
- Amazon Linux 2
- Ubuntu Server 20.04 LTS
- Red Hat Enterprise Linux 8
## Dependencies
**awsautodns** has several dependencies for installation.
- net-tools
- aws-cli
- gcc
- make
- git

Once installed, **awsautodns** has only 2 dependencies.
- net-tools
- aws-cli
## Configuration
**awsautodns** configures itself by reading tags associated with the instance. The available configuration tags are as follows:
- `autodnsdomain` (Required) - The full domain name to point to. (ex. `dev.example.com`)
- `autodnshostedzoneid` (Required) - The Hosted Zone ID (ex. `Z119WBBTVP5WFX`)

**awsautodns** uses aws-cli to interact with AWS.
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
## Installation
Install all dependencies.
- Ubuntu (net-tools, aws-cli, gcc, make, git): 

	`sudo apt -y update && sudo apt -y install net-tools && sudo apt -y install gcc && sudo apt -y install make && sudo apt -y install git`
	
	If aws-cli is not already installed, install it.
	```
	sudo apt -y install unzip
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	rm awscliv2.zip
	sudo ./aws/install
	rm -rf aws/
	```

- Amazon Linux 2/RHEL (net-tools, aws-cli, gcc, make, git):

	`sudo yum -y update && sudo yum -y install net-tools && sudo yum -y install gcc && sudo yum -y install make && sudo yum -y install git`
	
	If aws-cli is not already installed, install it.
	```
	sudo yum -y install unzip
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	rm awscliv2.zip
	sudo ./aws/install -b /usr/sbin
	rm -rf aws/
	```
If you haven't already done so, configure aws-cli as root.
- The `Default output format` must be set to `json`
```
sudo su
aws configure && exit
```

Clone this repo.

`sudo git clone https://github.com/walia6/awsautodns.git`

Run the install bash file.
Note: In RHEL, the install script must set `SELINUX=disabled`, due to a bug with SELinux. This has security implications.

`sudo bash awsautodns/install.sh`
## Uninstallation
Uninstalling **awsautodns** is simple.
```
sudo systemctl stop awsautodns && sudo systemctl disable awsautodns
sudo rm -f /etc/systemd/system/awsautodns.service
sudo rm -rf /opt/awsautodns
```
If you wish to also remove the log file,

`sudo rm -f /var/log/awsautodns.log`.
