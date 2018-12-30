local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local util = require("util");
local json = require('cjson');

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
      ngx.log(ngx.ERR, name..pwd)
      local usr = col:find_one({name=name, pwd=pwd})

      if usr then
          return json.encode({name=usr['name'], pwd=usr['pwd']})
      else
	  return nil
      end

end

ngx.status = 200
ngx.say(signin(util.post_args('name'), util.getsha(util.post_args('pwd'))))
ngx.exit(200)