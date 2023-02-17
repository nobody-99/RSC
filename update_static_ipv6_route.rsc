:local AddressListName "CM6_OUT_DST_LIST"
:local GatewayName "PPPoE_CM"

# Find all addresses in the address list with a comment
:local AddrListRecords [/ipv6 firewall address-list find where list=$AddressListName && comment!="dummy"]

:foreach Record in=$AddrListRecords do={
  :local RecordIp [/ipv6 firewall address-list get $Record address]
  :local RecordComment [/ipv6 firewall address-list get $Record comment]
  :local RouterRule [/ipv6 route find dst-address=$RecordIp]

  # If the router rule doesn't exist, create it
  :if ([:len $RouterRule] = 0) do={
    /ipv6 route add dst-address=$RecordIp gateway=$GatewayName distance=1 routing-table=main comment=$RecordComment
    :log info "Added router rule for $RecordIp with comment $RecordComment in address list $AddressListName"
  }
}
