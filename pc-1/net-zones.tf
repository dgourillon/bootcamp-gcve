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






module "zone_teams" {
  count                        = var.team_count
  source                       = "../modules/t1-dhcp-zone/"
  t1_name                      = "t1-lr-team${count.index}"
  edge_cluster_path            = data.nsxt_policy_edge_cluster.edge-cluster.path
  t0_path                      = data.nsxt_policy_tier0_gateway.tier0_gw_gateway.path
  t1_description               = "L1 Logical router for team ${count.index}"
  t1_failover_mode             = "PREEMPTIVE"
  t1_default_rule_logging      = "false"
  t1_enable_firewall           = "true"
  t1_enable_standby_relocation = "false"
  t1_route_advertisement_types = ["TIER1_CONNECTED"]
  t1_pool_allocation           = "ROUTING"
  default_gcve_dns_forwarder   = nsxt_policy_dns_forwarder_zone.defaultgcve.path
  dhcp_path                    = nsxt_policy_dhcp_server.tier_dhcp.path
  overlay_tz_path              = data.nsxt_policy_transport_zone.overlay_tz.path
  default_dns_forwarding_ip    = "10.129.${count.index}.3"
  advertised_subnet_list       = ["10.129.${count.index}.0/25", "10.129.${count.index}.128/25"]
  segments = {
    prod-frontend-segment = {
      display_name = "team${count.index}-frontend-segment"
      description  = "frontend segment for team ${count.index}"
      connectivity = "ON"
      subnet = {
        cidr        = "10.129.${count.index}.1/25"
        dhcp_ranges = ["10.129.${count.index}.10-10.129.${count.index}.100"]
        dhcp_v4_config = {
          server_address = "10.129.${count.index}.2/25"
          dns_servers    = ["10.129.${count.index}.3"]
        }
      }
    },
    prod-backend-segment = {
      display_name = "team${count.index}-backend-segment"
      description  = "backend segment for team ${count.index}"
      connectivity = "ON"
      subnet = {
        cidr        = "10.129.${count.index}.129/25"
        dhcp_ranges = ["10.129.${count.index}.140-10.129.${count.index}.200"]
        dhcp_v4_config = {
          server_address = "10.129.${count.index}.130/25"
          dns_servers    = ["10.129.${count.index}.3"]
        }
      }
    }
  }
  gwf_policies = [
    {
      display_name    = "gwf_allow_policy"
      sequence_number = 100
      rules = [
        {
          action             = "ALLOW"
          destination_groups = []
          source_groups      = ["10.0.0.0/8"]
          direction          = "IN_OUT"
          display_name       = "gwf-allow-internal"
          logged             = false
          services           = []
        },
        {
          action             = "ALLOW"
          destination_groups = []
          source_groups      = []
          direction          = "OUT"
          display_name       = "gfw-allow-egress"
          logged             = false
          services           = []
        },
      ]
    },
    {
      display_name    = "gwf_drop_policy"
      sequence_number = 1000
      rules = [
        {
          action             = "DROP"
          destination_groups = ["10.123.2.0/23"]
          source_groups      = []
          direction          = "IN"
          display_name       = "gfw-drop-all"
          logged             = false
          services           = []
        }
      ]
    },
  ]
}





module "zone_teams_demo" {
  source                       = "../modules/t1-dhcp-zone/"
  t1_name                      = "t1-lr-team-demo0"
  edge_cluster_path            = data.nsxt_policy_edge_cluster.edge-cluster.path
  t0_path                      = data.nsxt_policy_tier0_gateway.tier0_gw_gateway.path
  t1_description               = "L1 Logical router for vmug 0"
  t1_failover_mode             = "PREEMPTIVE"
  t1_default_rule_logging      = "false"
  t1_enable_firewall           = "true"
  t1_enable_standby_relocation = "false"
  t1_route_advertisement_types = ["TIER1_CONNECTED"]
  t1_pool_allocation           = "ROUTING"
  default_gcve_dns_forwarder   = nsxt_policy_dns_forwarder_zone.defaultgcve.path
  dhcp_path                    = nsxt_policy_dhcp_server.tier_dhcp.path
  overlay_tz_path              = data.nsxt_policy_transport_zone.overlay_tz.path
  default_dns_forwarding_ip    = "10.140.0.3"
  advertised_subnet_list       = ["10.140.0.0/25", "10.140.0.128/25"]
  segments = {
    prod-frontend-segment = {
      display_name = "team0-frontend-segment-vmug"
      description  = "vmug frontend segment for team 0"
      connectivity = "ON"
      subnet = {
        cidr        = "10.140.0.1/25"
        dhcp_ranges = ["10.140.0.10-10.140.0.100"]
        dhcp_v4_config = {
          server_address = "10.140.0.2/25"
          dns_servers    = ["10.140.0.3"]
        }
      }
    },
    prod-backend-segment = {
      display_name = "team0-backend-segment-vmug"
      description  = "vmug backend segment for team 0"
      connectivity = "ON"
      subnet = {
        cidr        = "10.140.0.140/25"
        dhcp_ranges = ["10.140.0.140-10.140.0.200"]
        dhcp_v4_config = {
          server_address = "10.140.0.130/25"
          dns_servers    = ["10.140.0.3"]
        }
      }
    }
  }
  gwf_policies = [
    {
      display_name    = "gwf_allow_policy"
      sequence_number = 100
      rules = [
        {
          action             = "ALLOW"
          destination_groups = []
          source_groups      = ["10.0.0.0/8"]
          direction          = "IN_OUT"
          display_name       = "gwf-allow-internal"
          logged             = false
          services           = []
        },
        {
          action             = "ALLOW"
          destination_groups = []
          source_groups      = []
          direction          = "OUT"
          display_name       = "gfw-allow-egress"
          logged             = false
          services           = []
        },
      ]
    },
    {
      display_name    = "gwf_drop_policy"
      sequence_number = 1000
      rules = [
        {
          action             = "DROP"
          destination_groups = ["10.123.2.0/23"]
          source_groups      = []
          direction          = "IN"
          display_name       = "gfw-drop-all"
          logged             = false
          services           = []
        }
      ]
    },
  ]
}


