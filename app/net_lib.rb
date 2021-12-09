# frozen_string_literal: true

def local_ip
  ($gtk.exec 'powershell -Command (Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address).IPAddressToString').strip
end

def external_ip
  ($gtk.exec 'powershell -Command (Resolve-DnsName -Name myip.opendns.com -Server 208.67.222.220).IPAddress').strip
end
