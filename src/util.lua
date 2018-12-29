local util = {}
local resty_sha1 = require("resty.sha1");
local str = require("resty.string");

function util.getsha(data)
      local sha1 = resty_sha1:new()
      sha1:update(data)
      return str.to_hex(sha1:final())
end

return util