local p = "/usr/local/openresty/lualib/"
local m_package_path = package.path
package.path = string.format("%s?.lua;%s?/init.lua;%s",
	        p, p, m_package_path)

local mongo = require("resty.mongol");
local json = require("cjson");

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
      local usr = col:find_one({name=name})

      return usr["token"]
end


ngx.say(get_token_by_name(post_args("name") or query_args("name") or header_args("name"))
    == (post_args("token") or query_args("token") or header_args("token")))