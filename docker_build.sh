docker build -t homeautomation .
docker tag homeautomation:latest 565409713405.dkr.ecr.ap-southeast-2.amazonaws.com/homeautomation:latest
docker push 565409713405.dkr.ecr.ap-southeast-2.amazonaws.com/homeautomation:latest
