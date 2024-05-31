# This Lab objective is to use AWS API Gateway to call lambda functions inside of AWS

# search for AWS API Gateway in Management Console
AWS Management Console -> search bar -> "API Gateway" -> click

# create REST API in AWS API Gateway
Create API -> Rest API -> click "Create API" button

# create resource for REST API
click "Create Resource" button -> make sure "Proxy Resource" is untoggled -> resource name is "notes" -> enable CORS (Cross Origin Resource Sharing)

# create method for new resource "/notes"
select "/notes" resource -> click on "Create Method" button

# insert method configurations
Method type: GET
Lambda function: arn that has list-function in it
Click on create method after

# test GET method within Lambda
Select "GET" method in "/notes" resource -> click on "Test" tab -> click on "Test" button

# adjust integration request within "GET /notes"
Near the "Test" tab, see to the "Integration request" hyperlink or the "Intergration request" tab
Click on "Edit"
Go to "Mapping templates" section
Click "Add mapping templates"
Mapping template type configuration should be:
	Type: "application/json"
	Content of the mapping template is:
	{"UserId":"student"}

# test "GET /notes" again
Now response JSON will only have notes from UserId "student"

# change "Integration response"
Click on "Integration response" tab -> Add mapping template -> Type is "application/json" -> content is:
#set($inputRoot = $input.path('$'))

[
    #foreach($elem in $inputRoot)
    {
        "NoteId" : "$elem.NoteId",
        "Note" : "$elem.Note"
    }
    #if($foreach.hasNext),#end
    #end
]

# test "GET /notes" again
Now response JSON does not have "UserId" property within the JSON response, witch reduces data being returned in the API
	Reduces cost and removes unnecessary data since "UserId" is redundant
		"UserId" is used as an input for the "GET /notes"

# create "POST /notes"
Create new method under resource "/notes"
Use "POST"  for method and application/json

# test "POST /notes"
Use the following JSON to test if the method works:
{
    "Note": "This is your new note added using the POST method",
    "NoteId": 3,
    "UserId": "student"
}

# test "GET /notes" to see if note added through "POST /notes" is there

# create a new Model
on the left side menu, click on "Models"
Click on "Create model" button

# new model configuration
Model name: NoteModel
Content-type: application/json
Model schema:
{
    "title": "Note",
    "type": "object",
    "properties": {
        "UserId": {"type": "string"},
        "NoteId": {"type": "integer"},
        "Note": {"type": "string"}
    },
    "required": ["UserId", "NoteId", "Note"]
}

# go to "POST /notes" within API Gateway

# go to "Method Request" tab

# edit "Method Request" setttings

# add "Request Body" into "Request validator" field

# add "Request Body" model that was created on previous step ("NoteModel")

# test "POST /notes" again with the following payload

{
    "Note": "This is your updated note using the Model validation",
    "UserId": "student",
    "id": 3
}

# request will fail since there is no "NoteId" property in the request body

# body of the request is now being validated by API Gateway

# test "POST /notes" with the following payload for successful request:

{
    "Note": "This is your updated note using the Model validation",
    "UserId": "student",
    "NoteId": 3
}

# request successful !

# enable CORS in the resources view

# check Default 4XX and 5XX checkboxes

# check all methods created: GET, POST and OPTIONS

# Click on "Enable CORS" button

# Wait for pop-up to disapear

# CORS is enabled!!!

# deploy API through API Gateway: go to resources view and "Deploy API"

# create a new stage: PROD

# click on "deploy" button

# API deployed! Copy URL to use it within AWS!

# Test access "$url/notes" to see GET method working! 
