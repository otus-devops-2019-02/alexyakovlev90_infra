resource "google_compute_target_pool" "lb_pool" {
  name = "lb-pool"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.app_healthcheck.name}",
  ]
}

resource "google_compute_forwarding_rule" "lb_firewall" {
  name = "lb-firewall"

  target = "${google_compute_target_pool.lb_pool.self_link}"

  port_range = "9292"
}

resource "google_compute_http_health_check" "app_healthcheck" {
  name               = "app-healthcheck"
  port               = "9292"
  timeout_sec        = 1
  check_interval_sec = 1
}
