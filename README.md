# s3-sync-buckets

If you are tasked to copy existing buckets in your account into a bucket in another account, this solution should help you.

# Task

Let's say we have 2 accounts:
- Source account (ACCOUNT_A);
- Destination account (ACCOUNT_B);

The task is to copy some buckets from ACCOUNT_A to a bucket in ACCOUNT_B.

# Solution

Step 1. Create a destination bucket

Goto to the AWS console of ACCOUNT_B and create a bucket.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "**ARN_OF_THE_USER_IN_ACCOUNT_A**"
            },
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "**ARN_OF_THE_BUCKET_IN_ACCOUNT_B/***",
                "**ARN_OF_THE_BUCKET_IN_ACCOUNT_B**"
            ]
        }
    ]
}
```


Step 2.

Goto to AWS console of ACCOUNT_A and create a user with the following IAM policy attached:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "WriteToRemoteBucket",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "**ARN_OF_THE_BUCKET_IN_ACCOUNT_B/***",
                "**ARN_OF_THE_BUCKET_IN_ACCOUNT_B**"
            ]
        },
        {
            "Sid": "ReadAccessToLocalBuckets",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        }
    ]
}```


