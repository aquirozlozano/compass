resource "aws_mwaa_environment" "helix-mwaa" {
  source_bucket_arn              = "arn:aws:s3:::compass-data-mwaa"
  airflow_version                = "2.2.2"
  dag_s3_path                    = "${var.prefix}/dags/"
  execution_role_arn             = aws_iam_role.helix_mwaa_execution_role.arn
  plugins_s3_path                = "${var.prefix}/plugins.zip"
  plugins_s3_object_version      = aws_s3_object.plugins_zip.version_id
  requirements_s3_path           = "${var.prefix}/requirements.txt"
  requirements_s3_object_version = aws_s3_object.requirements_txt.version_id
  name                           = var.prefix
  environment_class              = "mw1.large"

  network_configuration {
    security_group_ids = [module.mwaa_scheduler_sg.id]
    subnet_ids         = slice(data.terraform_remote_state.cnvrg.outputs.private_subnets_id, 0, 2)
  }

  airflow_configuration_options = {
    "core.default_task_retries" = 3
    "core.parallelism"          = 40
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "ERROR"
    }

    worker_logs {
      enabled   = true
      log_level = "CRITICAL"
    }
  }
}

# Get private IPs of MWAA VPC Endpoint using a DNS lookup
# The VPC Endpoint is managed by MWAA, and the IPs are not exposed via any
# Terraform resource directly
data "dns_a_record_set" "mwaa" {
  host = aws_mwaa_environment.helix-mwaa.webserver_url
}