# documentations used in the tutorial
https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html#table

# create lambda inside of AWS Console
# AWS Console -> Lambda -> function name "dictate-function" -> Python 3.11 -> use existing permission role -> "lambdaPollyRole" -> click on "create function"

# "lambdaPollyRole" policy for reference
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"dynamodb:DeleteItem",
				"dynamodb:PutItem",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:UpdateItem",
				"dynamodb:DescribeTable",
				"polly:SynthesizeSpeech",
				"s3:PutObject",
				"s3:GetObject",
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"lambda:TagResource"
			],
			"Resource": "*",
			"Effect": "Allow"
		}
	]
}

# open Cloud9 inside of AWS managemement console
# AWS Management Console -> Cloud9 -> Lab4

# add s3 bucket name into variable through terminal in Cloud9
apiBucket=labstack-669d4913-00cf-4cce-85-pollynotesapibucket-z9lombprcfld

# set notes table variable in Cloud9 terminal
notesTable='Notes'

# add two environment variables to lambda function in terminal
aws lambda update-function-configuration \
--function-name dictate-function \
--environment Variables="{MP3_BUCKET_NAME=$apiBucket, TABLE_NAME=$notesTable}"

# go to dictate function folder
cd ~/environment/api/dictate-function

# zip into file to be uploaded to the lambda
zip dictate-function.zip app.py

# upload zip file to the lambda
aws lambda update-function-code \
--function-name dictate-function \
--zip-file fileb://dictate-function.zip

# update lambda handler path since the handler is inside the app.py file
aws lambda update-function-configuration \
--function-name dictate-function \
--handler app.lambda_handler

# create event.json inside of "dictate-function" folder
cd ~/environment/api/dictate-function

# event.json file contents
{
  "UserId": "newbie",
  "NoteId": "2",
  "VoiceId": "Joey"
}

# invoke lambda and put response into a txt file that has s3 url to MP3 file
aws lambda invoke \
--function-name dictate-function \
--payload fileb://event.json response.txt

# invoke lambda manually through AWS Console
# AWS Console -> Lambda -> "dictate-function" -> "Test" tab -> Add new test event with the following JSON:
# name: testPolly
# event sharing: private
# template optional: hello world
# event json:
{
  "UserId": "newbie",
  "NoteId": "2",
  "VoiceId": "Joey"
}

# create a variable with the "lambdaPollyRole" policy
roleArn=$(aws iam list-roles --output text --query 'Roles[?contains(RoleName, `lambdaPollyRole`) == `true`].Arn')

# set "folderName" variable
folderName=createUpdate-function

# change function directory
cd ~/environment/api/$folderName

# create zip file for createUpdate-function
zip $folderName.zip app.py

# a help command that might assist
aws lambda create-function help

# create the function by running an AWS CLI command
aws lambda create-function \
--function-name $folderName  \
--handler app.lambda_handler \
--runtime python3.11 \
--role $roleArn \
--environment Variables={TABLE_NAME=$notesTable} \
--zip-file fileb://$folderName.zip

# change folder name and repeat previous four commands to create a new lambda for each
folderName=delete-function
folderName=list-function
folderName=search-function

# test invoke each function through terminal
aws lambda invoke \
--function-name $folderName \
--payload fileb://event.json response.txt
