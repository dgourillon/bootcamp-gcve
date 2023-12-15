/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


// NSX-T Segments
team_count = 10

segments = [
  {
    description  = "example-subnet1"
    display_name = "example-subnet1"
    cidr         = "10.123.1.1/24"
    tags = {
      tier        = "web",
      environment = "dev"
    }
  },
  {
    description  = "example-subnet2"
    display_name = "example-subnet2"
    cidr         = "10.123.1.1/24"
    tags = {
      tier        = "backend",
      environment = "dev"
    }
  }
]

// NSX-T gateway firewall
gwf_policies = [
  {
    display_name = "gwf_allow_policy"
    rules = [
      {
        action             = "ALLOW"
        destination_groups = []
        source_groups      = []
        direction          = "IN_OUT"
        display_name       = "gfw-allow-all"
        logged             = false
        services           = []
      },
    ]
  },

]

// NSX-T distributed firewall
dfw_policies = [
  {
    display_name    = "dfw_allow_policy"
    sequence_number = 1
    rules = [
      {
        action             = "ALLOW"
        destination_groups = []
        source_groups      = []
        direction          = "IN_OUT"
        display_name       = "dfw-allow-ssh"
        logged             = false
        services           = ["SSH", "RDP"]
      },
      {
        action             = "ALLOW"
        destination_groups = []
        source_groups      = []
        direction          = "OUT"
        display_name       = "dfw-allow-egress"
        logged             = false
        services           = []
      },
      {
        action             = "ALLOW"
        destination_groups = []
        source_groups      = []
        direction          = "IN_OUT"
        display_name       = "dfw-allow-dhcp"
        logged             = false
        services           = ["DHCP-Client", "DHCP-Server"]
      }
    ]
  },
  {
    display_name    = "dfw_baseline_deny_policy"
    sequence_number = 1000
    rules = [
      {
        action             = "DROP"
        destination_groups = []
        source_groups      = []
        direction          = "IN"
        display_name       = "dfw-drop-all"
        logged             = true
        services           = []
      }
    ]
  },
]

##### VSphere section

vsphere_folder_config_l1 = {
  "DEV" = {
    "datacenter" : "Datacenter",
    "type" : "vm",
    "custom_attributes" : {
      # "abc.xyz.Custom.Attribute" : "myvalue",
      # "abc1.xyz1.Custom1.Attributes11" : "my2value"
    },
    "tags" : {
      # "abc-l0" : {
      #   "category_name" : "cat-abc"
      # },
      # "newtag-l0" : {
      #   "category_name" : "cat-abc"
      # }
    },
    "role_assignments" : {
      "permission1" : {
        "user_or_group" : "vsphere.local\\\\ExternalIPDUsers",
        "is_group" : true,
        "propagate" : true,
        "role" : "Monitoring-Role"
      },
      "permission2" : {
        "user_or_group" : "vsphere.local\\\\DCClients",
        "is_group" : true,
        "propagate" : true,
        "role" : "Monitoring-Role"
      }
    }
  },
  "UAT" = {
    "datacenter" : "Datacenter",
    "type" : "vm",
    "custom_attributes" : {
    },
    "tags" : {
    },
    "role_assignments" : {
    }
  },
  "PROD" = {
    "datacenter" : "Datacenter",
    "type" : "vm",
    "custom_attributes" : {
    },
    "tags" : {
    },
    "role_assignments" : {
    }
  }
}

vsphere_folder_config_l2 = {
  "DEV/App 1" = {
    "datacenter" : "Datacenter",
    "type" : "vm",
    "custom_attributes" : {
    },
    "tags" : {
    },
    "role_assignments" : {
    }
  }
}

vsphere_resource_pool_config = {
  dev-resource-pool = {
    datacenter = "Datacenter",
    location   = "Cluster/cluster",
    role_assignments = {
      permission1 = {
        user_or_group = "vsphere.local\\DCClients"
        is_group      = true
        propagate     = true
        role          = "Monitoring-Role"
      },
      permission2 = {
        user_or_group = "vsphere.local\\DCClients"
        is_group      = true
        propagate     = true
        role          = "Monitoring-Role"
      },
    },
  },
  uat-resource-pool = {
    datacenter = "Datacenter",
    location   = "Cluster/cluster",
    role_assignments = {
      permission1 = {
        user_or_group = "vsphere.local\\DCClients"
        is_group      = true
        propagate     = true
        role          = "No access"
      },
      permission2 = {
        user_or_group = "vsphere.local\\DCClients"
        is_group      = true
        propagate     = true
        role          = "No access"
      },
    },
  },
  prod-resource-pool = {
    datacenter = "Datacenter",
    location   = "Cluster/cluster",
    role_assignments = {
      permission1 = {
        user_or_group = "vsphere.local\\DCClients"
        is_group      = true
        propagate     = true
        role          = "Monitoring-Role"
      },
      permission2 = {
        user_or_group = "vsphere.local\\DCClients"
        is_group      = true
        propagate     = true
        role          = "Monitoring-Role"
      },
    },
  },
}

