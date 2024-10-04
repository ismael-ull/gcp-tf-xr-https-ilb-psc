# Internal Cross Regional HTTPS Load Balancer with PSC Backends

## Overview
This module will create the Load Balancer with the desire quantity of backends, each of them pointing to a PSC Neg in every desired region. The certificate used in the frontend should be stored (public and private keys) in two secrets in GCP Secret Manager so the integration with any kind of vault is as simple as sync those secrets and it wouln't be neccesary to expose those files in any pipeline or workflow if this is automated.

The module creates the following resources:
- **Network Endpoint Groups (NEGs)**: For managing endpoints for the internal load balancer.
- **Backend Services**: To define how the load balancer routes traffic to the NEGs.
- **URL Maps**: To route requests to the appropriate backend service.
- **Target HTTPS Proxies**: To handle HTTPS requests and forward them to the URL maps.
- **Internal IP Addresses**: For the load balancer to use.
- **Global Forwarding Rules**: To direct traffic to the target HTTPS proxies.
- **SSL Certificate**: For securing HTTPS traffic.

Al resources will startt with the same suffix, declared as variable.

## Requirements.
As is said before, the certificate files should be stored in two Secret Manager secrets (could be in a sepparate project) in PEM encoding format.
Also, the backends NEGs are PRIVATE_SERVICE_CONNECT type so is neccesary to have the corresponding Service Attachements already created.
the variable 

## Variables

- `project_id`:
  - **Description**: The GCP project ID where resources will be created.
  - **Type**: `string`

- `sm_project_id`:
  - **Description**: The GCP project ID where Secret Manager stores the certificate files.
  - **Type**: `string`

- `domains`:
  - **Description**: List of domains for the SSL certificate.
  - **Type**: `list(string)`

- `suffix`:
  - **Description**: A suffix to add before every resource name to be created.
  - **Type**: `string`

- `psc_endpoints`:
  - **Description**: List of Private Service Connect endpoints.
  - **Type**: `list(object({ region = string, vpc = string, subnetwork = string, psc_target = string }))`

- `ssl_certificate`:
  - **Description**: Name of the Secret Manager secret storing the certificate file in PEM coding.
  - **Type**: `string`

- `ssl_private_key`:
  - **Description**: Name of the Secret Manager secret storing the certificate key file in PEM coding"
  - **Type**: `string`


## Using the module

```hcl
  module "internal_https_lb" {
  source = "./ilb"
  project_id              = "PROJECT-ID"
  sm_project_id           = "SM-PROJECT-ID"
  suffix                  = "name-suffix"
  domains                 = ["a.example.com"]  
  ssl_private_key         = "projects/SM-PROJECT-ID/secrets/PRIVATE-KEY-SECRET"
  ssl_certificate         = "projects/SM-PROJECT-ID/secrets/CERTIFICATE-SECRET"
  psc_endpoints           = [
      {
      region         = "REGION-A"
      vpc_project_id = "PROJECT-ID"
      vpc            = "projects/PROJECT-ID/global/networks/VPC-A"
      subnetwork     = "projects/PROJECT-ID/regions/REGION-A/subnetworks/SUBNET-A"
      psc_target     = "projects/PROJECT-ID/regions/REGION-A/serviceAttachments/SERVICE-ATTACHEMENT-NAME"
       },
       {
       region         = "REGION-B"
       vpc_project_id = "PROJECT-ID"
       vpc            = "projects/PROJECT-ID/global/networks/VPC-B"
       subnetwork     = "projects/PROJECT-ID/regions/REGION-B/subnetworks/SUBNET-B"
       psc_target     = "projects/PROJECT-ID/regions/REGION-B/serviceAttachments/SERVICE-ATTACHEMENT-NAME"
      }
      ]
}
```


