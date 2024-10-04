variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "sm_project_id" {
  description = "The GCP project ID where Secret Manager stores the certificate files"
  type        = string
}

variable "suffix" {
  description = "A suffix to add before every resource name to be created"
  type        = string
}

variable "domains" {
  description = "List of domains for the SSL certificate"
  type        = list(string)
}


variable "psc_endpoints" {
  description = "List of Private Service Connect endpoints"
  type = list(object({
    region          = string
    vpc             = string
    subnetwork      = string
    psc_target      = string
  }))
}

variable "ssl_certificate" {
  description = "Name of the Secret Manager secret storing the certificate file in PEM coding"
  type        = string
}

variable "ssl_private_key" {
  description = "Name of the Secret Manager secret storing the certificate key file in PEM coding"
  type        = string
}
