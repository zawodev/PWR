variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for services"
  type        = string
  default     = "t3.micro"
}

variable "services" {
  description = "Names of microservices"
  type        = list(string)
  default     = ["booking","availability","payment","ticketing","notification"]
}

variable "service_ports" {
  description = "Map service → port"
  type        = map(number)
  default = {
    booking      = 8000
    availability = 8001
    payment      = 8002
    ticketing    = 8003
    notification = 8004
  }
}
