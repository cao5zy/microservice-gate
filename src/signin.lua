local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local util = require("util");
local json = require('cjson');

ngx.header.content_type = "text/plain";

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


      function insert_token(token)
          local tokens = db:get_col("tokens")
	  tokens:insert({{token=token, expdate=util.expdate()}})

          return token
      end
      if usr then
          return insert_token(usr['name']..'$$'..util.gentoken(usr['pwd']))
      else
	  return nil
      end

end

local token = signin(util.post_args('name'), util.getsha(util.post_args('pwd')))

if token then
  ngx.status = 201
  ngx.print(token)
  ngx.exit(201)
else
  ngx.status = 401
  ngx.exit(401)
end
