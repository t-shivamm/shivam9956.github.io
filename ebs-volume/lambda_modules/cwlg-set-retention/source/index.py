"""Sets retention on Cloudwatch Log Groups that are not set aka Never expire"""
import logging
import boto3
import os
import json
import re

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event, context):

    # Controls whether to run or skip the actual setting of retention periods
    enable_set_retention_action = True if os.environ['enable_set_retention_action'] == "true" else False

    # Create AWS client
    cwlogs_client = boto3.client('logs', os.environ['AWS_REGION'])

    # Load definition on how to classify log groups by name regex
    class_defs = json.loads(os.environ['classification_json'])

    # Paginator containing all Cloudwatch Log Groups in the account + region
    paginator = cwlogs_client.get_paginator('describe_log_groups')

    # Iterate through paginator
    for response in paginator.paginate():
        # For each log group
        for lg in response['logGroups']:
            # Skip if retention is already set (if not set it will show as Never expire in the console)
            if "retentionInDays" not in lg:
                # for each classification in the json, if the log group name matches the regex
                # then update the retention period. N.B. First regex match takes precedence
                for class_def in class_defs:
                    if re.search(class_def["regex"], lg["logGroupName"]):
                        # Update the retention setting
                        if enable_set_retention_action:
                            cwlogs_client.put_retention_policy(
                                logGroupName=lg['logGroupName'],
                                retentionInDays = class_def["retention_in_days"]
                            )
                        LOGGER.info("{0}Log group {1} has been classed as {2} and now has a retention of {3}".format((\
                            "" if enable_set_retention_action else "Log Only: "),\
                            lg["logGroupName"],\
                            class_def["classification"],\
                            class_def["retention_in_days"]))
                        break
