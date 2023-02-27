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


variable "vm_name" {
  type        = string
  description = "The name of the virtual machine"
}

variable "datacenter" {
  type        = string
  description = "Datacenter name where the VM will be located"
}

variable "cluster" {
  type        = string
  description = "Cluster name where the VM will be located"
}

variable "datastore" {
  type        = string
  description = "Datastore name where the VM will be located"
}

variable "resource_pool" {
  type        = string
  description = "Resource pool name where the VM will be assigned"
}

variable "folder" {
  type        = string
  description = "Folder name where the VM will be located"
}

variable "guest_os_type" {
  type        = string
  description = "The guest ID for the operating system"
}

variable "annotation" {
  type        = string
  description = "User-provided description of the VM"
  default     = "Terraform-managed VM"
}

variable "num_cpu" {
  type        = number
  description = "The number of virtual processors to assign to the VM"
}

variable "num_memory" {
  type        = number
  description = "The size of the virtual machine's memory, in MB"
}

variable "network" {
  type        = string
  description = "The managed object reference ID of the network on which to connect the virtual machine network interface"
}

variable "cdrom_path" {
  type        = string
  description = "Single CD-ROM device path to be attached to the VM"
  default     = ""
}

variable "default_storage_policy_id" {
  type        = string
  description = "Default Storage Policy ID"
  default     = "vSAN Default Storage Policy"
}

variable "disks" {
  type = map(object({
    size             = number
    thin_provisioned = bool
    unit_number      = number
    storage_policy   = string
  }))
  description = "Virtual disks assigned to the VM"
  default     = {}
}
