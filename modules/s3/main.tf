# --------------------------
# Creation of the bucket S3
# --------------------------

resource "aws_s3_bucket" "my-bucket" {
 bucket = "Write your bucket name"
}
 
resource "aws_s3_object" "data-users" {
 bucket = aws_s3_bucket.my-bucket.id
 key    = "data-users/"
}
 
resource "aws_s3_object" "projects-folder" {
 bucket = aws_s3_bucket.my-bucket.id
 key    = "projects/"
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.my-bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# -------------------------------------
# Creation of endpoints for the bucket
# -------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc-id
  service_name      = "com.amazonaws.eu-west-2.s3"
}

# ----------------------------------------------------------
# Association between the route table and the endpoint
# ----------------------------------------------------------

resource "aws_vpc_endpoint_route_table_association" "route-private-subnets-S3" {
  route_table_id = var.private-subnets-rt-id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}