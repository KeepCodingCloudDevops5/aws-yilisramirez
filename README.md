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
  
![MFA code](https://user-images.githubusercontent.com/39458920/158809945-dbcb195c-ad36-4bea-b059-5a83f823e38d.JPG)

   Now you will see the IAM dashboard as follows:

![IAM dashboard](https://user-images.githubusercontent.com/39458920/158830580-bcdf361c-78cc-4590-9b19-eb03701bbf81.JPG)

  
- Creating OUs in order to apply SCPs
