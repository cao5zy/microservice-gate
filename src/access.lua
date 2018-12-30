local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local util = require("util");


ngx.req.read_body();


local function validate(token)
      local conn = mongo:new()
      err, ok = conn:connect(ngx.var.auth_db, ngx.var.auth_db_port)

      if err then
      	 ngx.log(ngx.ERR, err)
      end
      
      if ok then
      	 ngx.log(ngx.ERR, ok)
      end

      local db = conn:new_db_handle("authdb")
      local r = db:auth("","")
      local col = db:get_col("tokens")
      local token = col:find_one({token=token})

      if token then
        return true
      else
        return false
      end
end

if util.header_args("name") then
  ngx.log(ngx.ERR, "header name---"..header_args("name"))
end

if not validate(util.header_args("token")) then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.send_headers()
end