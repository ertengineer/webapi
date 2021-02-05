[![Build Status](https://travis-ci.org/msepahvand/dotnetcore-docker.svg?branch=master)](https://travis-ci.org/msepahvand/dotnetcore-docker)

### Running locally

1) `docker build -t studentapi .`

2) Create a network:
`docker network create studentapi-network`

3) Start the SQL Server container and put it in a network: 
`docker run --net=studentapi-network -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Password1!" -p 1433:1433 --name sqlserver -d microsoft/mssql-server-linux`

4) Run the API container, put it in the same network:
`docker run --net=studentapi-network --rm -p 5000:5000 -e "DatabaseServer=sqlserver" -e "DatabaseUserPassword=Password1!" studentapi`

**Helpful docker commands**

List all containers: `docker ps -a`

Stop all containers: `docker stop $(docker ps -aq)`

Remove all containers: `docker rm $(docker ps -aq)`


### Deploy to ECS

The ECS CLI allows us to deploy multi container apps with docker-compose. Currently ECS only supports version 2 of the docker-compose syntax.
More about the [gotchas of docker-compose on the ECS CLI].

**Linux**
1) Install the ECS CLI:
`sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest`
`sudo chmod +x /usr/local/bin/ecs-cli`

2) Configure the ECS CLI
`ecs-cli configure --region ap-southeast-2 --access-key AWS_ACCESS_KEY --secret-key AWS_SECRET_KEY --cluster studentapi-demo`

3) Create an ECS cluster
Here we create an ECS cluster which is 1 instance of type t2.medium, note that we need to generate a key pair in EC2 dashboard which maps to `EC2_KEY_PAIR_NAME` here
`ecs-cli up --keypair EC2_KEY_PAIR_NAME --capability-iam --size 1 --instance-type t2.medium --force`

4) Create and start an ECS task
Create an ECS task definition and run the containers (From a directory containing a `docker-compose.yml`):
`ecs-cli compose up`

5) List running containers (Gives you the status of the container cluster and if running the public IP)
`ecs-cli compose ps`

**Windows**
[Install and configure the ECS CLI] first. Then:

1) `aws iam --region ap-southeast-2 create-role --role-name ecsExecutionRole --assume-role-policy-document file://execution-assume-role.json`

2) `aws iam --region ap-southeast-2 attach-role-policy --role-name ecsExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy`
3) `aws logs create-log-group --log-group-name ecsDemoLogs --region ap-southeast-2`
4) `ecs-cli configure profile --access-key ACCESS_KEY_ID --secret-key SECRET_ACCESS_KEY --profile-name ecsDemoProfile`
5) `ecs-cli configure profile default --profile-name ecsDemoProfile`
6) `ecs-cli configure --cluster studentapi-demo-cluster --default-launch-type EC2 --region ap-southeast-2 --config-name ecsDemoConfig`
7) `ecs-cli up --keypair ecs-demo --capability-iam --size 1 --instance-type t2.medium --force`
8) `ecs-cli compose --file docker-compose.yml up --cluster studentapi-demo-cluster`
9) `ecs-cli ps`
10) `ecs-cli down --force`

# References
[.Net Core and SQL Server In Docker - Part 1]

[Building and shipping a .NET Core application with Docker and TravisCI]

[Amazon ECS: using the CLI with Docker Compose]

[Docker cluster management on AWS]

[Install and configure the ECS CLI]

[Amazon ECS CLI Tutorial]

[.Net Core and SQL Server In Docker - Part 1]: <http://blog.kontena.io/dot-net-core-and-sql-server-in-docker/>

[Building and shipping a .NET Core application with Docker and TravisCI]: <https://dusted.codes/building-and-shipping-a-dotnet-core-application-with-docker-and-travisci>

[Docker cluster management on AWS]:<https://laszlo.cloud/Docker-cluster-management-on-AWS>

[gotchas of docker-compose on the ECS CLI]:<https://laszlo.cloud/Docker-cluster-management-on-AWS>

[Amazon ECS: using the CLI with Docker Compose]:<https://medium.com/@Electricste/amazon-ecs-using-the-cli-with-docker-compose-74287f19b181>

[Install and configure the ECS CLI]:<http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html>

[Amazon ECS CLI Tutorial]:<http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_tutorial.html>