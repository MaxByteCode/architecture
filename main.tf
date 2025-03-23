provider "azurerm" {
  features {}
}

# Define providers for different regions
provider "azurerm" {
  alias   = "us"
  features {}
}

provider "azurerm" {
  alias   = "eu"
  features {}
}

# Create resource groups
resource "azurerm_resource_group" "us_rg" {
  provider = azurerm.us
  name     = "myResourceGroupUS"
  location = "East US"
}

resource "azurerm_resource_group" "eu_rg" {
  provider = azurerm.eu
  name     = "myResourceGroupEU"
  location = "West Europe"
}

# Create a virtual network in US
resource "azurerm_virtual_network" "us_vnet" {
  provider                = azurerm.us
  name                    = "myVNetUS"
  location                = azurerm_resource_group.us_rg.location
  resource_group_name     = azurerm_resource_group.us_rg.name
  address_space           = ["10.0.0.0/16"]
}

# Create a virtual network in EU
resource "azurerm_virtual_network" "eu_vnet" {
  provider                = azurerm.eu
  name                    = "myVNetEU"
  location                = azurerm_resource_group.eu_rg.location
  resource_group_name     = azurerm_resource_group.eu_rg.name
  address_space           = ["10.1.0.0/16"]
}

# Create a subnet for the frontend in US
resource "azurerm_subnet" "us_frontend_subnet" {
  provider                = azurerm.us
  name                    = "frontendSubnetUS"
  resource_group_name     = azurerm_resource_group.us_rg.name
  virtual_network_name    = azurerm_virtual_network.us_vnet.name
  address_prefixes        = ["10.0.1.0/24"]
}

# Create a subnet for the backend in US
resource "azurerm_subnet" "us_backend_subnet" {
  provider                = azurerm.us
  name                    = "backendSubnetUS"
  resource_group_name     = azurerm_resource_group.us_rg.name
  virtual_network_name    = azurerm_virtual_network.us_vnet.name
  address_prefixes        = ["10.0.2.0/24"]
}

# Create a subnet for the frontend in EU
resource "azurerm_subnet" "eu_frontend_subnet" {
  provider                = azurerm.eu
  name                    = "frontendSubnetEU"
  resource_group_name     = azurerm_resource_group.eu_rg.name
  virtual_network_name    = azurerm_virtual_network.eu_vnet.name
  address_prefixes        = ["10.1.1.0/24"]
}

# Create a subnet for the backend in EU
resource "azurerm_subnet" "eu_backend_subnet" {
  provider                = azurerm.eu
  name                    = "backendSubnetEU"
  resource_group_name     = azurerm_resource_group.eu_rg.name
  virtual_network_name    = azurerm_virtual_network.eu_vnet.name
  address_prefixes        = ["10.1.2.0/24"]
}

# Create Network Security Group for US Frontend Subnet
resource "azurerm_network_security_group" "us_frontend_nsg" {
  provider                = azurerm.us
  name                    = "usFrontendNSG"
  location                = azurerm_resource_group.us_rg.location
  resource_group_name     = azurerm_resource_group.us_rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix   = "*"
  }
}

# Associate NSG with US Frontend Subnet
resource "azurerm_subnet_network_security_group_association" "us_frontend_nsg_association" {
  subnet_id                 = azurerm_subnet.us_frontend_subnet.id
  network_security_group_id = azurerm_network_security_group.us_frontend_nsg.id
}

# Create Network Security Group for US Backend Subnet (optional, can be configured similarly)
resource "azurerm_network_security_group" "us_backend_nsg" {
  provider                = azurerm.us
  name                    = "usBackendNSG"
  location                = azurerm_resource_group.us_rg.location
  resource_group_name     = azurerm_resource_group.us_rg.name

   # Add rules as needed, e.g., allow traffic from frontend to backend.
}

# Associate NSG with US Backend Subnet (optional)
resource "azurerm_subnet_network_security_group_association" "us_backend_nsg_association" {
   subnet_id                 = azurerm_subnet.us_backend_subnet.id 
   network_security_group_id=azurerm_network_security_group.us_backend_nsg.id 
} 

# Repeat similar steps for EU Frontend and Backend NSGs and associations

resource "azurerm_network_security_group" "eu_frontend_nsg" {
   provider               =azurerm.eu 
   name                    ="euFrontendNSG"
   location               =azurerm_resource_group.eu_rg.location 
   resource_group_name     =azurerm_resource_group.eu_rg.name 

   security_rule { 
      name="Allow-HTTP" 
      priority=100 
      direction="Inbound" 
      access="Allow" 
      protocol="Tcp" 
      source_port_range="*" 
      destination_port_range="80" 
      source_address_prefix="*" 
      destination_address_prefix="*" 
   } 
} 

resource "azurerm_subnet_network_security_group_association" "eu_frontend_nsg_association"{ 
   subnet_id=azurerm_subnet.eu_frontend_subnet.id 
   network_security_group_id=azurerm_network_security_group.eu_frontend_nsg.id 
} 

# Create App Service Plan and Function App for Frontend in US

resource "azurerm_app_service_plan" "us_frontend_service_plan" {
   provider                 =azurerm.us 
   name                      ="myFrontendAppServicePlanUS"
   location                 =azurerm_resource_group.us_rg.location 
   resource_group_name      =azurerm_resource_group.us_rg.name 

   sku { 
      tier="Standard"
      size="S1"
      capacity="" 
   } 
} 

resource "azurerm_function_app" "us_frontend_function_app"{ 
   provider                 =azurerm.us 
   name                      ="myFrontendFunctionAppUS"
   location                 =azurerm_resource_group.us_rg.location 
   resource_group_name      =azurerm_resource_group.us_rg.name 
   app_service_plan_id      =azurerm_app_service_plan.us_frontend_service_plan.id 

   app_settings={ 
      FUNCTIONS_WORKER_RUNTIME="node"  
      # Add other necessary settings here.
   }  
} 

# Repeat similar steps for Backend Function App in US

resource "azurerm_app_service_plan" "us_backend_service_plan"{ 
   provider                 =azurerm.us  
   name                      ="myBackendAppServicePlanUS"
   location                 =azurerm_resource_group.us_rg.location  
   resource_group_name      =azurm.resourcegroup.us_rg.name  

   sku {  
      tier="Standard"
      size="S1"
      capacity=""  
   }  
}  

resource "azurm.function_app""us_backend_function_app"{  
    provider                  ="azurm.us""  
    name                      ="myBackendFunctionAppUS""  
    location                  ="azure.resourcegroup.us_rg.location""  
    resourcegroupname         ="azure.resourcegroup.us_rg.name""  
    appserviceplanid          ="azure.appserviceplan.us_backend_service_plan.id""  

    appsettings={  
       functions_worker_runtime="node""  
       # Add other necessary settings here."  
    }  
}  

# Repeat similar steps for Frontend and Backend Apps in EU

resource “azurm.appserviceplan” “eu_frontend_service_plan” {  
    provider                  ="azure.eu""  
    name                      ="myFrontendAppServicePlanEU""  
    location                  ="azure.resourcegroup.eu_rg.location""  
    resourcegroupname         ="azure.resourcegroup.eu_rg.name""  

    sku {  
       tier="Standard""  
       size="S1""  
       capacity=""  
    }   
}  

resource “azure.function_app” “eu_frontend_function_app” {    
    provider                  ="azure.eu""    
    name                      ="myFrontendFunctionAppEU""    
    location                  ="azure.resourcegroup.eu_rg.location""    
    resourcegroupname         ="azure.resourcegroup.eu_rg.name""    
    appserviceplanid          ="azure.appserviceplan.eu_frontend_service_plan.id""    

    appsettings={    
       functions_worker_runtime="node""    
       # Add other necessary settings here."    
    }    
}    

# Repeat similar steps for Backend Function App in EU

resource “azure.appserviceplan” “eu_backend_service_plan” {   
     provider                   ="azure.eu""   
     name                       ="myBackendAppServicePlanEU""   
     location                   ="azure.resourcegroup.eu_rg.location""   
     resourcegroupname          ="azure.resourcegroup.eu_rg.name""   

     sku {   
        tier="Standard""   
        size="S1""   
        capacity=""   
     }   
}   

resource “azure.function_app” “eu_backend_function_app” {   
     provider                   ="azure.eu""   
     name                       ="myBackendFunctionAppEU""   
     location                   ="azure.resourcegroup.eu_rg.location""   
     resourcegroupname          ="azure.resourcegroup.eu_rg.name""   
     appserviceplanid           ="azure.appserviceplan.eu_backend_service_plan.id"

     appsettings={   
        functions_worker_runtime="node"""   
        # Add other necessary settings here."    
     }    
}    

# Create a storage account for the Function App in US
resource "azurerm_storage_account" "us_storage" {
  provider                  = azurerm.us
  name                      = "mystorageaccountus"
  resource_group_name       = azurerm_resource_group.us_rg.name
  location                  = azurerm_resource_group.us_rg.location
  account_tier              = "Standard"
  account_replication_type   = "LRS"
}

# Create a storage account for the Function App in EU
resource "azurerm_storage_account" "eu_storage" {
  provider                  = azurerm.eu
  name                      = "mystorageaccounteu"
  resource_group_name       = azurerm_resource_group.eu_rg.name
  location                  = azurerm_resource_group.eu_rg.location
  account_tier              = "Standard"
  account_replication_type   = "LRS"
}

# Create the Function App in US
resource "azurerm_function_app" "us_function_app" {
  provider                   = azurerm.us
  name                       = "vehicleMonitor"
  location                   = azurerm_resource_group.us_rg.location
  resource_group_name        = azurerm_resource_group.us_rg.name
  app_service_plan_id        = azurerm_app_service_plan.us_service_plan.id
  storage_account_name       = azurerm_storage_account.us_storage.name
  storage_account_access_key   = azurerm_storage_account.us_storage.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME   = "node"
    AzureWebJobsStorage        = azurerm_storage_account.us_storage.primary_connection_string 
  }
}

# Create the Function App in EU
resource "azurerm_function_app" "eu_function_app" {
  provider                   = azurerm.eu
  name                       = "maintenance"
  location                   = azurerm_resource_group.eu_rg.location
  resource_group_name        = azurerm_resource_group.eu_rg.name
  app_service_plan_id        = azurerm_app_service_plan.eu_service_plan.id
  storage_account_name       = azurerm_storage_account.eu_storage.name
  storage_account_access_key   = azurerm_storage_account.eu_storage.primary_access_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME   = "node"
    AzureWebJobsStorage        = azurerm_storage_account.eu_storage.primary_connection_string 
  }
}

# Create an App Service Plan for US Function App
resource "azurerm_app_service_plan" "us_service_plan" {
  provider                  = azurerm.us
  name                      = "myAppServicePlanUS"
  location                  = azurerm_resource_group.us_rg.location
  resource_group_name       = azurerm_resource_group.us_rg.name

  sku {
    tier     = "Standard"
    size     = "S1"
    capacity = ""
  }
}

# Create an App Service Plan for EU Function App
resource "azurerm_app_service_plan" "eu_service_plan" {
  provider                  = azurerm.eu
  name                      = "myAppServicePlanEU"
  location                  = azurerm_resource_group.eu_rg.location
  resource_group_name       = azurerm_resource_group.eu_rg.name

  sku {
    tier     = "Standard"
    size     = "S1"
    capacity = ""
  }
}



# Create IoT Hub in US
resource "azurerm_iothub" "us_iothub" {
  provider                = azurerm.us
  name                    = "myIoTHubUS"
  resource_group_name     = azurerm_resource_group.us_rg.name
  location                = azurerm_resource_group.us_rg.location

  sku {
    name     = "S1"
    capacity = 1
  }
}

# Create IoT Hub in EU
resource "azurerm_iothub" "eu_iothub" {
  provider                = azurerm.eu
  name                    = "myIoTHubEU"
  resource_group_name     = azurerm_resource_group.eu_rg.name
  location                = azurerm_resource_group.eu_rg.location

  sku {
    name     = "S1"
    capacity = 1
  }
}

# Create Event Hub Namespace in US
resource "azurerm_eventhub_namespace" "us_namespace" {
  provider                = azurerm.us
  name                    = "myeventhubnamespaceUS"
  resource_group_name     = azurerm_resource_group.us_rg.name
  location                = azurerm_resource_group.us_rg.location

  sku {
    name     = "Standard"
    capacity = 1
  }
}

# Create Event Hub Namespace in EU
resource "azurerm_eventhub_namespace" "eu_namespace" {
  provider                = azurerm.eu
  name                    = "myeventhubnamespaceEU"
  resource_group_name     = azurerm_resource_group.eu_rg.name
  location                = azurerm_resource_group.eu_rg.location

  sku {
    name     = "Standard"
    capacity = 1
  }
}

# Create Event Hub in US
resource "azurerm_eventhub" "us_eventhub" {
  provider                = azurerm.us
  name                    = "myeventhubUS"
  resource_group_name     = azurerm_resource_group.us_rg.name
  namespace_name          = azurerm_eventhub_namespace.us_namespace.name

  partition_count         = 2
  message_retention       = 1
}

# Create Event Hub in EU
resource "azurerm_eventhub" "eu_eventhub" {
  provider                = azurerm.eu
  name                    = "myeventhubEU"
  resource_group_name     = azurerm_resource_group.eu_rg.name
  namespace_name          = azurerm_eventhub_namespace.eu_namespace.name

  partition_count         = 2
  message_retention       = 1
}

# Create IoT Hub endpoint for Event Hub in US
resource "azurerm_iothub_endpoint_eventhub" "us_endpoint_eventhub" {
  resource_group_name     = azurerm_resource_group.us_rg.name
  iothub_name             = azurerm_iothub.us_iothub.name
  name                    = "endpoint_eventhub_us"

  connection_string       = azurerm_eventhub.us_eventhub.default_primary_connection_string
}

# Create IoT Hub endpoint for Event Hub in EU
resource "azurerm_iothub_endpoint_eventhub" "eu_endpoint_eventhub" {
  resource_group_name     = azurerm_resource_group.eu_rg.name
  iothub_name             = azurerm_iothub.eu_iothub.name
  name                    = "endpoint_eventhub_eu"

  connection_string       = azurerm_eventhub.eu_eventhub.default_primary_connection_string
}

# Create Storage Account for Functions in US
resource "azurerm_storage_account" "us_storage" {
  provider                  = azurerm.us
  name                      = "mystorageaccountus"
  resource_group_name       = azurerm_resource_group.us_rg.name
  location                  = azurerm_resource_group.us_rg.location
  account_tier              = "Standard"
  account_replication_type   = "LRS"
}

# Create Storage Account for Functions in EU
resource "azurerm_storage_account" "eu_storage" {
  provider                  = azurerm.eu
  name                      = "mystorageaccounteu"
  resource_group_name       = azurerm_resource_group.eu_rg.name
  location                  = azurerm_resource_group.eu_rg.location
  account_tier              = "Standard"
  account_replication_type   = "LRS"
}

# Create App Service Plan for Functions in US
resource "azurerm_app_service_plan" "us_service_plan" {
  provider                  = azurerm.us
  name                      = "myAppServicePlanUS"
  location                  = azurerm_resource_group.us_rg.location
  resource_group_name       = azurerm_resource_group.us_rg.name

   sku {
    tier     = "Consumption"
    size     = ""
   }
}

# Create App Service Plan for Functions in EU 
resource "azurerm_app_service_plan" "eu_service_plan" {
   provider                  = azurerm.eu 
   name                      ="myAppServicePlanEU"
   location                 =azurerm_resource_group.eu_rg.location 
   resource_group_name      =azurerm_resource_group.eu_rg.name 

   sku { 
      tier="Consumption"
      size="" 
   } 
}

# Create Function App in US 
resource "azurerm_function_app" "us_function_app" { 
   provider                  =azurerm.us 
   name                       ="vehicleMonitor"
   location                  =azurerm_resource_group.us_rg.location 
   resource_group_name       =azurerm_resource_group.us_rg.name 
   app_service_plan_id       =azurerm_app_service_plan.us_service_plan.id 
   storage_account_name      =azurerm_storage_account.us_storage.name 
   storage_account_access_key  =azurerm_storage_account.us_storage.primary_access_key 

   app_settings={ 
      FUNCTIONS_WORKER_RUNTIME="node" 
      AzureWebJobsStorage=azurerm_storage_account.us_storage.primary_connection_string 
      EVENTHUB_CONNECTION_STRING=azurerm_eventhub.us_eventhub.default_primary_connection_string 
   } 
} 

# Create Function App in EU 
resource "azurerm_function_app" "eu_function_app" { 
   provider                  =azurerm.eu 
   name                       ="vehicleMonitor"
   location                  =azurerm_resource_group.eu_rg.location 
   resource_group_name       =azurerm_resource_group.eu_rg.name 
   app_service_plan_id       =azurerm_app_service_plan.eu_service_plan.id 
   storage_account_name      =azurerm_storage_account.eu_storage.name 
   storage_account_access_key  =azurerm_storage_account.eu_storage.primary_access_key 

   app_settings={ 
      FUNCTIONS_WORKER_RUNTIME="node" 
      AzureWebJobsStorage=azurerm_storage_account.eu_storage.primary_connection_string 
      EVENTHUB_CONNECTION_STRING=azurerm_eventhub.eu_eventhub.default_primary_connection_string  
   }  
}
