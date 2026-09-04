

########################################################################################
#--------------------- SSH open protocol for remote instance control ------------------#
#--------------------------------------------------------------------------------------#


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
              "token.actions.githubusercontent.com:sub" = "repo:Tiffea/devops_project1:*"
            }
          }
        }
      ]
  })
}

#custom policy -> need description
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
            "ec2:RevokeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupIngress"
          ],
          Resource = aws_security_group.devops1_sg.arn
        }
      ]
  })
}
#linking
resource "aws_iam_role_policy_attachment" "github_worker" {
  role       = aws_iam_role.github_worker.name
  policy_arn = aws_iam_policy.github_worker.arn
}

########################################################################################
#--------------------- Assume role for EC2 DB inctance --------------------------------#
#--------------------------------------------------------------------------------------#

resource "aws_iam_role" "Role-for-EC2" {
  name        = "Role-for-EC2"
  description = "assume role on instances" #description can be changed on a place
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
# "I want that agent to help me hereby I agree use if I take this role on an instance"
resource "aws_iam_role_policy_attachment" "SSM_attachment_db" {
  role       = aws_iam_role.Role-for-EC2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

##EC2 cannot attach to a role without this resourse
resource "aws_iam_instance_profile" "DB_instance_profile" {
  name = "Role-for-EC2"
  role = aws_iam_role.Role-for-EC2.name
}

########################################################################################
#--------------------- SMM CONNECTION POLICY -- ---------------------------------------#
#--------------------------------------------------------------------------------------#

resource "aws_iam_policy" "SSMconnection_policy" {
  name        = "SSMconnection_policy"
  description = "give rights to open ssm session "
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        #allow connection between instance and SSM bot
        {
          Effect = "Allow",
          Action = "ssm:StartSession",
          Resource = [
            "arn:aws:ec2:eu-north-1:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.server_for_db.id}",
            "arn:aws:ssm:*:*:document/AWS-StartSSHSession"
            #amazon-ssm-agent as a daemon process that listens to aws
          ]
        },
        #open channel to transmit data
        {
          Effect   = "Allow",
          Action   = "ssmmessages:OpenDataChannel",
          Resource = "arn:aws:ssm:*:*:session/$${aws:userid}-*"
          #user id is used for preventing 3rd party interuptions

        }
      ]
    }
  )
}

#linking
resource "aws_iam_role_policy_attachment" "SSM_policy_attachment_db" {
  role       = aws_iam_role.github_worker.name
  policy_arn = aws_iam_policy.SSMconnection_policy.arn
}

########################################################################################
#--------------------- CUSTOM S3 POLICY FOR DB INSTANCE-- ---------------------------------------#
#--------------------------------------------------------------------------------------#

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

resource "aws_iam_role_policy_attachment" "S3-putObject_access_attachement" {
  role       = aws_iam_role.Role-for-EC2.name
  policy_arn = aws_iam_policy.S3-putObject_access.arn
}