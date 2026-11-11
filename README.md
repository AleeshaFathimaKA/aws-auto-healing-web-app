

\# AWS Auto-Healing Web Application



A highly available Flask web application deployed on AWS using Terraform, EC2 Auto Scaling, an Application Load Balancer, CloudWatch, and SNS.



\## 1. Project Overview



\### Problem



Applications running on a single EC2 instance can become unavailable if the application process crashes or the EC2 instance fails.



Manual recovery can increase downtime and require continuous monitoring.



\### Solution



I built an AWS-based auto-healing web application that uses multiple recovery and monitoring mechanisms:



\- \*\*systemd:\*\* Automatically restarts the application process if Gunicorn crashes.

\- \*\*Application Load Balancer (ALB):\*\* Routes incoming HTTP traffic to healthy EC2 instances.

\- \*\*EC2 Auto Scaling Group (ASG):\*\* Maintains the desired instance capacity and replaces terminated or unhealthy instances.

\- \*\*Amazon CloudWatch:\*\* Monitors EC2 CPU utilization and triggers an alarm.

\- \*\*Amazon SNS:\*\* Sends email notifications when the CloudWatch alarm enters the ALARM state.

\- \*\*Terraform:\*\* Provisions and manages the AWS infrastructure as code.



\## 2. Architecture



```mermaid

flowchart TD

&#x20;   U\[User Browser] --> ALB\[Application Load Balancer]

&#x20;   ALB --> TG\[Target Group]

&#x20;   TG --> EC2A\[EC2 Instance 1]

&#x20;   TG --> EC2B\[EC2 Instance 2]



&#x20;   EC2A --> APP1\[Gunicorn + Flask]

&#x20;   EC2B --> APP2\[Gunicorn + Flask]



&#x20;   SD1\[systemd] --> APP1

&#x20;   SD2\[systemd] --> APP2



&#x20;   ASG\[EC2 Auto Scaling Group] --> EC2A

&#x20;   ASG --> EC2B



&#x20;   CW\[CloudWatch CPU Alarm] --> SNS\[Amazon SNS]

&#x20;   SNS --> EMAIL\[Email Notification]

```



\## 3. AWS Services and Technologies



| Technology | Purpose |

|---|---|

| AWS VPC | Isolated network environment |

| EC2 | Runs the Flask application |

| Application Load Balancer | Distributes incoming traffic |

| Auto Scaling Group | Maintains instance capacity |

| CloudWatch | Monitors CPU utilization |

| SNS | Sends email alerts |

| IAM | Controls AWS permissions |

| Systems Manager | Secure EC2 access without SSH |

| Terraform | Infrastructure as Code |

| Python / Flask | Web application |

| Gunicorn | Python application server |

| Linux systemd | Application process recovery |



\## 4. How Auto-Healing Works



\### Application-Level Recovery



Gunicorn runs the Flask application as a systemd service.



The service is configured with:



\- `Restart=always`

\- `RestartSec=5`



If the Gunicorn process crashes, systemd automatically starts it again.



\### Instance-Level Recovery



The Application Load Balancer performs health checks using the `/health` endpoint.



The Auto Scaling Group is configured with ELB health checks. It can replace an unhealthy EC2 instance and maintain the desired capacity.



\### Monitoring and Notifications



CloudWatch monitors average EC2 CPU utilization.



The alarm is configured to trigger when CPU utilization exceeds 70% for two consecutive five-minute evaluation periods.



SNS delivers an email notification when the alarm enters the ALARM state.



\## 5. Infrastructure Configuration



\- AWS Region: `ap-southeast-2`

\- EC2 Instance Type: `t3.micro`

\- Auto Scaling Minimum Capacity: 1

\- Auto Scaling Desired Capacity: 2

\- Auto Scaling Maximum Capacity: 2

\- Load Balancer: Application Load Balancer

\- Application Port: 5000

\- Health Check Endpoint: `/health`

\- Monitoring Metric: CPUUtilization

\- CPU Alarm Threshold: 70%



\## 6. Security Considerations



\- EC2 instances are accessed through AWS Systems Manager Session Manager.

\- No inbound SSH access is configured.

\- EC2 application traffic on port 5000 is allowed only from the ALB security group.

\- EBS volumes are encrypted.

\- EC2 metadata access requires IMDSv2.

\- IAM roles provide permissions for Systems Manager access.



\## 7. Project Structure



```text

aws-auto-healing-web-app/

│

├── app/

│   ├── app.py

│   └── requirements.txt

│

├── terraform/

│   ├── autoscaling.tf

│   ├── iam.tf

│   ├── launch\_template.tf

│   ├── load\_balancer.tf

│   ├── main.tf

│   ├── monitoring.tf

│   ├── outputs.tf

│   ├── providers.tf

│   ├── security\_groups.tf

│   ├── variables.tf

│   └── .terraform.lock.hcl

│

├── .gitignore

└── README.md

```



\## 8. Testing and Validation



The following tests were performed on the deployed infrastructure.



| Test | Result |

|---|---|

| Application homepage through ALB | Passed |

| `/health` endpoint returned HTTP 200 | Passed |

| ALB target group health checks | Passed |

| Gunicorn process termination and systemd recovery | Passed |

| EC2 instance termination and ASG replacement | Passed |

| Application availability after instance replacement | Passed |

| SNS email notification delivery | Passed |

| CloudWatch alarm returned to OK state | Passed |



\*\*Testing notes:\*\*



\- Application recovery was verified by terminating the Gunicorn process and checking that systemd restarted it with a new process ID.

\- Instance replacement was verified by manually terminating an EC2 instance and observing the Auto Scaling Group launch a replacement.

\- SNS email delivery was verified using a controlled CloudWatch alarm state-change test.

\- The actual CPU threshold breach under load was not tested.



\## 9. Deployment



Prerequisites:



\- AWS account and configured AWS CLI access.

\- Terraform installed.

\- Git installed.



Navigate to the Terraform directory:



```powershell

cd terraform

```



Initialize Terraform:



```powershell

terraform init

```



Validate the configuration:



```powershell

terraform validate

```



Review the infrastructure plan:



```powershell

terraform plan

```



Apply the configuration:



```powershell

terraform apply

```



Before deployment, create a local `terraform.tfvars` file containing your notification email:



```hcl

notification\_email = "your-email@example.com"

```



Do not commit `terraform.tfvars` or Terraform state files to GitHub.



\## 10. Cleanup



AWS resources such as EC2 instances and the Application Load Balancer can incur charges.



After testing, remove the infrastructure:



```powershell

terraform destroy

```



Review the destruction plan and confirm when prompted.



\---



\## Key Learning Outcomes



\- Provisioning AWS infrastructure using Terraform.

\- Understanding load balancing and EC2 Auto Scaling.

\- Configuring Linux systemd services.

\- Implementing application process recovery.

\- Monitoring infrastructure with CloudWatch.

\- Configuring SNS email notifications.

\- Accessing EC2 securely using Systems Manager.

\- Testing failure scenarios and validating recovery.



\*\*Project focus:\*\* AWS Infrastructure, Cloud Support, Linux Administration, Monitoring, and DevOps.



