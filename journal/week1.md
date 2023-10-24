# Terraform Beginner Bootcamp 2023 - Week 1

## Fixing Tags

[How to Delete Local and Remote Tags on Git](https://devconnected.com/how-to-delete-local-and-remote-tags-on-git/)

Locall delete a tag
```sh
git tag -d <tag_name>
```

Remotely delete tag

```sh
git push --delete origin tagname
```

Checkout the commit that you want to retag. Grab the sha from your Github history.

```sh
git checkout <SHA>
git tag M.M.P
git push --tags
git checkout main
```

## Root Module Structure

Our root module structure is as follows:

```
PROJECT_ROOT
│
├── main.tf                 # everything else.
├── variables.tf            # stores the structure of input variables
├── terraform.tfvars        # the data of variables we want to load into our terraform project
├── providers.tf            # defined required providers and their configuration
├── outputs.tf              # stores our outputs
└── README.md               # required for root modules
```

[Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)

## Terraform and Input Variables

### Terraform Cloud Variables

In terraform we can set two kind of variables:
- Enviroment Variables - those you would set in your bash terminal eg. AWS credentials
- Terraform Variables - those that you would normally set in your tfvars file

We can set Terraform Cloud variables to be sensitive so they are not shown visibliy in the UI.

### Loading Terraform Input Variables

[Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

### var flag
We can use the `-var` flag to set an input variable or override a variable in the tfvars file eg. `terraform -var user_ud="my-user_id"`

### var-file flag

[var-file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
Terraform also automatically loads a number of variable definitions files if they are named exactly terraform.tfvars or terraform.tfvars.json.
Any files with names ending in .auto.tfvars or .auto.tfvars.json

### terraform.tvfars
[`terraform.tfvars`](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)

This is the default file to load in terraform variables in blunk

### auto.tfvars

Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.

### order of terraform variables

Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)

## Dealing With Configuration Drift

## What happens if we lose our state file?

If you lose your statefile, you most likely have to tear down all your cloud infrastructure manually.

You can use terraform port but it won't for all cloud resources. You need check the terraform providers documentation for which resources support import.

### Fix Missing Resources with Terraform Import

`terraform import aws_s3_bucket.bucket bucket-name`

[Terraform Import](https://developer.hashicorp.com/terraform/cli/import)
[AWS S3 Bucket Import](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import)

### Fix Manual Configuration

If someone goes and delete or modifies cloud resource manually through ClickOps. 

If we run Terraform plan is with attempt to put our infrstraucture back into the expected state fixing Configuration Drift

## Fix using Terraform Refresh

```sh
terraform apply -refresh-only -auto-approve
```

## Terraform Modules

### Terraform Module Structure

It is recommend to place modules in a `modules` directory when locally developing modules but you can name it whatever you like.

### Passing Input Variables

We can pass input variables to our module.
The module has to declare the terraform variables in its own variables.tf

```tf
module "terrahome_aws" {
  source = "./modules/terrahome_aws"
  user_uuid = var.user_uuid
  bucket_name = var.bucket_name
}
```

### Modules Sources

Using the source we can import the module from various places eg:
- locally
- Github
- Terraform Registry

```tf
module "terrahome_aws" {
  source = "./modules/terrahome_aws"
}
```


[Modules Sources](https://developer.hashicorp.com/terraform/language/modules/sources)


## Considerations when using ChatGPT to write Terraform

LLMs such as ChatGPT may not be trained on the latest documentation or information about Terraform.

It may likely produce older examples that could be deprecated, often affecting providers.

## Working with Files in Terraform


### Fileexists function

This is a built in terraform function to check the existance of a file.

```tf
condition = fileexists(var.error_html_filepath)
```

https://developer.hashicorp.com/terraform/language/functions/fileexists

### Filemd5

https://developer.hashicorp.com/terraform/language/functions/filemd5

### Path Variable

In terraform there is a special variable called `path` that allows us to reference local paths:
- path.module = get the path for the current module
- path.root = get the path for the root module
[Special Path Variable](https://developer.hashicorp.com/terraform/language/expressions/references#filesystem-and-workspace-info)


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key    = "index.html"
  source = "${path.root}/public/index.html"
}

## Terraform Locals

Locals allows us to define local variables.
It can be very useful when we need transform data into another format and have referenced a varaible.

```tf
locals {
  s3_origin_id = "MyS3Origin"
}
```
[Local Values](https://developer.hashicorp.com/terraform/language/values/locals)

## Terraform Data Sources

This allows use to source data from cloud resources.

This is useful when we want to reference cloud resources without importing them.

```tf
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```
[Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)

## Working with JSON

We use the jsonencode to create the json policy inline in the hcl.

```tf
> jsonencode({"hello"="world"})
{"hello":"world"}
```

[jsonencode](https://developer.hashicorp.com/terraform/language/functions/jsonencode)


### Changing the Lifecycle of Resources

[Meta Arguments Lifcycle](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)

## Terraform Data

Plain data values such as Local Values and Input Variables don't have any side-effects to plan against and so they aren't valid in replace_triggered_by. You can use terraform_data's behavior of planning an action each time input changes to indirectly use a plain value to trigger replacement.

https://developer.hashicorp.com/terraform/language/resources/terraform-data

## Provisioners

Provisioners allow you to execute commands on compute instances eg. a AWS CLI command.

They are not recommended for use by Hashicorp because Configuration Management tools such as Ansible are a better fit, but the functionality exists.

[Provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax)

### Local-exec

This will execute command on the machine running the terraform commands eg. plan apply

```tf
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo The server's IP address is ${self.private_ip}"
  }
}
```

https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec

### Remote-exec

This will execute commands on a machine which you target. You will need to provide credentials such as ssh to get into the machine.

```tf
resource "aws_instance" "web" {
  # ...

  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "consul join ${aws_instance.web.private_ip}",
    ]
  }
}
```
https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec


## For Each Expressions

For each allows us to enumerate over complex data types

```sh
[for s in var.list : upper(s)]
```

This is mostly useful when you are creating multiples of a cloud resource and you want to reduce the amount of repetitive terraform code.

[For Each Expressions](https://developer.hashicorp.com/terraform/language/expressions/for)

## My Notes

We will get Static website from cloudfront and connect to terratowns. 

![image](./assets/week1/StaticWebsite.PNG)

Using ChatGPT created index.html and to see locally how it looks, `npm install http-server -g`

![image](./assets/week1/install-httpserver.PNG)

(We don’t connect gitpod to s3 but we installed aws CLI with our credentials on gitpod which connects to s3.)

`aws s3 cp public/index.html s3://8e864bc7-b373-4447-a2f7-d12df50cda76/index.html`

 ![image](./assets/week1/CopyToS3.PNG)

Go to s3 bucket and check if index.html is uploaded. 

 ![image](./assets/week1/Aftercopytos3.PNG)

click on Properties of the s3 bucket and then on ‘static website hosting’ . We get a “forbidden error message” because our default bucket is not public. When we check Permissions tab, we find that “Block all public access” is turned on. 

 ![image](./assets/week1/Forbidden.PNG)

There are 2 ways to handle this. We can either turn it on and change the bucket policy OR using Cloud Front distribution we can give the bucket public access. Cloud front is a CDN and it takes copy of our website and caches it to bunch of computers around the world. Cloudfront will attach more security services like AWS firewall.

Create a CloudFront Distribution, with these settings  

![image](./assets/week1/CreateCF_Domain.PNG)

(use the website endpoint- bucket domain name ).

In the Default root object property add “index.html”.

Description changed to “Terraform example CDN”  ![image](./assets/week1/CFNCreated.PNG)

We still get “forbidden error message” . We need origin access controls and bucket policy. 

#### Create OAC (Origin Access Control) 
In CloudFront > Origin access, start creating a control setting. Sign requests, then create it.

 ![image](./assets/week1/CreateControlSetting1.PNG)

 ![image](./assets/week1/CopyPolicy.PNG)

![image](./assets/week1/CopyPolicysave.PNG)

 Restructure root module: 

In this video, we refactor our root module into Terraform’s standard root module structure, which looks like the following:

PROJECT_ROOT
├── [variables.tf](http://variables.tf/)      # stores the structure of input variables
├── [providers.tf](http://providers.tf/)      # defined required providers and their configurations
├── [outputs.tf](http://outputs.tf/)        # stores the outputs
├── terraform.tfvars  # the data of variables we want to load into our terraform project.
├── [main.tf](http://main.tf/)           # everything else
└── [README.md](http://readme.md/)         # required for root modules

We will refactor main.tf into the various files we generated above.

We ran `tf init` and then `tf plan`

Received an error ![image](./assets/week1/ErrTFPlan.PNG) This error happens because our current backend is set with the Terraform Cloud.

Execute `tf plan -var user_uuid='Testing123'`but this takes a long time to go to Terraform cloud to generate and therefore we decide to generate the plan local. 

![image](./assets/week1/Err_TFUUID.PNG)

So we tear down our infrastructure. Before we destroy, we need to comment out 

```
tags = {
    UserUuid = var.user_uuid
  }
```

in [main.tf](http://main.tf) and in variables.tf

```
variable "user_uuid" {
  description = "The UUID of the user"
  type        = string
  validation {
    condition        = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.user_uuid))
    error_message    = "The user_uuid value is not a valid UUID."
  }
}
```

We now enter `tf destroy`.  
![image](./assets/week1/ErrTFDestroy.PNG)

But we run into the following credential issue. The reason behind this is because we migrated our state to Terraform Cloud. We don’t have the states in the local machine. So the provisioning or deprovisioning work is done via Terraform Cloud, but we haven’t granted Terraform Cloud any permissions to work with AWS resources. Hence, the `No valid credential source found` issue.

We can see this when we login to Terraform. ![image](./assets/week1/ErrTFDestroy2.PNG)

The solution for this is to feed Terraform Cloud our variables for AWS credentials as Environment variables and mark as sensitive (this will prevent the values from being displayed in the UI).. 

![image](./assets/week1/AddEnv_variable.PNG) , 

![image](./assets/week1/AddedEnv_variables.PNG) and

 ![image](./assets/week1/Destroying.PNG)

 ![image](./assets/week1/Destroyed.gif)

Comment out workspace name in `providers.tf`

```
# cloud {
  #   organization = "roopish-bootcamp"
  #   workspaces {
  #     name = "terra-house-1"
  #   }
  # }

```

Uncomment variables.tf and in main.tf

```
tags = {
     UserUuid = var.user_uuid
   }
```

Run `tf init` ![image](./assets/week1/CommentOut_init.PNG)

Now, delete the file `.terraform.lock.hcl` and the folder `.terraform`. 

![image](./assets/week1/DeleteTFLock.PNG)

![image](./assets/week1/DeleteTFFolder.PNG)

This marks the disconnect between your local environment and Terraform Cloud. So if you run terraform, the states will be updated locally.

Now you are ready to start from scratch again. Run the following commands to initiate terraform, then apply the plan. This time around, the file and folder .terraform.lock.hcl and .terraform that are generated will be stored locally in your machine.

![image](./assets/week1/TFPlan_withUUID.PNG)

Another way would be to store this user_uuid in terraform.tfvars and then call `tf plan` 

![image](./assets/week1/TFPlan_withUUID2.PNG)

Make changes to Week1 journal. `tf destroy` and `tf apply —auto-approve` and then commit changes

****Import and Configuration Drift****

How to fix if we delete our state file. We first run `tf init` and then 

![image](./assets/week1/ImportConfig1.PNG). We now run `tf plan` as seen below

![image](./assets/week1/ImportConfig2.PNG)

 ![image](./assets/week1/TFPlan.gif)

### Static website Hosting

We created a new s3 bucket with Static webhosting enables as shown in the GIF below.

![ ](./assets/week1/NewBucket.PNG)

![ ](./assets/week1/StaticwebsiteHostingEnabled.GIF)

Create files `index.html` and `error.html` which will be configured as the index and error pages of our static website.

![image](./assets/week1/AfterAddingHTML.PNG)

![image](./assets/week1/AfterAddingHTML_2.PNG)

![image](./assets/week1/Static.PNG)

After adding the HTML pages and defining variables for `index.html` and `error.html` files in `modules/terrahouse_aws/variables.tf`,  we ran `tf init`, `tf plan`, `tf apply --auto-approve`. Below is the output as seen from CloudFront URL

![image](./assets/week1/Staticwebsite_2.PNG)

Now we make changes to HTML page and update the content version. We want that our CDN cache invalidates when the `content-version` (implemented in the previous step) changes. For this we will be making use of `terraform-data`. We create the `terraform-data` resource in  `modules/terrahouse_aws/resource-cdn.tf`. 

```markdown
resource "terraform_data" "invalidate_cache" {
  triggers_replace = terraform_data.content_version.output

  provisioner "local-exec" {
    # https://developer.hashicorp.com/terraform/language/expressions/strings#heredoc-strings
    command = <<COMMAND
aws cloudfront create-invalidation \
--distribution-id ${aws_cloudfront_distribution.s3_distribution.id} \
--paths '/*'
    COMMAND

  }
}
```

Below screenshots show detailed steps and updated HTML

![image](./assets/week1/UpdateContent_Test.PNG)

![image](./assets/week1/UpdateContent_validatecache.PNG)

![image](./assets/week1/UpdateContent_InvalidateCache.PNG)

![image](./assets/week1/UpdateContent_DistributionEnabled.PNG)

![image](./assets/week1/UpdateContent_UpdatedHTML.PNG)

### Assets Upload

Create an `assets` directory under `public` and upload a few images for our TerraHome in it. Reference the images in `public/index.html`

![image](./assets/week1/httpserver.PNG)

![image](./assets/week1/Listassets.PNG)

![image](./assets/week1/Listassets_2.PNG)

![image](./assets/week1/Assets.gif)

![image](./assets/week1/AssetsUploadedS3Bucket.PNG)