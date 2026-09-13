package main

import rego.v1

allowed_ports := {80,443}

deny contains msg if {
    some rc in input.resource_changes
    rc.type == "aws_security_group"
    some ingress in rc.change.after.ingress
    some cidr in ingress.cidr_blocks
    cidr == "0.0.0.0/0"
    not port_is_allowed(ingress)
    msg := sprintf(
        "%s: ingress open to 0.0.0.0/0 on port %d-%d, only 80/443 allowed",
        [rc.address, ingress.from_port, ingress.to_port],
    )
}

port_is_allowed(ingress) if {
    ingress.from_port == ingress.to_port
    ingress.from_port in allowed_ports
}