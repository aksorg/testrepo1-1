# WebApp Pattern creation
This folder provides guidance on the creating WebApp pattern for v2.


## **Overview** 

In this pattern Webapp can be created using docker containers. For Docker container only images from ACR can be used.

## **Structure of Deployment**

- For the deployment we are using layered approach. In the respective layers the following resources are getting created.

1. App Layer
    - ACR
    - App service plan
    - App service published as Docker Container
    - Key vault
   The input file stored for the App layer in the following path for the respective layers:
        - Data Layer : ` ci/infra/terraform/webapp/vars/layer1-applayer.tfvars `

2. Frontend Layer
    - Application gateway
    - if user does'nt provide Key vault having secrets for application gateway, Keyvault is created with secrets.    
    The input file stored for the frontend layer in the following path for the respective layers:
        - App layer : ` ci/infra/terraform/webapp/vars/layer2-frontendlayer.tfvars ` 

2. Network Layer
    - Vnet integration to appservice
    - Private endpoints are created for ACR, keyvault and App service.    
    The input file stored for the network layer in the following path for the respective layers:
        - App layer : ` ci/infra/terraform/webapp/vars/layer3-networklayer.tfvars ` 

- After the infra layer is created the required application can be deployed and the associated workflow is also added to the respective repository.

## Pre-Requisites
#### Subscription and Resource Group
- Subscription should be available in M&S tenant.
- Resource Group should be available in your Subscription.

#### Azure Resources
- One VNET available in same subscription / region of the webapp is required.
- **Three subnets which has no other services in it is required**
  1. WebApp Integration Subnet (**Microsoft.Web/serverFarms** must be added in delegation)
  2. Private Endpoint Subnet 
  3. Application gateway Subnet
- NSG and NSG rules should be created and added in Subnets.

### 2. **GitHub Repository**

- Environment configured in repository (nonprod and prod).
- Azure Subscription and Service Principals configured as GitHub secrets in the respective environments.
- Github PAT token configured as GitHub secret
- if keyvault is created for application gateway, secrets should be configured as GITHUB secrets.

## Inputs Given in the Form

Following are the inputs given in the Muziris input form:

|S.No|Parameter Name|Description|Optional/Mandatory|
|----|--------------|---------|----------------|
|1.|Portfolio Name|The name of the Portfolio owning this application|Any subscription id|mandatory|
|2.|Resource group name|Resource group in which webapp will be deployed|mandatory|
|3|Location|Location in which webapp will be deployed|mandatory|
|4|Application Name|Name of the application||mandatory|
|5|OS type|OS of the App service plan.|Linux, Windows|mandatory|
|6|Vnet name|Virtual network name in which all subnets lies|mandatory|
|7|Vnet integration subnet|Subnet name for vnet integration for webapp|mandatory|
|8|Private endpoint subnet|Subnet name for private endpoints|Optional|
|9|Application gateway subnet| Subnet name used for application gateway|Optional|

# How to consume

## 1. **Muziris As Front End UI**

Using Muziris as a platform to recieve inputs from user and is able to deploy the webapp using minimal and basic inputs. Refer the Pre-requisites and the inputs to be known before filling the form.

## 2. **From Muziris to Users' Repo**

- After entering the details proceed to create the webapp by following the on screen instructions. 

- After review of the inputs in muziris itself , please proceed to create the Webapp.

- User will be directed to a screen with muziris actions running and a log can be view on the right pane.

- A **link to the pull request for the repository** given by the user will be created, after clicking the link user will be **directed to the pull request raised**

## 3. **Infra As Code and Workflows**

- Muziris action pushes the entire infra as a code in the respective branch created on pull request (Branch Name: create-ApplicationName) and the required GitHub Action workflow files into the repository in the following paths:
    
  1. Infra as Code : ``` ci/infra/terraform ```
  
  2. Github Action Workflows : ``` .github/workflows ```

## 4. **WebApp Plan**

- Pull request triggered by Muziris will **automatically trigger a WebApp deployment Plan (Workflow name: bootstrap--webapp-plan)** which configures the secrets required to provision the webapp as well as the statefiles to maintain the resource state. (Move to the Actions Tab)

## 5. **WebApp Apply**

- As soon as the pull request is approved and branch is merged with main **Webapp Apply workflow is automatically triggered (Workflow name: Webapp-run-apply)** that deploys the webapp  in cloud.

A webapp is now succesfully deployed with the required configurations.