#! /bin/sh
yum update -y
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
docker pull 678727778487.dkr.ecr.ap-southeast-2.amazonaws.com/docker-images:latest
docker run -p 80:3000  678727778487.dkr.ecr.ap-southeast-2.amazonaws.com/docker-images:latest
