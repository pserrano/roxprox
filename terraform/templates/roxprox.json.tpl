[
    {
      "essential": true,
      "image": "in4it/roxprox:${ROXPROX_RELEASE}",
      "name": "roxprox",
      "command": ["-acme-contact", "${ACME_CONTACT}", "-storage-path", "/config", "-storage-type", "s3", "-storage-bucket", "${S3_BUCKET}", "-aws-region", "${AWS_REGION}", "-loglevel", "${LOGLEVEL}"],
      "logConfiguration": { 
              "logDriver": "awslogs",
              "options": { 
                 "awslogs-group" : "roxprox",
                 "awslogs-region": "${AWS_REGION}",
                 "awslogs-stream-prefix": "roxprox"
              }
       },
       "portMappings": [ 
          { 
             "containerPort": 8080,
             "hostPort": 8080,
             "protocol": "tcp"
          }
       ]
    }
  ]