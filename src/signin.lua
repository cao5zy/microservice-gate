local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local util = require("util");

ngx.header.content_type = "application/json";

ngx.req.read_body();

local function signin(name, pwd)
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

      local col = db:get_col("users")
      local usr = col:find_one({name=name, pwd=util.getsha(pwd)})

      return usr
end

ngx.status = 200
ngx.print(signin(util.post_args('name'), util.post_args('pwd')))
ngx.exit(200)