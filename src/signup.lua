local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local util = require('util')

ngx.header.content_type = "application/json";

ngx.req.read_body();

local function signup(name, pwd)
      local conn = mongo:new()
      err, ok = conn:connect(ngx.var.auth_db, ngx.var.auth_db_port)

      
      if err then
      	 ngx.log(ngx.ERR, err)
      end
      
      if ok then
      	 ngx.log(ngx.ERR, 'signup-db connected')
      end

      local db = conn:new_db_handle("authdb")
      local ok, err = db:auth("","")

      local col = db:get_col("users")
      local n, err = col:insert({{name=name, pwd=util.getsha(pwd)}})

      if n == nil then ngx.log(ngx.ERR, err) end


end

ngx.status = 201
signup(util.post_args('user'), util.post_args('pwd'))
ngx.exit(201)