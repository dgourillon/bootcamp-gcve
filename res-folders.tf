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

module "folder_l1" {
  for_each = var.vsphere_folder_config_l1
  source   = "../modules/vcenter-folder"

  folder_path       = each.key
  folder_type       = each.value.type
  datacenter        = each.value.datacenter
  role_assignments  = each.value.role_assignments
  custom_attributes = each.value.custom_attributes
  tags              = each.value.tags
}


module "folder_l2" {
  for_each = var.vsphere_folder_config_l2
  source   = "../modules/vcenter-folder"

  folder_path       = each.key
  folder_type       = each.value.type
  datacenter        = each.value.datacenter
  role_assignments  = each.value.role_assignments
  custom_attributes = each.value.custom_attributes
  tags              = each.value.tags

  depends_on = [module.folder_l1]
}

module "folder_teams" {
  count    = 4
  source   = "../modules/vcenter-folder"

  folder_path       = "team${count.index}"
  folder_type       = "vm"
  datacenter        = "Datacenter"
  "role_assignments" : {
      "owner_permission" : {
        "user_or_group" : "dgourillon\\\\user-team-${count.index}",
        "is_group" : false,
        "propagate" : true,
        "role" : "Cloud-Owner-Role"
      }
  custom_attributes = {}
  tags              = {}
}

