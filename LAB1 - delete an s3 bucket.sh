# disable temporary credentials in AWS Cloud 9
# Gear icon > AWS Settings > Disable temporary credentials

# check if temporary credentials can be removed
rm /home/ec2-user/.aws/credentials

# configure profile
aws configure
	default region: REGION
	default output format: yaml
	
# check command that authenticates the requests
aws sts get-caller-identity

# verify aws toolkit
check AWS icon inside of Cloud9

# verify if you can view S3 and verify IAM permissions
aws s3 ls

# save to environment variable a bucket with "deleteme" inside of the variables
bucketToDelete=$(aws s3api list-buckets --output text --query 'Buckets[?contains(Name, `deletemebucket`) == `true`] | [0].Name')

# command to delete `deletemebucket`
aws s3 rb s3://$bucketToDelete

# debug to check out why it can't be deleted
aws s3 rb s3://$bucketToDelete --debug

# wont be able to delete, no permissions

# add profile policy to delete bucket
policyArn=$(aws iam list-policies --output text --query 'Policies[?PolicyName == `S3-Delete-Bucket-Policy`].Arn')

# review created policy
aws iam get-policy-version --policy-arn $policyArn --version-id v1

# attach policy 
aws iam attach-role-policy --policy-arn $policyArn --role-name notes-application-role

# review attached policy
aws iam list-attached-role-policies --role-name notes-application-role

# try to delete bucket again
aws s3 rb s3://$bucketToDelete

# verify all buckets
aws s3 ls

# bucket must have been deleted


