module resource_group {
        source                  = "./modules/resourcegroup"
        app_name_prefix         = var.app_name_prefix
        subscription_prefix     = var.subscription_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
        location                = var.location
        tags                    = var.tags
}

module storage_account {
        source                  = "./modules/storageaccount"
        resource_group_name     = module.resource_group.output_resource_group_name
        location                = module.resource_group.output_resource_group_location
        account_tier            = var.account_tier
        account_replication_type= var.account_replication_type
        app_name_prefix         = var.app_name_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
        env_prefix              = var.env_prefix
        #storage_account_name    = var.saname
}

module public_ip{
        source                  = "./modules/publicip"
        resource_group_name     = module.resource_group.output_resource_group_name
        location                = module.resource_group.output_resource_group_location
        app_name_prefix         = var.app_name_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
        env_prefix              = var.env_prefix
}

module virtual_network1 {
        source                  = "./modules/vnet"
        resource_group_name     = module.resource_group.output_resource_group_name
        location                = module.resource_group.output_resource_group_location
        subscription_prefix     = var.subscription_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
        address_space           = var.addressspace
}

module virtual_network2 {
        source                  = "./modules/vnet"
        resource_group_name     = module.resource_group.output_resource_group_name
        location                = module.resource_group.output_resource_group_location
        subscription_prefix     = var.subscription_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
        address_space           = var.addressspace
}

module subnet1 {
        source                  = "./modules/subnet"
        resource_group_name     = module.resource_group.output_resource_group_name
        vnet_name               = module.virtual_network1.output_vnet_name
        subscription_prefix     = var.subscription_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
}

module subnet2 {
        source                  = "./modules/subnet"
        resource_group_name     = module.resource_group.output_resource_group_name
        vnet_name               = module.virtual_network2.output_vnet_name
        subscription_prefix     = var.subscription_prefix
        region_prefix           = var.region_prefix
        ordinal_prefix          = var.ordinal_prefix
}

# Creates VNET peerings from First VNET to Second VNET and also from Second VNET to First VNET
module peering1 {
        source                  = "./modules/vnetpeering"
        resource_group_name     = module.resource_group.output_resource_group_name
        vnet_name               = module.virtual_network1.output_vnet_name
        virtual_network_name    = module.virtual_network1.output_vnet_name
        peerings                = [
{ name = module.virtual_network2.output_vnet_name, remote_virtual_network_id = module.virtual_network2.output_vnet_id }
  ]
}

module nsg {
        source                  = "./modules/nsg"
        resource_group_name     = module.resource_group.output_resource_group_name
        location                = module.resource_group.output_resource_group_location
        policy_name_prefix      = var.policy_name_prefix
        ordinal_prefix          = var.ordinal_prefix
        inbound_rules           = [
    {
      name                       = "allow-port80-inbound"
      priority                   = 100
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "10.10.10.10"
      destination_address_prefix = "10.10.10.10"
      description                = "allow-port80-inbound"
    },
    {
      name                   = "deny-port22-inbound"
      priority               = 200
      access                 = "Deny"
      protocol               = "Udp"
      source_address_prefix  = "20.20.20.20"
      destination_port_range = 22
      description            = "deny-port22-inbound"
    }
  ]
  outbound_rules = [
    {
      name                       = "allow-port80-outbound"
      priority                   = 100
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = 80
      destination_address_prefix = "10.10.10.10"
      description                = "allow-port80-outbound"
    },
    {
      name                   = "deny-port443-outbound"
      priority               = 200
      access                 = "Deny"
      protocol               = "*"
      source_port_range      = 443
      destination_port_range = 3389
      description            = "deny-port443-outbound"
    }
  ]
}

module firewall {
        source                          = "./modules/firewall"
        resource_group_name             = module.resource_group.output_resource_group_name
        location                        = module.resource_group.output_resource_group_location
        env_prefix                      = var.env_prefix
        region_prefix                   = var.region_prefix
        ordinal_prefix                  = var.ordinal_prefix
        azure_firewall_configuration    = var.azure_firewall_configuration
        subnet_id                       = module.subnet1.output_subnet_id1
        public_ip_address_id            = module.public_ip.output_public_ip_id
}

module frontdoor {
        source                          = "./modules/frontdoor"
        resource_group_name             = module.resource_group.output_resource_group_name
        env_prefix                      = var.env_prefix
        region_prefix                   = var.region_prefix
        ordinal_prefix                  = var.ordinal_prefix
        routing_rule                    = var.routing_rule
        accepted_protocols              = var.accepted_protocols
        patterns_to_match               = var.patterns_to_match
        frontend_endpoints              = var.frontend_endpoints
        forwarding_protocol             = var.forwarding_protocol
        backendPool_name                = var.backendPool_name
        backendPool_LB                  = var.backendPool_LB
        backendPool_HP                  = var.backendPool_HP
        hostheader                      = var.hostheader
        host_name                       = var.host_name
        frontend_endpoint_name          = var.frontend_endpoint_name
}

module cdn {
        source                          = "./modules/cdn"
        resource_group_name             = module.resource_group.output_resource_group_name
        location                        = module.resource_group.output_resource_group_location
        env_prefix                      = var.env_prefix
        region_prefix                   = var.region_prefix
        ordinal_prefix                  = var.ordinal_prefix
        sku                             = var.sku
        origin_name                     = var.origin_name
        cdn_host_name                   = var.cdn_host_name
}

module appgateway {
        source                          = "./modules/appgateway"
        resource_group_name             = module.resource_group.output_resource_group_name
        location                        = module.resource_group.output_resource_group_location
        subnet_id                       = module.subnet1.output_subnet_id1
        public_ip_address_id            = module.public_ip.output_public_ip_id
        service_prefix                  = var.service_prefix
        env_prefix                      = var.env_prefix
        region_prefix                   = var.region_prefix
        ordinal_prefix                  = var.ordinal_prefix
        appgw_sku_name                  = var.appgw_sku_name
        appgw_tier                      = var.appgw_tier
        gateway_ip_configuration_name   = var.gateway_ip_configuration_name
        frontend_ip_configuration_name  = var.frontend_ip_configuration_name
        backend_address_http_pool_name  = var.backend_address_http_pool_name
        backend_address_https_pool_name = var.backend_address_https_pool_name
        backend_http_settings_name      = var.backend_http_settings_name
        backend_https_settings_name     = var.backend_https_settings_name
        appgw_list1_hostname            = var.appgw_list1_hostname
        certpath                        = var.certpath

}

module vpngateway {
        source                          = "./modules/vpngateway/site-to-site"
        resource_group_name             = module.resource_group.output_resource_group_name
        location                        = module.resource_group.output_resource_group_location
        peer_vpn_gateway                = var.peer_vpn_gateway
        peer_subnet_address_spaces      = var.peer_subnet_address_spaces
        env_prefix                      = var.env_prefix
        region_prefix                   = var.region_prefix
        ordinal_prefix                  = var.ordinal_prefix
        service_prefix                  = var.service_prefix
        subnet_id                       = module.subnet1.output_subnet_id1
        public_ip_address_id            = module.public_ip.output_public_ip_id
        vpn_connection                  = var.vpn_connection
        vpn_psk                         = var.vpn_psk
}

module cosmos_db {
        source                                  = "./modules/cosmosdb"
        resource_group_name                     = module.resource_group.output_resource_group_name
        location                                = module.resource_group.output_resource_group_location
        env_prefix                              = var.env_prefix
        region_prefix                           = var.region_prefix
        ordinal_prefix                          = var.ordinal_prefix
        app_name_prefix                         = var.app_name_prefix
        cosmos_db_account_name                  = var.cosmos_db_account_name
        failover_location                       = var.failover_location
        azurerm_cosmosdb_sql_database_name      = var.azurerm_cosmosdb_sql_database_name
        azurerm_cosmosdb_sql_container          = var.azurerm_cosmosdb_sql_container

}