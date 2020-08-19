#!/bin/bash

help=0

while getopts i:u:t:p:h flag

do
	case "${flag}" in
		i) identity_file=${OPTARG};;
		u) username=${OPTARG};;
		t) target_instance_ip=${OPTARG};;
		h) help=1
	esac
done

if [ $help -eq 1 ]
then
	echo ""
	echo "get_ec2_creds.sh - a tool for getting AWS credentials from an ec2 instance metadata service"
	echo "Requires a private key for an ec2 instance and the username and ip address for that instance"
	echo "Usage: get_ec2_creds.sh -i <identity file> -u <username> -t <target ip>"

	echo "Returns credentials pre-formatted for use in an ~/.aws/credentials file"
	echo "***NOTE*** Requires 'jq' (https://github.com/stedolan/jq) to function"
	echo ""
	exit
fi

if ! [ -r $identity_file ]
then
	echo ""
	echo ">>> $identity_file not found! <<<"
	echo ">>> Exiting... <<<"
	echo ""
	exit
fi

role_name=`ssh -i ./$identity_file $username@$target_instance_ip "curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials;echo ''" `

echo ""
echo "[ $profile ]"
ssh -i ./$identity_file $username@$target_instance_ip "curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$role_name; echo ''" | jq '  "aws_access_key_id = \(.AccessKeyId),aws_secret_acess_key = \(.SecretAccessKey),aws_session_token = \(.Token)" ' | sed 's/"//g' | sed 's/,/\n/g'
echo ""
