
#SECTION - github CI/CD: Open port 22 > deploy > close port
#NOTE - check if github is allowed to open only this port (not written clearly)

# json role - allow github bot to assume role
resource "aws_iam_role" "github_worker" {
  name        = "github_worker"
  description = "Role includes 2 permissions: open port 22 and then close it"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
          },
          Action = "sts:AssumeRoleWithWebIdentity",
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            },
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "repo:Tiffea/devops_project1:environment:prod"
            }
          }
        }
      ]
  })
}

# json policy - allows github to open and close ports
resource "aws_iam_policy" "github_worker" {
  name        = "github-actions-sg-toggle-role"
  description = "for github actions"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid    = "VisualEditor0",
          Effect = "Allow",
          Action = [
            "ec2:RevokeSecurityGroupIngress", # close ssh (delete inboud rule)
            "ec2:AuthorizeSecurityGroupIngress" # open ssh (add inboud rule)
          ],
          Resource = aws_security_group.devops1_sg.arn
        }
      ]
  })
}

# linking policy arm and role name
resource "aws_iam_role_policy_attachment" "github_worker" {
  role       = aws_iam_role.github_worker.name
  policy_arn = aws_iam_policy.github_worker.arn
}
#!SECTION

#SECTION - Role-for-EC2: attach a role for EC2

# json policy - allow ssm for EC2 service
resource "aws_iam_role" "Role-for-EC2" {
  name        = "Role-for-EC2"
  description = "assume role on instances" # description can be changed on a place
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# linking policy arm and role name
resource "aws_iam_role_policy_attachment" "SSM_attachment_db" {
  role       = aws_iam_role.Role-for-EC2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # policy is already wirtten by AWS
}

# instance profile attaches role to DB instance
resource "aws_iam_instance_profile" "DB_instance_profile" {
  name = "Role-for-EC2"
  role = aws_iam_role.Role-for-EC2.name
}
#!SECTION

#SECTION - action policy for SSM on DB instance

resource "aws_iam_policy" "SSMconnection_policy" {
  name        = "SSMconnection_policy"
  description = "give rights to open ssm session "
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        # allow connection between instance and SSM bot
        {
          Effect = "Allow",
          Action = "ssm:StartSession",
          Resource = [
            "arn:aws:ec2:eu-north-1:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.server_for_db.id}",
            "arn:aws:ssm:*:*:document/AWS-StartSSHSession"
            # amazon-ssm-agent as a daemon process that listens to aws
          ]
        },
        # open channel to transmit data
        {
          Effect   = "Allow",
          Action   = "ssmmessages:OpenDataChannel",
          Resource = "arn:aws:ssm:*:*:session/$${aws:userid}-*"
          # user id is used for preventing 3rd party interuptions

        }
      ]
    }
  )
}

# linking
resource "aws_iam_role_policy_attachment" "SSM_policy_attachment_db" {
  role       = aws_iam_role.github_worker.name
  policy_arn = aws_iam_policy.SSMconnection_policy.arn
}

#!SECTION

#SECTION - S3 custom bucket policy

resource "aws_iam_policy" "S3-putObject_access" {
  name        = "s3-Backup_policy"
  description = "this policy allows to put objects into a bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.devops1_bucket1.arn}/*"
      }
    ]
  })
}

# linking policy arm and role name
resource "aws_iam_role_policy_attachment" "S3-putObject_access_attachment" {
  role       = aws_iam_role.Role-for-EC2.name
  policy_arn = aws_iam_policy.S3-putObject_access.arn
}
#!SECTION

#Section - separate policy for Get action (least priveledge attitude - separate write / read )

resource "aws_iam_policy" "S3-getObject_access" {
  name        = "s3-Backup_policy-get-access"
  description = "this policy allows to get objects from a bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.devops1_bucket1.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role" "GetObject_role" {
  name = "GetObject_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn #how will perform this action: can also be Federated or Service
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "GetObject_access_policy_attachement" {
  role = aws_iam_role.GetObject_role.name
  policy_arn = aws_iam_policy.S3-getObject_access.arn
}
#!SECTION 

#Policy for CI tf state check
resource "aws_iam_role" "Github_tf-CI-ops_role" {
  name = "Github-tf-CI-ops-role"
  description = "Role for CI github tf-config secutiry check via OPA/conftest"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Tiffea/devops_project1:*"
          }
        }
      }
  })
}

resource "aws_iam_role_policy_attachment" "tf_CI_ViewOnly-attachment" {
  role = aws_iam_role.Github_tf-CI-ops_role.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_policy" "tf-lock_table_access" {
  name = "tf-state-lock-access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
      Resource = "arn:aws:dynamodb:eu-north-1:${data.aws_caller_identity.current.account_id}:table/DynamoDB-for-tfstate"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tf-lock-attachement" {
  role = aws_iam_role.Github_tf-CI-ops_role.name
  policy_arn = aws_iam_policy.tf-lock_table_access.arn
}