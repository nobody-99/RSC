:local GatewayName "PPPoE_CU"
:local Distance 2
:local AddressListName "SecondOutDstList6"
:local AddressListComment "SecondOutDstList6"

# Find all addresses in the address list with a comment
:local AddrListRecords [/ipv6 firewall address-list find where list=$AddressListName && comment!=$AddressListComment]

:foreach Record in=$AddrListRecords do={
  :local RecordIp [/ipv6 firewall address-list get $Record address]
  :local RecordComment [/ipv6 firewall address-list get $Record comment]
  :local RouterRule [/ipv6 route find dst-address=$RecordIp]

  # If the router rule doesn't exist, create it
  :if ([:len $RouterRule] = 0) do={
    /ipv6 route add dst-address=$RecordIp gateway=$GatewayName distance=$Distance routing-table=main comment=$RecordComment
    :log info "Added router rule for $RecordIp with comment $RecordComment in address list $AddressListName"
  }
}
