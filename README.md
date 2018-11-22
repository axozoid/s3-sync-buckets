# s3-sync-buckets

If you are tasked to copy existing buckets from one AWS account into a bucket in another AWS account, this solution should help you. 

Do `git clone git@github.com:axozoid/s3-sync-buckets.git` and let's get started.

# Task

Let's say we have 2 accounts:
- Source account (ACCOUNT_A);
- Destination account (ACCOUNT_B);

The task is to copy some buckets from ACCOUNT_A to a bucket in ACCOUNT_B.

# Solution

## Step 1. Create a destination bucket

Goto to the AWS console of ACCOUNT_B and create a bucket with the following bucket policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "ARN_OF_THE_USER_IN_ACCOUNT_A"
            },
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "ARN_OF_THE_BUCKET_IN_ACCOUNT_B/*",
                "ARN_OF_THE_BUCKET_IN_ACCOUNT_B"
            ]
        }
    ]
}
```


## Step 2. Create a user in the source account

Goto to the AWS console of ACCOUNT_A and create a user with **Programmatic access**. Make sure you download credentials.
Then create and attach an IAM policy to this user:

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
                "ARN_OF_THE_BUCKET_IN_ACCOUNT_B/*",
                "ARN_OF_THE_BUCKET_IN_ACCOUNT_B"
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

## Step 3. Preparing a list
Now we need to prepare a file containing details for syncing jobs.

An example line from this file would look like:

```
my-bucket-with-docs;my-new-bucket/backups;AKIAJWQI97LCRXN1L0QR;sPJ5nfJgcKinFevKGHN7AbHtQl1kPS3/dqplMMo2;k8s-bkp-cluster
```

This file contains lines with the following fields (separated by semicolon):
* 1st column - source bucket (my-bucket-with-docs)
* 2nd column - destination bucket (my-new-bucket/backups)
* 3rd column - AWS_ACCESS_KEY_ID (AKIAJWQI97LCRXN1L0QR)
* 4th column - AWS_SECRET_ACCESS_KEY (sPJ5nfJgcKinFevKGHN7AbHtQl1kPS3/dqplMMo2)
* 5th column - k8s namespace (k8s-bkp-cluster)

This structure allows us to have different credentials for all buckets, as well as a choise which kubernetes namespace to use.

> In case when we need to copy N-buckets from ACCOUNT_A to a bucket in ACCOUNT_B, columns [2-5] will be the same and only the first column is different (provided we launch the job in the same namespace, otherwise column 5 is also changes).

## Step 4. Generate and launch the backup jobs
Use script `generate-jobs.sh` to generate YAML files for k8s jobs (one file/job per bucket) and start them immediately.

Explanation:

The script requires the following arguments to be passed:
1. A file with a list of buckets - created in step 3;
2. A template file - `template_job.yaml`;

> You can also pass `true` as the 3rd argument if you only want to generate jobs' files without starting them in k8s.

When you run `./generate-jobs.sh buckets.csv my_template.yaml` the script will generate as many files as you have lines in your list file and run them in k8s as jobs.

## Step 5. Check status
You may check the status of the jobs by executing `kubectl -n <YOUR_K8S_NAMESPACE> get jobs`. 
