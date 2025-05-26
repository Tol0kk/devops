# Configuration Management Tools and Infrastructure as Code

# Infrastructure Declaration using Terraform

We choose to declare all the machine in our infrastructure using Terraform. We use it to declare our infrastructure on OVH Cloud. 

## Terraform

[Terraform](https://developer.hashicorp.com/) is an open-source Infrastructure as Code (IaC) tool developed by HashiCorp that uses a cloud provider–agnostic, declarative language to define and manage infrastructure. It allows users to provision resources across multiple cloud platforms like AWS, Azure, and Google Cloud without needing to learn each provider’s GUI—only Terraform's documentation is needed. Terraform (b1.5+) use the Business Source License (BSL). 

## OVH

[OCHCloud](https://www.ovhcloud.com/en/) is a European cloud service provider offering a wide range of infrastructure solutions, including virtual machines, dedicated servers, web hosting, and public/private cloud services. Known for its strong data privacy practices and competitive pricing, OVHcloud operates its own data centers and global fiber network, providing scalable and secure cloud solutions.

We took OHV Cloud because it is French and that get a 200€ Credit to try different things with it. The Web interface is quite convenient.

## Configuration

We followed [this](https://help.ovhcloud.com/csm/fr-public-cloud-compute-terraform?id=kb_article_view&sysparm_article=KB0050792) OVH tutorial to setup the Terraform using OVH Cloud.

When using Terraform in general we give access to Terraform to perform actions  (Create a network, VM, Bucket, ...) under our CLoud provider account. Thus we need to given some identification token to the Terraform CLI. 

<a href="https://api.ovh.com/createToken/?GET=/*&POST=/*&PUT=/*&DELETE=/*">
<img src="./assets/ovhKey.png" alt="drawing" width="200"/>
</a>

We can than deploy our infrastructure with the followings commands

```sh
# Enter a bash compliant shell

# Create workspace
terraform workspace new test_terraform

# Create .env file using .template.env and https://api.ovh.com/createToken

# Source .env
. .env
# Source OpenRC variable from openrc.sh
source ./openrc.sh

# Init terraform project
terraform init
terraform plan

# Create infra
terraform apply

# Delete infra (Optional)
terraform destroy

# Print available Openstack Images
openstack image list --public

# Print available Openstack Flavors (virtual machine type)
openstack flavor list

# Generate Ansible inventory
terraform output -json | jq .ansible_inventory.value | sed 's/^"\|"$//g' |  { echo -e "$(cat)"; } > ../ansible/environments/production/hosts 
```

# Systems Configuration using Ansible 

We use [Ansible](https://github.com/ansible/ansible) to configure our systems. We use it to configure our machines.

We have 3 types of roles given to our machines:
- Common: for all the machines
- Master: for the master node
- Worker: for the worker nodes

And we created a production infrastructure. 

To deploy our configuration to all the instances we use the following command:
```sh
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/environments/production/hosts ansible/playbook.yml
```

This will install containerd, Kubernetes and configure the cluster. It will then deploy the application kubernetes configuration. 

# Building the doodle application using Nix

We started to use nix to build the application reproducibly. Thanks to nix we managed to build the application and a a docker images that can be deployed on a kubernetes cluster or a docker isntances. We made 2 docker images one for the backend and one for the frontend. 

# Kubernetes 

We managed to deploy our application on a kubernetes cluster locally using minikube. you can find the relevant files and command in the kube/ folder. 

# Configuration Pitfalls

We did some experimentation with creating virtual machine for each services of the application. But getting internet on those vm without edit the host network ocnfiguration was not possible. But we got the application in a "working state". But we were thinking that we could easly install teh vms natively on the instances. But we found out that we couldn't use a custom os images on OVH Cloud. But we sucessfuly managed to "corrupt" the image of the instance to get nixos installed on them (see terraform/nixos_deploy.fr).

Since we where short in time and we already had a working local kubernetes cluster. We deciced that it will be easier to just install kubernetes on the instances and deploy the application on it for the configuration using Ansible since we knew how to use it. 

After more than 8 hours of trying to get kubernetes to work on the isntances it kept crashing. Not our services but the kube-system pods. We could not even use kubectl. We tried using containerd and docker-cri but still nothings worked. We decided to give up.

Deployment should only be done using the command in this files. 

# Conclusion

Appart from kubernetes not working we manged to get the application working on the local cluster. And to deploy isntances with terraform without issues. So we decided to consider the project as working. Even if is not really. Since configuration on the ubuntu instances using ansible is not working. We might really consider using nix-anywhere to deploy the application. We have some starting point configuration of kubernetes master and worker nodes. in the nix/systems/ directory. 

The teraform configuration is working really well. And Openstack is really a nice isntance provider over OVH Cloud and others. It is really realiable. 

# Future Work

- Use nix to configure kubernetes master and worker nodes. It might work better. or jsut fix the ansible configuration but really error and documentation are not helpful. 
- Manage secrets using vault. Either sops-nix if using nix or ansible-vault if using ansible.
- Handle SSL certificate  using nginx in the kubernetes cluster. Would need IngressController and cert-manager. That is complex to setup without using helm. Helm seem to be the only way to setup easly cert-manager and nginx as an IngressController for the whole cluster. 

# PS:

After some work (its +7hour after the deadline) we managed to install and deploy correctly kubernetes using nixos. We managed to corrupt the ovh vm. But since it's late we can't really fix things now. 

<!-- Settings up new machine is time consuming and can become complicated when it need to be done entirely remotely. 
We could use [Ansible](https://github.com/ansible/ansible), or [Chef](https://github.com/chef/chef) that would allow us to create "Cookbook" that specify commands and steps to configure our systems. Those tools are the most used in the industry in term of configuration. But they still have some issue in term of reproducibility and don't prevent configuration drift as they are not immutable.

It all boils down to "Declarative vs Imperative Configuration".

<img src="./assets/AnsibleNixosMeme.png" alt="drawing" width="200"/>

We choose to go the more declarative way and use Nix/NixOS to do the configuration fo the systems. 

[Nix/NixOS](https://nixos.org/) is a powerful tool to create and build reproducible software systems. We can perform the building our project and configure the systems our software will run on using the same language and configuration language. Which is enjoyable & convenient.  -->

# Annexes 

## The Doodle App

The doodle application use multiple services. We have an SQL Server, etherpad and a mail server.

Here is the description of doodle app architecture and dependancies.
- Doodle Frontend (Angular 10/Typescript)
    - Static files served by a httpd server.
    - Port 3000
    - Call by user (Must be publicly available):
        - Doodle Backend with `http://doodle-api:8080` endpoint
        - Etherpad with `http://etherpad:9001`
- Doodle Back (Quarkus/Java JDK 11)
    - Port 8080
    - Call directly (Can be intern):
        - Database with `jdbc:mysql://mysql:3306` endpoint
        - Mail Server with `http://mail:2525`
- Database (MariaDB)
    - Port 3306
- Etherpad 1.8.6
    - Port 9001
- Mail Server
    - Port 2525

# Services Deployment using Kubernetes