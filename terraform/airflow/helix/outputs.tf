output "mwaa_ip_addrs" {
  value = data.dns_a_record_set.mwaa
}

output "mwaa_alb_sg_id" {
  value = module.mwaa_alb_sg.id
}