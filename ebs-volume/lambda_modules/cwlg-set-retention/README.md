# Module cwlg-set-retention

<br />

## Source
The main file is called index.py which is located in the ./source directory

<br />

## Dependencies and Packaging
All packages are nativly available to Lambda so nothing external needs to be packaged. Terraform is configured to zip up the source directory to create the Lambda package on runtime.

<br />

## Defining the retention
Using the boto3 library we can grab a list of all cloudwatch log groups in the account + region. If the name matches regex AND retention is default/not set (in the console shows as Never Expire) then set the retention period
