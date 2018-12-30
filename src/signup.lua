local p = "/usr/local/openresty/lualib/"
local p1 = "/lua_app/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s?.lua;%s",
	        p, p, p1, m_package_path)

local mongo = require("resty.mongol");
local resty_sha1 = require("resty.sha1");
local json = require("cjson");
local str = require("resty.string");

ngx.header.content_type = "application/json";

ngx.req.read_body();

local function has_key(rs, key)
      for k,v in pairs(rs)
      do
	if k == key then
	   return true
	end
      end

      return false
end
local function get_post_args()
      local args = ngx.req.get_body_data()

      if args then
          local rs = json.decode(args)

           return function (name)
		 if has_key(rs, name) then
		    return rs[name]
		 else
		    return nil
		 end	 

	   end
      else
          return function(name)
	       return nil
	  end
      end
end

local function get_query_args()
    local args = ngx.req.get_uri_args()

    if args then
        return function(name)
	    if has_key(args, name) then
	        return args[name]
	    else
	        return nil
            end
	end
    else
        return function(name)
	    return nil
	end
    end
end

local function get_header_args()
    local args = ngx.req.get_headers()

    if args then
        return function(name)
	    if has_key(args, name) then
	        return args[name]
	    else
	        return nil
	    end
	end
    else
        return function(name)
	    return nil
	end
    end
end

local post_args = get_post_args()
local query_args = get_query_args()
local header_args = get_header_args()


local function signup(name, pwd)
      local conn = mongo:new()
      err, ok = conn:connect(ngx.var.auth_db, ngx.var.auth_db_port)
      local util = require('util')

      
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
signup(post_args('user'), post_args('pwd'))
ngx.exit(201)