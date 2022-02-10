New-NetFirewallRule -DisplayName "Allow Outbound Port 80" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port 443" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 443" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow

