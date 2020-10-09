local dns	= require "dns"
local dnsbls	= {%DNSBL_LIST%}
local ip	= ngx.var.remote_addr

function cached_ko ()
	return ngx.shared.dnsbl_cache:get(ip) == "ko"
end

function cached ()
	return ngx.shared.dnsbl_cache:get(ip) ~= nil
end

function check ()
	local rip = dns.ip_to_arpa()
	for k, v in ipairs(dnsbls) do
		local req = rip .. "." .. v
		local ips = dns.get_ips(req)
		for k2, v2 in ipairs(ips) do
			a,b,c,d = v2:match("([%d]+).([%d]+).([%d]+).([%d]+)")
			if a == "127" then
				ngx.shared.dnsbl_cache:set(ip, "ko", 86400)
				return true
			end
		end
	end
	ngx.shared.dnsbl_cache:set(ip, "ok", 86400)
	return false
end
