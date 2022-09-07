locals {
  origin_groups = {
    for name, og in var.origin_groups : name => defaults(og, {
      session_affinity_enabled                                  = true
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10
      load_balancing = {
        additional_latency_in_milliseconds = 0
        sample_size                        = 16
        successful_samples_required        = 3
      }
    })
  }

  origins = {
    for name, origin in var.origins : name => defaults(origin, {
      health_probes_enabled          = true
      certificate_name_check_enabled = true
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1
      origin_host_header             = origin.host_name
    })
  }
}
