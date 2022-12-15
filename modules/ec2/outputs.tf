output "instance_id" {
  description = "The ID of the EC2"
  value = "${aws_instance.instance.id}"
}