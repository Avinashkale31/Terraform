resource "aws_iam_role" "ec2" {
  name = "ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"  # Replace with the appropriate service if needed
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_readonly_attachment" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_three_tier_instance_profile" {
  name = "ec2-three-tier-instance-profile"
  role = aws_iam_role.ec2.name
}
