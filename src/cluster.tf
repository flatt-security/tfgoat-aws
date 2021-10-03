
resource "aws_iam_role" "tfgoat-cluster" {
  name = "${local.prefix}-tfgoat-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "tfgoat-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tfgoat-cluster.name
}

resource "aws_iam_role_policy_attachment" "tfgoat-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.tfgoat-cluster.name
}

resource "aws_security_group" "tfgoat-cluster" {
  name        = "${local.prefix}-tfgoat-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.tfgoat.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            
    # [Shisho]: remove `0.0.0.0/0` from the following line and add appropriate IP ranges
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "tfgoat-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.tfgoat-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "tfgoat" {
  name     = "${local.prefix}-tfgoat-cluster"
  role_arn = aws_iam_role.tfgoat-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.tfgoat-cluster.id]
    subnet_ids         = aws_subnet.tfgoat[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.tfgoat-cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.tfgoat-cluster-AmazonEKSVPCResourceController,
  ]
}
