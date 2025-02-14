################################################################################################################
### Top Level Stuff

# General
tfAwsAccNo = "328645840678"

tfAwsRegion = "eu-west-1"

# Microsoft AD Domain
dnsRootDomain = "inte.local"

r53HostedZoneMap = {
  PublicZone     = "Z09446541SMITS5AHE41T"
  CloudfrontZone = "Z2FDTNDATAQYW2"
}

# PublicR53ZoneNames
PublicR53ZoneName = "integration-te-collinson.com"

# squidHostnamePrefix
# This gets prepended to private zone which is defined in vpc_routing module

roleVariables = {
  tfStateBucketName       = "tfstate.inte.te-general.com"
  deploymentBucketName    = "sitecode.inte.te-general.com"
  appdBucketName          = "appd.inte.te-general.com"
  userdataBucketName      = "userdata.inte.te-general.com"
  postfixConfigBucketName = "squidproxy.inte.poc-te.com"
  squidHostnamePrefix     = "squidnlbproxy"
  squidPostfixPrefix      = "squidpostfix"
}

# Tags
commonTags = {
  oEnvironment      = "inte"
  rEnvironmentName  = "inte"
  rBusinessUnit     = "TE"
  rDepartment       = "DevOps"
  rPONumber         = "18CMISBAU"
  uProjectOrService = "TE Devops Integration"
}

# In the future this should be replaced by using multi-account tfstate references
vpc_peers = {
  rpa-dev = {
    account_id = "917704122904"
    vpc_cidr   = "10.219.0.0/16"
    vpc_id     = "vpc-0c5d455df9c3cfeca"
    aws_region = "eu-west-1"
    vpc_peering_connection_id = {
      inte = "pcx-02bd208f4ec6f4f5e"
    }
  }
}

### Top Level Stuff
#################################################################################################################

#################################################################################################################
### Security Groups
ipsTrustedWeb = [
  "83.231.170.196/32", #Office IP
  "82.129.54.2/32",    #Office IP
  "13.42.74.124/32",   #AWS Netskope IP
  "3.9.40.104/32",     #AWS Netskope IP
  "18.169.60.115/32",  #SNI VMware Cloud IP
  "85.115.32.0/19",    # Forcepoint IP
  "86.111.216.0/23",   # Forcepoint IP
  "116.50.56.0/21",    # Forcepoint IP
  "208.87.232.0/21",   # Forcepoint IP
  "86.111.220.0/22",   # Forcepoint IP
  "103.1.196.0/22",    # Forcepoint IP
  "177.39.96.0/22",    # Forcepoint IP
  "196.216.238.0/23",  # Forcepoint IP
  "192.151.176.0/20",  # Forcepoint IP
  "157.167.0.0/16",    # Forcepoint IP
  "37.156.74.211/32",  # Harry IP
  "86.24.38.164/32",   # Sriram
]

ipsTrustedDevops = ["83.231.170.221/32", "82.129.54.2/32"]

ip_lists = {
  vpnTrustedCidrOffice = [
    "10.60.0.0/16",
    "10.206.137.0/24",
    "10.160.0.0/16",
    "10.215.0.0/16",
    "172.31.0.0/16",
    "10.208.7.0/24",
    "10.208.6.0/24",
    "10.208.5.0/24",
    "10.208.0.0/16" # TE-Hub
  ]
  sepm_mgmt_server = [
    "172.16.7.76/32" #SEPM ON_PREM MGMT SERVER
  ]
  for_sitecorestack_to_squidproxy = ["10.215.0.0/16"]

  bug_log_onprem = [
    "83.231.170.44/32" #BUG LOG ONPREM
  ]
  salesForce        = ["85.222.128.0/19", "159.92.128.0/17", "160.8.0.0/16", "161.71.0.0/17", "163.76.128.0/17", "163.79.128.0/17", "185.79.140.0/22"]
  gatherContent     = ["122.200.135.23/32"]
  genericOutBound   = ["0.0.0.0/0"]
  crowdstrike       = ["100.20.76.137/32", "35.162.239.174/32", "35.162.224.228/32", "34.209.79.111/32", "52.10.219.156/32", "34.210.186.129/32", "54.218.244.79/32", "54.200.109.111/32", "100.20.109.43/32", "44.225.216.237/32", "44.227.134.78/32", "44.224.200.221/32"]
  ppDatalakeInBound = ["10.206.84.0/22"]
}
### Security Groups
################################################################################################################


s3bucketnames = ["test111", "test222", "logging", "backups"]


PrivateR53ZoneName         = "inte.local"
vpc_id_inte                = "vpc-034fdf3e9d30e3bc5"
loungegateway_db_ip__lists = ["10.215.196.116", "10.215.197.116"]
##############################
### Services Configuration

services_config = {
  domain_services = {
    ports = {
      partner             = "9601"
      payment             = "9603"
      payment-card        = "9604"
      payment-network     = "9605"
      access-key          = "9606"
      subscription        = "9607"
      location            = "9608"
      collateral          = "9609"
      product             = "9610"
      order               = "9611"
      delivery            = "9612"
      price               = "9613"
      consumer            = "9614"
      renewal             = "9615"
      translation         = "9617"
      calendar            = "9618"
      fulfilment          = "9619"
      notification        = "9620"
      exchange-rate       = "9621"
      client              = "9622"
      consumer-security   = "9623"
      bill                = "9624"
      document            = "9625"
      inventory           = "9626"
      inventory-capacity  = "9627"
      security            = "9628"
      rule                = "9629"
      businessunit        = "9630"
      datasync            = "9631"
      device              = "9632"
      workflow            = "9634"
      denied-delivery     = "9635"
      wiremock            = "9636"
      productsearch       = "9637"
      shoppingbasket      = "9638"
      accesskey           = "9639"
      platformintegration = "9641"
      booking             = "9642"
      user                = "9643"
      global-consumer     = "9644"
    }
    rds = {
      zipmapHeaders      = "secGroupName|rdsDbInstanceIdentifier|rdsDbName"
      access-key         = "access-key-db|<env_name>-access-key|accesskey"
      accesskey          = "accesskey-db|<env_name>-accesskey|accesskey"
      product            = "product-db|<env_name>-product|product"
      order              = "order-db|<env_name>-order|orders"
      delivery           = "delivery-db|<env_name>-delivery|delivery"
      price              = "price-db|<env_name>-price|price"
      payment-card       = "payment-card-db|<env_name>-payment-card|payment_card"
      payment-network    = "payment-network-db|<env_name>-payment-network|payment_network"
      partner            = "partner-db|<env_name>-partner|partner"
      payment            = "payment-db|<env_name>-payment|payment"
      subscription       = "subscription-db|<env_name>-subscription|subscription"
      eligibility        = "eligibility-db|<env_name>-eligibility|eligibility"
      location           = "location-db|<env_name>-location|location"
      exchange-rate      = "exchange-rate-db|<env_name>-exchange-rate|exchange_rate"
      consumer           = "consumer-db|<env_name>-consumer|consumer"
      renewal            = "renewal-db|<env_name>-renewal|renewal"
      translation        = "translation-db|<env_name>-translation|translation"
      calendar           = "calendar-db|<env_name>-calendar|calendar"
      fulfilment         = "fulfilment-db|<env_name>-fulfilment|fulfilment"
      notification       = "notification-db|<env_name>-notification|notification"
      client             = "client-db|<env_name>-client|client"
      consumer-security  = "consumer-security-db|<env_name>-consumer-security|consumer_security"
      collateral         = "collateral-db|<env_name>-collateral|collateral"
      bill               = "bill-db|<env_name>-bill|bill"
      document           = "document-db|<env_name>-document|document"
      rule               = "rule-db|<env_name>-rule|rule"
      businessunit       = "businessunit-db|<env_name>-businessunit|businessunit"
      inventory          = "inventory-db|<env_name>-inventory|inventory"
      security           = "security-db|<env_name>-security|security"
      inventory-capacity = "inventory-capacity-db|<env_name>-inventory-capacity|inventory_capacity"
      datasync           = "datasync-db|<env_name>-datasync|datasync"
      device             = "device-db|<env_name>-device|device"
      workflow           = "workflow-db|<env_name>-workflow|workflow"
      denied-delivery    = "denied-delivery-db|<env_name>-denied-delivery|denied_delivery"
      shoppingbasket     = "shoppingbasket-db|<env_name>-shoppingbasket|shoppingbasket"
      global-consumer    = "global-consumer-db|<env_name>-global-consumer|global-consumer"
    }
  }
  toggles = {
    general = {
      access-key          = "1"
      accesskey           = "1"
      product             = "1"
      order               = "1"
      delivery            = "1"
      price               = "1"
      payment-card        = "1"
      payment-network     = "1"
      partner             = "1"
      payment             = "1"
      subscription        = "1"
      eligibility         = "1"
      location            = "1"
      exchange-rate       = "1"
      consumer            = "1"
      renewal             = "1"
      translation         = "1"
      calendar            = "1"
      fulfilment          = "1"
      notification        = "1"
      client              = "1"
      consumer-security   = "1"
      collateral          = "1"
      document            = "1"
      bill                = "1"
      businessunit        = "1"
      inventory           = "1"
      inventory-capacity  = "1"
      datasync            = "1"
      security            = "1"
      rule                = "1"
      device              = "1"
      workflow            = "1"
      pricelesscities     = "1"
      denied-delivery     = "1"
      wiremock            = "1"
      productsearch       = "1"
      shoppingbasket      = "1"
      platformintegration = "1"
      global-consumer     = "1"
    }
  }
  common = {
    appd_config = {
      appd_asa_s3_zipname                        = "AppServerAgent-1.8-23.1.0.34620-EVO.zip"
      appd_asa_jar_path                          = "ver23.1.0.34620/javaagent.jar"
      appd_ctrl_hostname                         = "collinsontedev.saas.appdynamics.com"
      appd_agent_accountname_ssmpnamesuffix      = "/userdata/appd.accountname"
      appd_agent_accountaccesskey_ssmpnamesuffix = "/userdata/appd.accountaccesskey"
      appd_agent_applicationname                 = "Travel Experience - INTE"
      appd_account_name                          = "collinsontedev"
    }
  }
  tenable_config = {
    nessusScannerAccount = {
      userKeySsmpnamesuffix      = "/userdata/nessus/user_keypair"
      userPasswordSsmpnamesuffix = "/userdata/nessus/user_password"
    }
  }
}

### Services Configuration
##############################
