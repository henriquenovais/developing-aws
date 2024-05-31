# access Amazon Cognito through AWS Management Console
AWS Management Console -> AWS Search Bar -> input "Cognito" -> Confirm

# inside of Cognito, choose to create a new user pool

# Cognito user pool configuration options
Provider types: Cognito User Pool
Sign-in options: User Name

# click on "Next" for Cognito user pool creation

# configure security requirements for Cognito user pool
# many options won't be needed since this is just an exercise
Password policy mode: "Custom"
Password minimum length: 6
Password requirements: 
	Untoogle the following:
		Contains at least 1 number
		Contains at least 1 special character
		Contains at least 1 uppercase letter
		Contains at least 1 lowercase letter
Multi-factor authentication: No MFA
User account recovery: untoogle self-service recovery

# click on next for the rest of the configuration
 Self-service registration: enabled
 Cognito-assisted verification and confirmation: dont automatically send confirmation
 	# leave the rest of the options as is by default: no required attributes and no optional attributes

# click next for further configuration of new Cognito user pool

# next options in Cognito user pool
Email: Send email with Cognito

# click next for further configuration of new Cognito user pool

# next options in Cognito user pool
User pool name: PollyNotesPool
Hosted authentication pages: Do not use Cognito Hosted UI
App type: Public client
App client name: PollyNotesWeb
Client secret: Don’t generate a client secret

# click next for further configuration of new Cognito user pool

# review properties and click on "Review and Create"

# on the Amazon Cognito menu, click on "PollyNotesPool" user pool

# save User Pool Id and User Pool ARN information from "PollyNotesPool"
us-east-1_MIleApD3t
arn:aws:cognito-idp:us-east-1:814000301453:userpool/us-east-1_MIleApD3t

# go to "App Integration" tab within Cognito

# Move to "App Client List" section within "App Integration" tab

# Save the Client Id information
6l2mqg88l8at1poadiqbbc157

# access lab development code inside of Cloud9

# create API URL variable with information from API url of the LAB
apiURL=https://64ti58qpsk.execute-api.us-east-1.amazonaws.com/Prod

# create variable with Cognito Pool Id saved from step before
CognitoPoolId=us-east-1_MIleApD3t

# create variable with application client id from step before
AppClientId=6l2mqg88l8at1poadiqbbc157

# create new Amazon Cognito user named "student" through CLI
aws cognito-idp sign-up --client-id $AppClientId --username student --password student

# confirm "student" user creation
aws cognito-idp admin-confirm-sign-up --user-pool-id $CognitoPoolId --username student

# in the AWS Management Console, check for "student" user within Amazon Cognito "PollyNotesPool"
	# the "student" user must be "Confirmed" and "Enabled"
	
# access the test login page provided in the Lab
	#URL temporary provided for the lab
		#test the "student" user
http://labstack-669d4913-00cf-4cce-85ce-0-testloginbucket-0zcf1ueon1nq.s3-website-us-east-1.amazonaws.com
	#this webpage will generate a JWT token that will be used in next steps
	
# move AWS Management Console to AWS API Gateway
	# must add Cognito already created user pool as authorizer for the api
	
# choose "/notes" API

# on the left side bar, go to "Authorizers"

# click on create authorizer option

# add the following configuration to authorizer to be created
Authorizer name: PollyNotesPool
Authorizer type: Cognito
Cognito user pool: PollyNotesPool
Token source: Authorization
Token validation: leave field empty

# click on "Create Authorizer" button

# you will be redirected to the list of authorizers available

# choose PollyNotesPool, the authorizer you just created

# click on "Test authorizer" button

# will return 401 since there is no token

# input token previously generated on Cognito test website

# will return 200

# adjust "Resources" within API Gateway to use information from Cognito user
	# Adjust "GET /notes" in "Method request" tab with "PollyNotesPool" under "Cognito pool of authorizers"
	# Adjust "GET /notes" in "Integration request" tab with a new mapping template that uses Cognito user information:
	{
    		"UserId": "$context.authorizer.claims['cognito:username']"
	}
	# Adjust "POST /notes" in "Method request" tab with "PollyNotesPool" under "Cognito pool of authorizers"
	# Adjust "POST /notes" in "Integration request" tab with a new mapping template that uses Cognito user information:
	{
	    "UserId": "$context.authorizer.claims['cognito:username']",
	    "NoteId": $input.json('$.NoteId'),
	    "Note": $input.json('$.Note')
	}

# go back to AWS Cloud9 to replace some variables to use a placeholder
	# these commands customize the swagger API according to the usage needed here
region=$(curl http://169.254.169.254/latest/meta-data/placement/region -s)
acct=$(aws sts get-caller-identity --output text --query "Account")
poolId=$(aws cognito-idp list-user-pools --max-results 1 --output text --query "UserPools[].Id")
poolArn="arn:aws:cognito-idp:$region:$acct:userpool/$poolId"

sed -i "s~\[Cognito_Pool_ARN\]~$poolArn~g" ~/environment/api/PollyNotesAPI-swagger.yaml
sed -i "s~\[AWS_Region\]~$region~g" ~/environment/api/PollyNotesAPI-swagger.yaml
sed -i "s~\[AWS_AccountId\]~$acct~g" ~/environment/api/PollyNotesAPI-swagger.yaml

# expand the api folder and open PollyNotesAPI-swagger.yaml
	# swagger describes the implemented API to be used through AWS

# merge the new swagger file with the existing API through CLI
cd ~/environment/api
apiId=$(aws apigateway get-rest-apis --query "items[?name == 'PollyNotesAPI'].id" --output text)
aws apigateway put-rest-api --rest-api-id $apiId --mode merge --body 'fileb://PollyNotesAPI-swagger.yaml'
aws apigateway create-deployment --rest-api-id $apiId --stage-name Prod

# grant the API Gateway access to the Lambdas since the Swagger is hosted on API Gateway and will trigger the Lambdas
aws lambda add-permission --function-name delete-function --statement-id apiInvoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com

aws lambda add-permission --function-name dictate-function --statement-id apiInvoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com

aws lambda add-permission --function-name search-function --statement-id apiInvoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com

# new resources are now available within API Gateway imported from Swagger file
	# Swagger .yaml files are a great way to back up API configurations

# update place holder variables again to use web frontend of the lab through CLI
sed -i "s~\[UserPoolId\]~$CognitoPoolId~g" ~/environment/web/src/Config.js
sed -i "s~\[AppClientId\]~$AppClientId~g" ~/environment/web/src/Config.js
sed -i "s~\[ApiURL\]~$apiURL~g" ~/environment/web/src/Config.js

# run npm install of the application within Cloud9
cd ~/environment/web
npm install

# build test and build
npm run test+build

# create a variable for the S3 webucket used for hosting the application
webBucket=labstack-669d4913-00cf-4cce-85ce-03e-pollynotesweb-ccyoav9oavs5

# sync folder into S3
	# "aws s3 sync --delete" command was used here to recursively update files from the source build directory the Amazon S3 bucket and remove any files that are no longer in the source directory. A local file will require uploading if the size of the local file is different than the size of the s3 object, the last modified time of the local file is newer than the last modified time of the s3 object, or the local file does not exist under the specified bucket and prefix.
aws s3 sync --delete build/. s3://$webBucket

