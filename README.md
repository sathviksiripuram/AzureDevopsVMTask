# AzureDevopsVMTask
Azure is a cloud computing platform and service provided by Microsoft. It offers a wide range of cloud-based services, including computing, storage, networking, databases.

## Deploying to Windows IIS on Azure VM

**1. Create a Virtual Machine on Azure Portal:**
  - Go to the [Azure Portal](https://portal.azure.com).
 - Click on "Create a resource" > "Virtual machine".
 - Choose a subscription, resource group, region, and VM name.
 - Select a Windows Server image (e.g., Windows Server 2019).
 - Choose the appropriate VM size, such as Standard DS1_v2.
 - Configure the administrator username and password.
 - Open port 80 for HTTP traffic (or any other port you prefer).
 - Review the configuration and click "Create" to provision the VM.

**2. Connect to the Virtual Machine:**
- Once the VM is provisioned, connect to it using Remote Desktop Protocol (RDP).
- Obtain the public IP address of the VM from the Azure Portal.
- Use a Remote Desktop Client to connect to the VM using the public IP address, username, and password configured during VM creation.

**3.1 Configure IIS:(Manually):**
- After connecting to the VM, open "Server Manager".
- Click on "Add roles and features".
- Select "Web Server (IIS)" and click "Next" through the wizard to install IIS.
- Once IIS is installed, open Internet Information Services (IIS) Manager from the Start menu.
- Right-click on "Sites" and select "Add Website".
- Specify a name for the website, set the physical path to the folder containing your .NET application files, and choose the appropriate binding settings (e.g., port 80, IP address).
- Click "OK" to create the website.

**3.2 Configure IIS(Using Terraform):**
- By using Custom scripts we can configure
- To deploy custom scripts for configuring Internet Information Services (IIS) using Azure Virtual Machine Extensions, you can follow these steps:
- **Prepare the Script**:
   Write the PowerShell script that contains the configuration settings for IIS.
- **Upload the Script to Azure Blob Storage**:
   Upload the PowerShell script to an Azure Storage Account Blob Container.
- **Validate IIS Configuration**:
   Once the virtual machine extension deployment is complete, verify that the IIS configuration has been applied as expected.


  
**4. Deploy the .NET Application:**
- Copy the published files of your .NET web application to the physical path specified in IIS.
- Ensure that the required .NET runtime is installed on the server.
- Optionally, configure any additional settings or modules required by your application in IIS.

**5. Access the Application:**
- Once the application is deployed and configured in IIS, you can access it from a web browser by navigating to the public IP address of the VM.
- If everything is set up correctly, you should see your application running and accessible over the internet.


**Infrastructure as Code (IaC) Configuration:**
- Choose an IaC(e.g., Terraform, ARM/Bicep, Pulumi).
- I have chosen terraform
- Terraform commands:

  terraform init:
    -  It downloads and installs the provider plugins and modules specified in the configuration files.
    -  This command is typically the first step when starting a new Terraform project or when working in a new environment.
      
    terraform plan:
    - The `terraform plan` command generates an execution plan.
    - `terraform plan` does not make any changes to your infrastructure. Instead, it provides a preview of what terraform apply would do.
  
    terraform apply:
    - The `terraform apply` command applies the changes defined in your Terraform configuration files.
    - After applying changes, Terraform updates its state file to reflect the current state of the infrastructure.
    
    terraform destroy:
    - The `terraform destroy` command is used to destroy all resources defined in your Terraform configuration files.
    
- Visit the [Terraform website](https://www.terraform.io/downloads.html) and download the appropriate version of Terraform for Windows.
- Verify Installation:

  Open a new command prompt window and run the following command:
  
  ```bash
  terraform --version
  ```
- Write configuration scripts to define all the resources (VMs, Load Balancer, Networking) using Terraform.
- Execute the scripts to automatically create the resources in Azure, replicating the manual deployment process.



This way, you can deploy the .NET application on an Azure Virtual Machine running Windows Server manually and then automate the deployment process using IaC for future deployments.



## Deploying to Linux behind an Azure Load Balancer

**1. Manually Create Linux Virtual Machines:**
 - Log in to the [Azure Portal](https://portal.azure.com).
- Navigate to "Virtual machines" and click "Add" to create a new VM.
- Choose a subscription, resource group, region, and VM name.
- Select an appropriate Linux distribution (e.g., Ubuntu, CentOS) and VM size.
- Configure the administrator username and password (or SSH key).
- Set up inbound rules to allow traffic on ports required by your application (e.g., HTTP port 80).
- Review the configuration, then click "Create" to provision the VM(s).
  
**2. Deploy the Application to Linux VM(s):**
- Connect to the Linux VM using SSH.
- Copy your application files to the VM or clone your application repository.
- install the .Net SDK
  ```bash
  sudo apt update
  sudo apt install dotnet-sdk-8.0
  ```
- Verify the installation:
  ```bash
  dotnet --version
    ```
- Run the application:
  ```bash
  dotnet /path/filename.dll
  ```
- Check the output by:
  ```bash
  curl localhost:portnumber
   ```
- Creating a service:
    ```bash
    sudo nano /etc/systemd/system/filename.service
    ```
- Define service configuration:
  ```bash
    [Unit]
    Description=My .NET Core Application
    After=network.target
    
    [Service]
    WorkingDirectory=/path/to/your/.NET/application
    ExecStart=/usr/bin/dotnet /path/to/your/.NET/application/filename.dll
    Restart=always
    # Restart service after 10 seconds if it crashes
    RestartSec=10
    SyslogIdentifier=myapp
    User=your_username # Change to the user that should run the service
    Environment=ASPNETCORE_ENVIRONMENT=Production
    Environment=ASPNETCORR_URLS=http://localhost:8001
    [Install]
    WantedBy=multi-user.target
  ```
- Save the changes in the text editor and exit.
- Enable the service to start:
    ```bash
  sudo systemctl enable filename
   ```
- Start the service:
    ```bash
  sudo systemctl start filename
   ```
- Check the status of the service to ensure it's running without any errors:
   ```bash
   sudo systemctl status filename
   ```
- you can check using
   ```bash
  curl localhost:8001
  ```
- Install Nginx:
  ```bash
  sudo apt update
  sudo apt install nginx
  ```
- Start Nginx:
  ```bash
  sudo systemctl start nginx
  ```
- To set up reverse proxy, edit the Default Configuration file of Nginx:
  ```bash
  sudo nano /etc/nginx/sites-enabled/default
    ```
  Add the following configuration:
  ```bash
  server {
      listen 80;
      server_name _; 
      location / {
          proxy_pass http://localhost:8001;
      }
  }
  ```
- Save the file.
- Finally, you should test the Nginx configuration for syntax errors:
  ```bash
  sudo nginx -t
  ```
- If the syntax is correct, you can reload Nginx to apply the changes:
  ```bash
  sudo systemctl reload nginx
  ```
- Now, you can access the web application on the VM using IP address or DNS.
- Follow same steps for the Virtual Machine-2 





    
      
   

      


**3. Manually Create Azure Load Balancer:**

- In the Azure Portal, navigate to "Load balancers" and click "Add" to create a new load balancer.
- Choose a subscription, resource group, region, and load balancer name.
- Configure the frontend IP address and port (e.g., public IP, port 80).
- Define backend pools by adding the Linux VM(s) as backend targets.
- Set up health probes to monitor the health of your application instances.
- Configure load balancing rules to route traffic to backend pool(s).
- Review the configuration, then click "Create" to provision the load balancer.

**4. Test Load Balancer's Distribution:**
- Once the load balancer is provisioned, note down its public IP address or DNS name.
- Access the application through the load balancer's public IP or DNS name in a web browser.
- Verify that the application responds correctly and the load balancer distributes traffic evenly among the VMs.

**Infrastructure as Code (IaC) Configuration:**
- Choose an IaC(e.g., Terraform, ARM/Bicep, Pulumi).
- I have chosen terraform
- Visit the [Terraform website](https://www.terraform.io/downloads.html) and download the appropriate version of Terraform for Windows.
- Verify Installation:

  Open a new command prompt window and run the following command:
  
  ```bash
  terraform --version
  ```
- Write configuration scripts to define all the resources (VMs, Load Balancer, Networking) using Terraform.
- Execute the scripts to automatically create the resources in Azure, replicating the manual deployment process.

## Architecture

![image](https://github.com/sathviksiripuram/AzureDevopsVMTask/assets/98334373/11888c2a-d35a-462b-aa00-d537d6953359)


1.**Backend Pool**: A backend pool is a collection of backend instances (such as VMs or VM scale sets) that are configured to receive and process network traffic from a load balancer or application gateway. These backend instances can be placed in one or more virtual networks.

2.**Virtual Network**: A virtual network (VNet) in Azure is a logically isolated network that you can deploy Azure resources into. It provides a secure communication channel between the resources deployed within the VNet

3.**Availability set**:An availability set is a logical grouping of two or more virtual machines (VMs) within the same datacenter region. The purpose of an availability set is to provide high availability 

4.**Load balancer**:A load balancer is a networking component designed to evenly distribute incoming network traffic across multiple servers or backend resources.

5.**NIC**:A Network Interface (NIC) is a networking component that connects a virtual machine (VM) to a virtual network (VNet) and provides it with connectivity to other resources within the Azure environment and beyond

6.**Subnets**: Subnets are subdivisions of a VNet that allow you to segment the network into smaller, more manageable parts. Each subnet can contain a range of IP addresses and is associated with specific Azure resources.
