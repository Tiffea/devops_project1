
moved {
  from = aws_iam_role_policy_attachment.S3-putObject_access_attachement
  to   = aws_iam_role_policy_attachment.S3-putObject_access_attachment
}