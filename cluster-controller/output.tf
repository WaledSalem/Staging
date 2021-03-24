output "kube-pub-ip"{
    value = aws_eip.main.public_ip
}