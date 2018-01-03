{
  "Id": "trussworks-aws-logs",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": [
            "public-read",
            "public-read-write"
          ]
        }
      },
      "Effect": "Deny",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${bucket}/*",
      "Sid": "ensure-private-read-write"
    },
    {
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::${bucket}",
      "Sid": "cloudtrail-logs-get-bucket-acl"
    },
    {
      "Action": "s3:PutObject",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::${bucket}/${cloudtrail_logs_prefix}/*",
      "Sid": "cloudtrail-logs-put-object"
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${elb_log_account_arn}"
        ]
      },
      "Resource": "arn:aws:s3:::${bucket}/${elb_logs_prefix}/*",
      "Sid": "elb-logs-put-object"
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${elb_log_account_arn}"
        ]
      },
      "Resource": "arn:aws:s3:::${bucket}/${alb_logs_prefix}/*",
      "Sid": "alb-logs-put-object"
    },
    {
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${redshift_log_account_id}:user/logs"
      },
      "Resource": "arn:aws:s3:::${bucket}/${redshift_logs_prefix}/*",
      "Sid": "redshift-logs-put-object"
    },
    {
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${redshift_log_account_id}:user/logs"
      },
      "Resource": "arn:aws:s3:::${bucket}",
      "Sid": "redshift-logs-get-bucket-acl"
    },
    {
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Resource": "arn:aws:s3:::${bucket}",
      "Sid": "config-permissions-check"
    },
    {
      "Action": "s3:PutObject",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "config.amazonaws.com"
        ]
      },
      "Resource": "arn:aws:s3:::${bucket}/${config_logs_prefix}/*",
      "Sid": " config-bucket-delivery"
    }
  ],
  "Version": "2012-10-17"
}
