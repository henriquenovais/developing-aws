# Open Cloud9 through AWS Management Console

# Run CLI command to populate delete function requirements.txt
echo 'aws-xray-sdk==2.4.3' >> api/delete-function/requirements.txt

# check requirements.txt file
cat api/delete-function/requirements.txt

# deployed structures are described in api/template.yml
cd api/template.yml

# go to environment/api folder
cd ~/environment/api/

# adjust api bucket variable according to lab S3 resource name
apiBucket=labstack-669d4913-00cf-4cce-85ce-03e-pollynotesapi-uzm43ldbw0wl

# make sure all files are saved

# run SAM build command
 # The sam build command processes your AWS SAM template file, application code, and any applicable language-specific files and dependencies. The command also copies build artifacts in the format and location expected for subsequent steps in your workflow. You specify dependencies in a manifest file that you include in your application, such as requirements.txt for Python functions, package.json for Node.js functions, and .NET project files (*.csproj).
sam build --use-container

# run the SAM deploy command
sam deploy --stack-name polly-notes-api --s3-bucket $apiBucket --parameter-overrides apiBucket=$apiBucket

# open CloudWatch in AWS Management Console
AWS Management Console -> AWS search bar -> "CloudWatch" -> click on CloudWatch to proceed

# Select "Trace Map" in CloudWatch main menu, on the left
Move mouse to left side bar -> click "X Ray Traces" -> click "Traces Map"

# Try to delete a note through URL

# Error returns

# Go to "Trace Map" and see "DynamoDB"

# See in Logs why has an exception being thrown

# Error 502 is thrown because Lambda does not have the necessary permissions to delete from DynamoDB

# Go back to Cloud9 and change template.yml
line 115 -> Role: !Sub arn:aws:iam::${AWS::AccountId}:role/DynamoDBReadRole
Change to -> Role: !Sub arn:aws:iam::${AWS::AccountId}:role/DynamoDBWriteRole

# Rebuild and redeploy SAM
cd ~/environment/api/
sam build --use-container
sam deploy --stack-name polly-notes-api --s3-bucket $apiBucket --parameter-overrides apiBucket=$apiBucket

# Retest application DELETE note functionality


