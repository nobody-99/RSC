:local address_list_name "your-address-list-name-here"
:local router_name "your-router-name-here"

# Find all addresses in the address list with a comment
:local addresses [/ipv6 firewall address-list find where list=$address_list_name && comment!=""]

:foreach address in=$addresses do={
  :local ip [/ipv6 firewall address-list get $address address]
  :local comment [/ipv6 firewall address-list get $address comment]
  :local router_rule [/ipv6 route find dst-address=$ip]

  # If the router rule doesn't exist, create it
  :if ([:len $router_rule] = 0) do={
    /ipv6 route add dst-address=$ip gateway=$router_name comment=$comment
    :log info "Added router rule for $ip with comment $comment in address list $address_list_name"
  }

  # Update the existing router rule
  :if ([:len $router_rule] > 0) do={
    /ipv6 route set [find dst-address=$ip] gateway=$router_name comment=$comment
    :log info "Updated router rule for $ip with comment $comment in address list $address_list_name"
  }
}
