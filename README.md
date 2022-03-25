# Use Soda SQL Cloud Runner to deploy Soda SQL in AWS 

While you can deploy Soda SQL in a local on-premises environment, you may wish to deploy the command-line tool in your organization's cloud environment. The following procedure and [accompanying code](https://github.com/sodadata/soda-sql-cloud-runner) offers an example of how to deploy Soda SQL in AWS.

## Prerequisites

* You are familiar with Soda SQL or have read Soda SQL basics.
* You are familiar with using GitHub, or another git server.  
* You have access to your organization’s AWS Console and are familiar with AWS CloudFormation.
* You have the permissions needed to make changes to your AWS environment.
* You have access to the login credentials for the data warehouse that contains the data you wish to scan.
* You have a Soda Cloud account (optional).

## Overview

There are two repositories involved in deploying and using Soda SQL in your AWS cloud environment.  

* **Soda SQL Cloud Runner example repository** which contains ready-to-use files that help you deploy Soda SQL and run it in your cloud environment. You can use the materials in the repo to deploy using the AWS Console and CloudFormation UI. This repo also contains an example of a Soda SQL project directory that you can reference for your own project.
* **Soda SQL project repository**, or a project subdirectory in a repo, that contains your Soda SQL configuration files. To run scans of your data, Soda SQL requires both a warehouse YAML file, in which you configure connection details for your warehouse, and scan YAML files in which you configure the tests that Soda SQL uses to run SQL queries against data in your tables. Refer to the Soda SQL install and configuration documentation for details. 

Be aware that your Soda SQL project repo or subdirectory must contain a **requirements.txt** file as the CloudFormation template references its contents when it runs a task. Refer to the example requirements.txt file in the soda-sql-example subdirectory.


## Deploy Soda SQL using AWS CloudFormation

To deploy Soda SQL in your AWS environment and set a schedule for it to run scans on tables in your warehouse, you need to adjust some of the contents of the example files in the Soda SQL Cloud Runner repo, then use use AWS CloudFormation in the AWS Console to deploy. 

The following procedure outlines the steps to take to create a CloudFormation stack, and deploy and run Soda SQL. However, because the values for several parameters are specific to your individual Soda SQL project and other resources and environments (git repository, AWS account, database login credentials, table names in a database), you must adjust some of the contents of the example files to successfully deploy Soda SQL in your own AWS environment.

1. Begin by cloning this soda-sql-cloud-runner repository from GitHub. This repo contains the example files that you can adjust and use to deploy and run Soda SQL scans. 
2. Refer to the **Appendix** below for insight on what to adjust in the CloudFormation template (cloudformation.yml) to conform to your own environment and resources. Save the changes you make to all files. For your first deployment, consider limiting the scans and scan schedule to just one table in your database; you can add all the tables later.
3. Log in to your AWS Console, then navigate to **CloudFormation** > **Stacks***. Click **Create stack** and select **With new resources (standard)**. 
4. Select **Template is ready** and **Upload a template file**, then upload the cloudformation.yml file you adjusted.
5. In **Specify stack details**, provide a name for your stack. CloudFormation extracted some of the values for the Parameters from the cloudformation.yml file; provide values for the remaining empty Parameters as per the following, then click Next.
* ApiKeyIdParam - use the API Key Id for your Soda Cloud account
* ApiKeySecretParam - use the API Key Secret for your Soda Cloud account
* [yourdatabase]UserName - the username to log in to your database
* [yourdatabase]PasswordParam - the password to log in to your database
6. In **Configure stack options**, change nothing and continue.
7. Review the details of your configurations, acknowledge the creation of IAM resources with custom names, then click **Create Stack**. 
8. When the stack creation is complete, you can change the values of the parameters you entered, if you wish. To do so, in your AWS Console, navigate to **Systems Manager** > **Parameter Store**. Click to select the parameter you wish to change, then click **Edit**. 
9. If the git repository in which you store your Soda SQL project is private, you must set up an SSH key pair with read access to the repository. Provide the Private Key file content to the RsaKeyIdentity Secret which CloudFormation created when it created the stack. To do so, in your AWS Console, navigate to **Secrets Manager** -> **Secrets**. Click to select the secret you wish to change, scroll to **Secret Value**, click **Retrieve Secret**, click **Edit**, then provide the contents of your SSH Private Key. See **Notes on RSA key** below for details.
10. To see the results of the scheduled Soda SQL scan (the scan schedule is configured in the cloudformation.yml file using a cron job), navigate to **CloudWatch** > **Logs** > **Log groups**, then click to open the log group for your stack. After Soda SQL has run a scan, you can select the **Log Stream** associated with the scan to see the scan output.
Alternatively, you can navigate to **Elastic Container Service (ECS)** to find your stack. Navigate to the **Tasks** tab, then scroll down to find a link to the logs where you can review the output.
Further, if you have a Soda Cloud account and you provided values for the ApiKeyIdParam and ApiKeySecretParam during the stack creation workflow, you can log in to your Soda Cloud account to review the Monitor Results.
11. Review Next Steps.



## Next steps

* If you want to modify the cron setting to trigger a scheduled scan more or less frequently, log in to your AWS Console, then navigate to **CloudWatch** > **Events** > **Rules**. Select the rule for your stack to open it, then click **Actions** > **Edit**. The value of this rule is in the GMT timezone. Alternatively, you can configure the cron expression directly in the CloudFormation template, in the SodaSqlTaskSchedule.
* Add more TaskDefinitions (effectively, adding scans of more datasets) and corresponding SodaSqlTaskSchedules, to the CloudFormation template until Soda SQL is regularly scanning all of your datasets. To do so, simply copy and paste the existing TaskDefinition and SodaSqlTaskSchedule content to the same file, then adjust the dataset details; refer to **Customize the CloudFormation template** and **Customize the Docker Image** to review what to change. Add one TaskDefinition + SodaSqlTaskSchedule for each table in your warehouse.



## Appendix

The CloudFormation template and Docker Image work together to complete a deployment to an AWS cloud environment.

### About the CloudFormation template

The CloudFormation template (cloudformation.yml file) in the Soda SQL Cloud Runner example repo contains **parameters**, and the configuration for a **TaskDefinition** and a **SodaSqlTaskSchedule**.
* A **TaskDefinition** in the cloudformation.yml file represents a scan of a single dataset. You need one TaskDefinition for every scan YAML file. The example file includes just one TaskDefinition for a scan to run on a dataset named “Cars”. In your own environment, you ought to copy and paste the format to add more TaskDefinitions to the file so that Soda SQL scans all of your datasets.
* A **SodaSqlTaskSchedule** instructs Soda SQL to run scans at regular intervals, using a cron job to define the interval. A SodaSqlTaskSchedule is associated with one TaskDefinition.
* **Parameters** provide values for some inputs. CloudFormation requests these values as you follow the guided steps to set up your stack. 

### Customize the CloudFormation template 

To successfully deploy Soda SQL and run scans in AWS, you need to provide values for several parameters and definitions in the CloudFormation template (cloudformation.yml file).

When you use the CloudFormation user interface to create a stack using the CloudFormation template, you can provide values for the following parameters during the stack creation workflow, and AWS stores them in the Parameter Store. You can leave these fields blank in the CloudFormation template if you intend to populate them during the stack creation flow.

* ApiKeyIdParam - use the API Key Id for your Soda Cloud account
* ApiKeySecretParam - use the API Key Secret for your Soda Cloud account
* [yourdatabase]UserName - the username to log in to your database
* [yourdatabase]PasswordParam - the password to log in to your database

In the CloudFormation template, change the values as per the following:

* Yellow = adjust the value to conform to your dataset details
* Orange = adjust the value to conform to you own environment or resource details
* Blue = (optional) adjust to change the scan schedule frequency which is set, by default, to “everyday at 1:30pm”

Note that adding sensitive values for parameters directly to the CloudFormation template is not without risk as this might expose those values. Consider providing the values in the file using environment variables.


**TaskDefinition**
![cf1.png](/cf1.png)

**SodaSqlTasksSchedule and Outputs**
![cf2.png](/cf2.png)

### Customize the Docker Image

The CloudFormation template leverages the Docker Image to clone the repo, install requirements from the requirements.txt file, and execute a scan command. Refer to the entrypoint.ssh file in the container directory. 

Soda has made the Docker Image public so you can configure it to your environment’s needs by providing the following values as environment variables. 
* Provide a value for the REPO_URI which is the SSH URI to the git repository that contains your soda-sql configuration files. Use an environment variable to provide this value.
* Provide a value for SCAN_CMD which is the soda scan command relative to the repository or WORKING_DIR.

Optionally, you may also adjust the following configurations:
* Provide a value for the WORKING_DIR which is the relative directory to chroot into after cloning the repository. Use an environment variable to provide this value.
* Provide a value for RSA_KEY_CONTENTS which is the Private Identity Key contents used as the identity for SSH requests. See Notes on RSA key below.

### Notes on RSA key

If the repository containing the Soda SQL project setup is private, it cannot be cloned during a task run because it does not have the permission to do so. Instead, you can use Deploy Keys in GitHub. 

Follow the <a href="https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys">GitHub instructions</a> to create an RSA key pair and store the key somewhere safe. Add the contents of the private key as the value for the RsaKeyIdentity Secret that’s created as part of the CloudFormation template. Add the public key as Deploy Key to your GitHub repository.
