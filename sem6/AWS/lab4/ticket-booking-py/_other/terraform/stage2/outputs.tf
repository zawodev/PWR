output "service_ips" {
  description = "Public IPs of each microservice EC2"
  value = {
    for name, inst in aws_instance.svc :
    name => inst.public_ip
  }
}
