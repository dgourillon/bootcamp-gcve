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
  default_dns_forwarding_ip    = "10.149.0.3"
  advertised_subnet_list       = ["10.129.${count.index}.0/24"]
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
          dns_servers    = ["10.149.0.3"]
        }
      }
    },
    prod-backend-segment = {
      display_name = "team${count.index}-backend-segment"
      description  = "backend segment for team ${count.index}"
      connectivity = "ON"
      subnet = {
        cidr        = "10.129.${count.index}.129/25"
        dhcp_ranges = ["10.130.${count.index}.140-10.130.${count.index + 1}.200"]
        dhcp_v4_config = {
          server_address = "10.129.${count.index}.130/25"
          dns_servers    = ["10.149.0.3"]
        }
      }
    }
  }
  gwf_policies = [
    {
      display_name = "gwf_allow_policy"
      rules = [
        {
          action             = "ALLOW"
          destination_groups = []
          source_groups      = ["10.0.0.0/8"]
          direction          = "IN_OUT"
          display_name       = "gwf-allow-rdp"
          logged             = false
          services           = ["SSH", "RDP"]
        },
        {
          action             = "ALLOW"
          destination_groups = ["10.0.0.0/8"]
          source_groups      = []
          direction          = "IN_OUT"
          display_name       = "gfw-allow-internal"
          logged             = false
          services           = ["DNS", "HTTP"]
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



