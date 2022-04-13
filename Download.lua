local com = require('component')
local internet = com.isAvailable("internet") and com.internet or error("нет интернет карты")

local function get(url, filename)
  local file, reason = io.open(filename, "w")
  if not file then
    error(reason, 2)
  end
  io.write("Download - "..filename.." ")
  local request, reason = internet.request(url, nil, {["User-Agent"] = "OpenComputers"})
  if not request then
    error(reason, 2)
  end
  while true do
    local data, reason = request.read()
    if not data then
      request.close()
      if reason then
        error(reason, 2)
      else
        io.write(" success")
      end
      break
    end
    file:write(data)
    io.write(".")
    os.sleep(0)
  end
  io.write("\n")
  file:close()
end

os.execute("cls")
get("https://raw.githubusercontent.com/serafim77/foto/main/1.pix", "1.pix")
get("https://raw.githubusercontent.com/serafim77/foto/main/PIXdraw.lua", "PIXdraw.lua")