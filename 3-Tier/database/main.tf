resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.3"
  database_name           = "database1"
  master_username         = "admin"
  master_password         = "Password123"
   backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = var.database_grp_name
  vpc_security_group_ids = [var.security_database]
   skip_final_snapshot    = false
  final_snapshot_identifier = "my-final-snapshot"

 tags = {
    Name = "Aurora MySQL Cluster"
  }
}

# Create RDS Cluster Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = 2
  identifier         = "aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.r6g.2xlarge"
  engine              = aws_rds_cluster.default.engine
  engine_version      = aws_rds_cluster.default.engine_version
  publicly_accessible = false
  availability_zone   = element(["us-east-1a", "us-east-1b"], count.index) # Adjust based on your region
}
resource "aws_rds_cluster_snapshot" "example_snapshot" {
  db_cluster_snapshot_identifier = "my-final-snapshot"
  db_cluster_identifier          = aws_rds_cluster.default.id
}
