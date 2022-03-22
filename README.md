# aws-yilisramirez
Práctica de migración a la nube AWS - Yilis Ramirez

The scope of this practice is building a Webapp to handle a to-do-list, in which we wil add items in a text box and when pressing enter it is added into the list. And if you make click in some of the items, it is deleted.

# 1. Requirements

First of all we are going to setup our environment in AWS: 

- <b>Creation of a personal AWS account.</b>

  Our first steps will be to create an AWS account through this [link](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html?nc2=h_ct&src=default), where you will have to populate your personal data accordingly. 
  ![AWS account](https://user-images.githubusercontent.com/39458920/158795611-54b088ba-4135-4e9c-9795-86a36121ce95.JPG)

- <b>Enable MFA in root access.</b>
  
  You will have to access in IAM dashboard, and in security recommendations you will see the option <b>Add MFA for root user</b>, click on <b>add MFA</b> tab.
  
  We advise to activate it with virtual MFA device, where you need an authenticator app installed on your mobile device. We highly recommend to use Google authenticator app.
  We proceed to scan the QR code with the app and introduce the corresponding codes.
  Now you will see the IAM dashboard as follows:

  ![IAM dashboard](https://user-images.githubusercontent.com/39458920/158830580-bcdf361c-78cc-4590-9b19-eb03701bbf81.JPG)
  
- <b>Create an organization in AWS to be able to set policies, servicies, and so on.</b>

  Search for <b>AWS organization</b> and click on <b>Create an Organization</b>. Now you will see your organizational structure.
![aws organization](https://user-images.githubusercontent.com/39458920/158848951-9d06c9d9-a42d-4f2f-9ec2-a59ba7619cbc.JPG)

- <b>Setting a SCP to deny resources in París and Sao Paulo.</b>

  For this we have implemented the following JSON code where we specified the regions where we have denied resources.
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyAllOutsideRequestedRegions",
            "Effect": "Deny",
            "NotAction": [
                "cloudfront:*",
                "iam:*",
                "route53:*",
                "support:*",
                "organizations:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": [
                        "sa-east-1",
                        "eu-west-3"
                    ]
                }
            }
        }
    ]
}
```
 We click on <b>Create policy</b>, now we select <b>Targets</b> and then we go on <b>Attach</b> tab, to attach the policy to our Organizational Unit closer than our     account.
 And you should see a pop up message <b>"Successfully attached the policy 'RestrictRegion' to OU 'KeepCoding3'."</b>

- <b>Generate a billing alarm.</b>

  To configure it we should go on AWS Budgets, select <b>Cost Budget</b>, and on <b>Next.</b>
  We select monthly period, recurring budget to renew it every month. The Budget method selected is <b>"Fixed"</b>, we enter the budgeted amount, and we have set the     name as <b>"My Budget".</b>
  
  Once we have defined the budget, we set the alert. On this we have set two alerts, one when the budgeted threshold exceeds 10% and another one when forecasted cost     is greater than 100% of the budgeted amount. As notification preference we choice email address to be informed about these billing alerts.
  
- <b>Delete default VPC</b>

  As one of best practices advised by Amazon, we are going to remove the default VPC of Ireland which is where our practice is based, so we search for VPC option in our AWS account, select the single VPC listed and proceed to delete and confirm it. 

  ![default vpc](https://user-images.githubusercontent.com/39458920/159047926-4dff5acc-01ca-42e4-ba8f-19d423f5cd53.JPG)
  
# 2. Network Topology
To design a network topology we will start creating a <b>VPC</b> as shown below.

![MyVPC](https://user-images.githubusercontent.com/39458920/159136749-9435b4c0-43f8-49d1-b098-dd846fe73e71.JPG)

We have also enabled DNS hostnames, DNS resolution to deploy the database, and set the <b>IPv4 172.24.0.0/16</b>

Now we will create the public and private Subnets. Where the private ones the database is provisioned, while the public ones the Loadbalancer and Webapp are provisioned.

![subnets](https://user-images.githubusercontent.com/39458920/159137064-8e41bf8c-5283-423a-9475-7739985b9486.JPG)

To enable the outbound internet in the public Subnets, we will add the <b>Internet Gateway</b> and attach it to the VPC.

![igw](https://user-images.githubusercontent.com/39458920/159137158-20a7bb91-43d9-444a-b8f6-3eea1e6261d0.JPG)

Now we are going to edit the <b>Route Table</b> automatically created and select the two public Subnets, which require internet access.

We added a new route with IP destination 0.0.0.0/0 and the internet gateway previously created as target.

![route-table](https://user-images.githubusercontent.com/39458920/159137750-c7822221-0745-476b-80c3-aa71c7921268.JPG)

As last setting, we define another <b>Route Table</b> for private Subnets, but in this case we will not include any other route, as it's a private subnet which does not need outbound internet.
![route-table-privada](https://user-images.githubusercontent.com/39458920/159138440-feeb17bf-5c53-4e31-8377-ff58ca71b7d0.JPG)

# 3. Database
To create the database we should create first a <b>Security Group</b> `kc-rds-sg` for security purposes, in which it only allows incoming requests from TCP 3306 to EC2.

In adittion, we have created another <b>Security Group</b> for EC2 instances, and a <b>Subnet Group</b> where we specify the private subnets in which the database will be connecting to.

Once the resources have been created, we will go on <b>RDS-Databases</b>, we choose <b>standard database creation</b> and select MySQL.
We named the database as `kc-mysql-ddbb`

![database dd](https://user-images.githubusercontent.com/39458920/159294720-c08cf0bd-3e17-4b15-865d-ba30705f1f86.JPG)

After the database has been created, we proceed to store the connection details into a <b>Secret Manager</b> with the name `rtb-db-secret`
                                                                                        
# 4. Roles
To get the connection details of database, we provide access from EC2 to secret manager by stating IAM role for EC2 instance, which we named `EC2RoleToAccessSecrets` and we attach the policy `SecretsManagerReadWrite`

![IAM role](https://user-images.githubusercontent.com/39458920/159451638-68c02c83-3bf9-4c1b-afe6-3f53e6fe2f78.JPG)

Now we proceed to attach the IAM policy to secret manager `rtb-db-secret` through this JSON code.

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::124678637394:role/EC2RoleToAccessSecrets"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
```
# 5. Webserver


