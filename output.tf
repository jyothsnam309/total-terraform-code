#create the data source

output "zones" {
  value = data.aws_availability_zones.available.names
}


output "vpc" {
  value = aws_vpc.dev-vpc.id
}

output "countofaz" {
  value = length(data.aws_availability_zones.available.names)
}