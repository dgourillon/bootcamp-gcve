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

# In the future this could be generated from the output of stage 01-privatecloud.
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = ">= 3.2.7"
    }
  }
}

provider "nsxt" {
  host                 = var.nsxt_url
  username             = var.nsxt_user
  password             = var.nsxt_password
  allow_unverified_ssl = false
}


provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = false
}
