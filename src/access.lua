local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local util = require("util");


ngx.req.read_body();


local function validate(token)
      if token == nil then
          return false
      end
      
      local conn = mongo:new()
      ok, err = conn:connect(ngx.var.auth_db, ngx.var.auth_db_port)

      if ok ~= 1 then
         ngx.log(ngx.ERR, 'connect error'..'err:'..err)
      end
      
      ngx.log(ngx.ERR, 'validate token:'..token)
      local db = conn:new_db_handle("authdb")
      local r = db:auth("","")
      local col = db:get_col("tokens")
      local rs = col:find_one({token=token})

      if rs then
        return true
      else
        return false
      end
end

if not validate(util.header_args("token")) then
  ngx.status = ngx.HTTP_UNAUTHORIZED
  ngx.send_headers()
else
  ngx.log(ngx.ERR, '200')
end