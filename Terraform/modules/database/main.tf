# /////////////////////// creating the subnrt Group ////////////////////////////
resource "aws_db_subnet_group" "my-subnet-gp" {
  name       = "main-subnet-gp"
  subnet_ids = var.subnet-ids
}
# /////////////////////// creating DocumentDb cluster  ////////////////////////////
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier   = "my-docdb"
  master_username      = var.db_username
  master_password      = var.db_password
  skip_final_snapshot  = true
  apply_immediately    = true
  db_subnet_group_name = aws_db_subnet_group.my-subnet-gp.name
}

# /////////////////////// creating DocumentDb Instance  ////////////////////////////
resource "aws_docdb_cluster_instance" "docdb_instance" {
  count              = 2
  identifier         = "my-docdb-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
  availability_zone  = var.azs[count.index % length(var.azs)]

}

# ///////////////////// Creating the MongoDB URL ///////////////////////
locals {
  # mongo_uri = "mongodb://root:${var.db_password}@{aws_docdb_cluster.docdb endpoint}:27017/?tls=true&tlsCAFile=global-bundle.pem&retryWrites=false"
  mongo_uri = "mongodb://${var.db_username}:${var.db_password}@${aws_docdb_cluster.docdb.endpoint}:27017/mydb?tls=true&retryWrites=false"
}


# /////////////////////// Craeting SSM parameter for MongoDb URL //////////////////
resource "aws_ssm_parameter" "mongo_uri" {
  name  = "/backend/MONGO_URI"
  type  = "SecureString"
  value = local.mongo_uri
}
