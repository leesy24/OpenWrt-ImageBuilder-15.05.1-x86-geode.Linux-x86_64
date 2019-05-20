local pcall, dofile, _G = pcall, dofile, _G

module "luci.company"

if pcall(dofile, "/etc/company_release") then
	name     = _G.NAME
	year     = _G.YEAR
	model    = _G.MODEL
	prefix   = _G.PREFIX
	origin   = _G.ORIGIN
	revision = _G.REVISION
end
