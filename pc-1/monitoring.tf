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

module "gcve-monitoring" {
  source                  = "../modules/gcve-monitoring"
  gcve_region             = "us-central1"
  project                 = "gcve-dgo"
  secret_vsphere_server   = var.vsphere_server
  secret_vsphere_user     = var.vsphere_user
  secret_vsphere_password = var.vsphere_password
  vm_mon_name             = "monitoring-vm"
  vm_mon_type             = "e2-small"
  vm_mon_zone             = "us-central1-a"
  sa_gcve_monitoring      = "sa-gcve-monitoring"
  subnetwork              = "projects/network-target-1/regions/us-central1/subnetworks/us-central1-subnet-2"
  create_dashboards       = "true"
  network_project         = "network-target-1"
}

