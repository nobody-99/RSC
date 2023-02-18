:local GatewayName "PPPoE_CU"
:local Distance 2
:local AddressListName "SecondOutDstList6"
:local AddressListComment "SecondOutDstList6"

# Step 1: Find all route rules with the specified Gateway and Distance, and get the associated IP addresses
:local RoutesTemp [/ipv6 route find where gateway=$GatewayName && distance=$Distance]
:local AddressesTBC [:toarray "" ]
:foreach RouteTemp in=$RoutesTemp do={
  :local AddressTBC [/ipv6 route get $RouteTemp dst-address]
  :set AddressesTBC ($AddressesTBC, $AddressTBC)
}

# Step 2: Find all addresses in the address list with the specified name and comment
:local AddrListsTemp [/ipv6 firewall address-list find where list=$AddressListName && comment!=$AddressListComment]
:local AddressesValid [:toarray "" ]
:foreach AddrListTemp in=$AddrListsTemp do={
  :local AddressValid [/ipv6 firewall address-list get $AddrListTemp address]
  :set AddressesValid ($AddressesValid, $AddressValid)
}

# Step 3: Loop through each AddressesTBC and remove any rules where the IP address is not in the valid address list
:foreach AddressTemp in=($AddressesTBC) do={
  :if ([:find $AddressesValid $AddressTemp] < 0) do={
    :local RouterRules [/ipv6 route find where dst-address=$AddressTemp && gateway=$GatewayName && distance=$Distance]
    :foreach RouterRule in=$RouterRules do={
      /ipv6 route remove $RouterRule
      :log info "Removed router rule for $AddressTemp with gateway $GatewayName and distance $Distance"
    }
  }
}
