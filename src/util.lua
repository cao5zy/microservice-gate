local util = {}
local resty_sha1 = require("resty.sha1");
local str = require("resty.string");
local json = require("cjson");

local function has_key(rs, key)
      for k,v in pairs(rs)
      do
	if k == key then
	   return true
	end
      end

      return false
end

function util.getsha(data)
      local sha1 = resty_sha1:new()
      sha1:update(data)
      return str.to_hex(sha1:final())
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

function get_arg(args, key)
     if args and has_key(args, key) then
	 return args[key]
     else
	 return nil
     end
end
function util.header_args(key)
    return get_arg(ngx.req.get_headers(), key)
end

function util.post_args(key)
      return get_arg(json.decode(ngx.req.get_body_data()), key)
end

function util.gentoken(seed)
    return util.getsha(seed .. os.date("%Y-%m-%d%H:%M:%S"))
end

function util.expdate()
    return os.time() + 6000    
end

return util