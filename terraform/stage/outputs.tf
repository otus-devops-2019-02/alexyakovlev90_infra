output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

//output "lb_external_ip" {
//  value = "${google_compute_forwarding_rule.lb_firewall.ip_address}"
//}

