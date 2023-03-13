module "mwaa_scheduler_sg" {
  source      = "git@github.com:compassinc/tf-module-ec2-security-group?ref=v1.0.2"
  name        = "${var.prefix}-airflow-scheduler-prod"
  description = "Security Group for the MWAA Scheduler - prod"
  vpc_id      = data.terraform_remote_state.cnvrg.outputs.vpc_id

  ingress_with_self = {
    "0" = [0, 0, "-1"]
  }

  ingress_with_source_sg = {
    "0" = [443, 443, "tcp", module.mwaa_alb_sg.id]
  }

  egress_rules = {
    "0" = [0, 0, "-1", "0.0.0.0/0"]
  }
}

module "mwaa_alb_sg" {
  source      = "git@github.com:compassinc/tf-module-ec2-security-group?ref=v1.0.2"
  name        = "${var.prefix}-airflow-alb-prod"
  description = "Security Group for the MWAA ALB - prod"
  vpc_id      = data.terraform_remote_state.cnvrg.outputs.vpc_id

  ingress_rules = {
    "0" = [443, 443, "tcp", "${data.terraform_remote_state.main-vpc.outputs.office_cidr_blocks}"]
  }

  egress_rules = {
    "0" = [0, 0, "-1", "0.0.0.0/0"]
  }
}