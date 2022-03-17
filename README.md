# aws-yilisramirez
Práctica de migración a la nube AWS - Yilis Ramirez

The scope of this practice is building a Webapp to handle a to-do-list, in which we wil add items in a text box and when pressing enter it is added into the list. And if you make click in some of the items, it is deleted.

<h1>Requirements</h1>

First of all we are going to setup our environment in AWS: 

- Creation of a personal AWS account.

  Our first steps will be to create an AWS account through this [link](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html?nc2=h_ct&src=default), where you will have to populate your personal data accordingly. 
  ![AWS account](https://user-images.githubusercontent.com/39458920/158795611-54b088ba-4135-4e9c-9795-86a36121ce95.JPG)

- Enabing MFA in root access.
  
  You will have to access in IAM dashboard, and in security recommendations you will see the option <b>Add MFA for root user</b>, click on <b>add MFA</b> tab.
  
  We advise to activate it with virtual MFA device, where you need an authenticator app installed on your mobile device. We highly recommend to use Google authenticator app.
  We proceed to scan the QR code with the app and introduce the corresponding codes.
  Now you will see the IAM dashboard as follows:

![IAM dashboard](https://user-images.githubusercontent.com/39458920/158830580-bcdf361c-78cc-4590-9b19-eb03701bbf81.JPG)
  
- Creating an organization in AWS to be able to set policies, servicies, and so on.

  Search for <b>AWS organization</b> and click on <b>Create an Organization</b>. Now you will see your organizational structure.
![aws organization](https://user-images.githubusercontent.com/39458920/158848951-9d06c9d9-a42d-4f2f-9ec2-a59ba7619cbc.JPG)

- Setting a SCP to deny resources in París and Sao Paulo.

  For this we have implemented the following JSON code where we specified the regions where we have denied resources.
```bash
{
    "Version": "2022-03-17",
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
                "StringNotEquals": {
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
 We click on <b>Create policy</b>, now we select <b>Targets</b> and then we go on <b>Attach</b> tab, to attach the policy to our Organizational Unit closer than our account.
 And you should see a pop up message <b>"Successfully attached the policy 'RestrictRegion' to OU 'KeepCoding3'."</b>

- Generating a billing alarm.

  To configure it we should go on AWS Budgets, select <b>Cost Budget</b>, and on <b>Next.</b>
  We select monthly period, recurring budget to renew it every month. The Budget method should be <b>"Fixed"</b>, entering the budgeted amount, and we have set the       name as <b>"My Budget".</b>
  
  Once we have defined the budget, we set the alert. On this we have set two alerts, one when the budgeted threshold exceeds 10% and another one when forecasted cost     is greater than 100% of the budgeted amount. Note we will be informed via email about these alerts.
