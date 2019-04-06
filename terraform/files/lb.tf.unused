module "lb-http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  name        = "group-http-lb"
  target_tags = ["reddit-lb"]

  backends = {
    "0" = [
      {
        group = "${google_compute_instance_group.webservers.self_link}"
      },
    ]
  }

  backend_params = [
    # health check path, port name, port number, timeout seconds.
    "/,http,9292,10",
  ]
}

resource "google_compute_firewall" "firewall_puma_lb" {
  name = "allow-puma-lb"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-lb"]
}

resource "google_compute_instance_group" "webservers" {
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    "${google_compute_instance.app.0.self_link}",
    "${google_compute_instance.app.1.self_link}",
  ]

  named_port {
    name = "http"
    port = "9292"
  }

  zone = "${var.zone}"
}
