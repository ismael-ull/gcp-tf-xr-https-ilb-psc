resource "google_compute_region_network_endpoint_group" "neg" {
  count                 = length(var.psc_endpoints)
  project               = var.project_id
  name                  = "${var.suffix}-neg-${count.index}"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  region                = var.psc_endpoints[count.index].region
  network               = var.psc_endpoints[count.index].vpc
  subnetwork            = var.psc_endpoints[count.index].subnetwork
  psc_target_service    = var.psc_endpoints[count.index].psc_target
}

resource "google_compute_backend_service" "backend_service" {
  project               = var.project_id
  count                 = length(var.psc_endpoints)
  name                  = "${var.suffix}-backend-service"
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTPS"
  log_config { enable = true }

  dynamic "backend" {
    for_each = google_compute_region_network_endpoint_group.neg
    content {
      group = backend.value.id
    }
  }
 }


resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  count           = length(var.psc_endpoints)
  name            = "${var.suffix}-url-map-${count.index}"
  default_service = google_compute_backend_service.backend_service[count.index].id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  project                          = var.project_id
  count                            = length(var.psc_endpoints)
  name                             = "${var.suffix}-proxy"
  url_map                          = google_compute_url_map.url_map[count.index].id
  certificate_manager_certificates = ["//certificatemanager.googleapis.com/${google_certificate_manager_certificate.default.id}"]
}

resource "google_compute_address" "ilb_ip" {
  count        = length(var.psc_endpoints)
  name         = "ilb-ip-${count.index}"
  project      = var.project_id
  address_type = "INTERNAL"
  region       = var.psc_endpoints[count.index].region
  subnetwork   = var.psc_endpoints[count.index].subnetwork
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project               = var.project_id
  count                 = length(var.psc_endpoints)
  name                  = "${var.suffix}-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy[count.index].id
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_address            = google_compute_address.ilb_ip[count.index].address
  network               = var.psc_endpoints[count.index].vpc
  subnetwork            = var.psc_endpoints[count.index].subnetwork
}

resource "google_certificate_manager_certificate" "default" {
  project     = var.project_id
  name        = "${var.suffix}-certificate"
  description = "sample google managed all_regions certificate with issuance config for terraform"
  scope       = "ALL_REGIONS"
  self_managed {
      pem_certificate = data.google_secret_manager_secret_version.ssl_certificate.secret_data
      pem_private_key = data.google_secret_manager_secret_version.ssl_private_key.secret_data
      }

}


data "google_secret_manager_secret_version" "ssl_certificate" {
project     = var.sm_project_id
  secret = var.ssl_certificate
}

data "google_secret_manager_secret_version" "ssl_private_key" {
project     = var.sm_project_id
  secret = var.ssl_private_key
}
