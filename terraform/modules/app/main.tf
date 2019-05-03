resource "google_compute_instance" "app" {
//  name         = "reddit-app"
  name         = "app"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  # for provisioners connection
  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.private_key_path)}"
  }

//  provisioner "remote-exec" {
//    inline = [
//      "export DATABASE_URL=${var.mongo_url}",
//    ]
//  }
//
//  # copy file
//  provisioner "file" {
//    source      = "${path.module}/files/puma.service"
//    destination = "/tmp/puma.service"
//  }
//
//  provisioner "remote-exec" {
//    script = "${path.module}/files/deploy.sh"
//  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["9292","80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
