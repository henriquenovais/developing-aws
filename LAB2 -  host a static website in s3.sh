# run script to create new bucket
cd ~/environment
python labRepo/create-bucket.py

# run script to upload an object to s3
cd ~/environment
python labRepo/create-object.py

# run script to convert json to csv
cd ~/environment
python labRepo/convert-csv-to-json.py

#create a new variable:
mybucket=notes-bucket-654470955

# check variable name with:
echo $mybucket

# update public access block to s3 bucket
aws s3api put-public-access-block --bucket $mybucket --public-access-block-configuration "BlockPublicPolicy=false,RestrictPublicBuckets=false"

# sync folder with bucket html files
aws s3 sync ~/environment/labRepo/html/. s3://$mybucket/

# enable s3 website hosting
aws s3api put-bucket-website --bucket $mybucket --website-configuration file://~/environment/labRepo/website.json

# change bucket name in policy
sed -i "s/\[BUCKET\]/$mybucket/g" ~/environment/labRepo/policy.json

# verify if policy change went correctly
cat ~/environment/labRepo/policy.json

# apply policy to bucket
aws s3api put-bucket-policy --bucket $mybucket --policy file://~/environment/labRepo/policy.json

# set region to a variable
region=$(curl http://169.254.169.254/latest/meta-data/placement/region -s)

# print command to show website url
printf "\nYou can now access the website at:\nhttp://$mybucket.s3-website.$region.amazonaws.com\n\n"
