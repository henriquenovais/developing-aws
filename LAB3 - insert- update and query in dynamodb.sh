# go to env
cd ~/environment

# run create table script
python labRepo/createTable.py

# run command to load data from DynamoDB
python labRepo/loadData.py

# run command to query data from DynamoDB
python labRepo/queryData.py

# run command to scan data from DynamoDB table
python labRepo/paginateTable.py

# run command to update table data from DynamoDB
python labRepo/updateItem.py

#run command to query data in DynamoDB using PartiQL
python labRepo/partiQL.py


