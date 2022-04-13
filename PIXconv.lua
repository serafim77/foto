local shl = require("shell")
local cmp = require("component")
local uni = require("unicode")
local fls = require("filesystem")
local gpu = cmp.gpu
local args = shl.parse(...)
local sym = {"▄", "▀", "█", " "}
local b32 = require("bit32")
local ser = require("serialization")
local SYM = {}
SYM[sym[1]] = 0
SYM[sym[2]] = 1
SYM[sym[3]] = 2
SYM[sym[4]] = 3

if not fls.exists("PIXdraw.lua") then
	shl.execute("pastebin get Bm0JUJnj PIXdraw.lua")
end

local function getMF(x, y, w, h)
  local m = {}
  local clr = {}  
  local max = {"one", "two"} 
  local f, b

  for i = x, x + w - 1 do
    m[i] = {}
    for j = y, y + h - 1 do
      _, f, b, _, _ = gpu.get(i, j)
      m[i][j] = { f, b }      
      if clr[m[i][j][1]] == nil then
        clr[m[i][j][1]] = {}
      end
      if clr[m[i][j][1]][m[i][j][2]] == nil then
        clr[m[i][j][1]][m[i][j][2]] = 0
      end
      clr[m[i][j][1]][m[i][j][2]] = clr[m[i][j][1]][m[i][j][2]] + 1
    end
  end

  clr["one"] = {}
  clr["one"]["two"] = 0
  
  for i, _ in pairs(clr) do
    for j, _ in pairs(clr[i]) do
      if clr[max[1]][max[2]] < clr[i][j] then
        max = {i, j}
      end
    end
  end

  local matrix = {}

  for i, _ in pairs(m) do
    for j, _ in pairs(m[i]) do
      if m[i][j][1] ~= max[1] or m[i][j][2] ~= max[2] then
        if matrix[j] == nil then
          matrix[j] = {}
        end
        matrix[j][i] = m[i][j]
      end
    end
  end  

  return matrix, {w, h, max[1], max[2]}
end

local function isLine(x, y)
  if y ~= nil and (x[1] == y[1] and x[2] == y[2] or x[1] == y[2] and x[2] == y[1] or y[1] == y[2] and (x[1] == y[1] or x[2] == y[1])) then
    return true
  end
  return false
end

local function getSym(x, y, s)
  if x[1] == y[1] and x[2] == y[2] then
    return sym[s[1]]
  elseif y[1] == y[2] then
    if x[1] == y[1] then
      return sym[s[1] + 2]
    elseif x[2] == y[1] then
      return sym[5 - s[1]]
    end
  else
    return sym[s[2]]
  end
end

local function getC(m)
  local clr = {}
  local f, b, s

  local ind
  local flag

  for i, _ in pairs(m) do
    for j, _ in pairs(m[i]) do
      f, b = m[i][j][1], m[i][j][2]
      if clr[b] ~= nil and clr[b][f] ~= nil then
        f, b = b, f
        s = {2, 1}
      else 
        if clr[f] == nil then
          clr[f] = {}
        end
        if clr[f][b] == nil then
          clr[f][b] = {}
        end
        s = {1, 2}
      end
      
      flag = false
      ind = #clr[f][b] + 1
      
      if isLine(m[i][j], m[i][j-1]) then
        clr[f][b][ind] = {j, i, sym[s[1]]}
        local k = j - 1

        while isLine(m[i][j], m[i][k-1]) do
          clr[f][b][ind][3] = getSym(m[i][j], m[i][k], s)..clr[f][b][ind][3]
          m[i][k] = nil
          clr[f][b][ind][1] = clr[f][b][ind][1] - 1
          k = k - 1
        end

        clr[f][b][ind][1] = clr[f][b][ind][1] - 1
        clr[f][b][ind][3] = getSym(m[i][j], m[i][k], s)..clr[f][b][ind][3]
        m[i][k] = nil
        flag = true
      end


      if isLine(m[i][j], m[i][j+1]) then
        if clr[f][b][ind] == nil then
          clr[f][b][ind] = {j, i, sym[s[1]]}
        end
        local k = j + 1
      
        while isLine(m[i][j], m[i][k+1]) do
          clr[f][b][ind][3] = clr[f][b][ind][3]..getSym(m[i][j], m[i][k], s)
          m[i][k] = nil
          k = k + 1
        end
      
        clr[f][b][ind][3] = clr[f][b][ind][3]..getSym(m[i][j], m[i][k], s)
        m[i][k] = nil
        flag = true        
      end
      if flag then
        m[i][j] = nil
  --        clr[f][b][ind] = nil
      end
    end
  end
  
  for i, _ in pairs(m) do
    for j, _ in pairs(m[i]) do
      f, b = m[i][j][1], m[i][j][2]
      if f == b  then
        if clr[f] ~= nil then
          local k, val = pairs(clr[f])
          local key, _ = k(val)
          clr[f][key][#clr[f][key] + 1] = {j, i, sym[3]}
        else
          clr[f] = {}
          clr[f][b] = {}
          clr[f][b][1] = {j, i, sym[3]}
        end
      elseif clr[b] ~= nil then 
        if clr[b][f] ~= nil then
          clr[b][f][#clr[b][f] + 1] = {j, i, sym[2]}
        elseif clr[f] ~= nil and clr[f][b] ~= nil then
          clr[f][b][#clr[f][b] + 1] = {j, i, sym[1]}
        else
          clr[b][f] = {j, i, sym[2]}
        end
      else
        if clr[f] == nil then
          clr[f] = {}
        end        
        if clr[f][b] == nil then
          clr[f][b] = {}
        end
        clr[f][b][#clr[f][b] + 1] = {j, i, sym[1]}
      end      
    end
  end  
  

  for i, _ in pairs(clr) do
    for j, _ in pairs(clr[i]) do
      if clr[i][j] == {} then
        clr[i][j] = nil
      end
    end
    if clr[i] == {} then
      clr[i] = nil
    end
  end

  return clr
end


local function codePIX(x, y, w, h)
  local matrix, f = getMF(x, y, w, h)  

  clr = getC(matrix)
  fone = f

  saveFile()
end


local function saveFile()
  local function StoB(str)
    local int = {}
    for i=1, math.ceil(uni.len(str) / 4) do
      int[i] = 0
      for j=1, 4 do
        if SYM[uni.sub(str, (i - 1) * 4 + j, (i - 1) * 4 + j)] ~= nil then
          int[i] = int[i] * 4 + SYM[(uni.sub(str, (i - 1) * 4 + j, (i - 1) * 4 + j) or "▄")]
        else
          int[i] = int[i] * 4
        end
      end
    end
    str = ""
    for i=1, #int do
      str = str..string.char(int[i])
    end
    return str
  end
  local function getn(table)
    local n = 0
    for _ in pairs(table) do n = n + 1 end
    return n
  end
  local function ItoB(integer, byte)
    local str = ""
    for i = 1, byte do
      str = string.char(integer % 256)..str
      integer = b32.rshift(integer, 8)
    end
    return str
  end

  file = io.open(path, "wb")

  --[[ FONE ]]  
  
  file:write(ItoB(fone[1], 1)..ItoB(fone[2], 1)..ItoB(fone[3], 3)..ItoB(fone[4], 3))  

  --[[ CLR ]]

  STRING = ""
  
  for i in pairs(clr) do
    for j in pairs(clr[i]) do
      for k in pairs(clr[i][j]) do
        STRING = STRING..clr[i][j][k][3]
      end
    end
  end

  file:write(ItoB(uni.len(STRING), 2))  
  file:write(StoB(STRING))
  
  file:write(ItoB(getn(clr), 2))
  for i in pairs(clr) do
    file:write(ItoB(i, 3))
    file:write(ItoB(getn(clr[i]), 2))
    for j in pairs(clr[i]) do
      file:write(ItoB(j, 3))
      file:write(ItoB(getn(clr[i][j]), 2))
      for k in pairs(clr[i][j]) do
        file:write(ItoB(clr[i][j][k][1], 1))
        file:write(ItoB(clr[i][j][k][2], 1))
        file:write(ItoB(uni.len(clr[i][j][k][3]), 1))
      end
    end
  end
  file:close()
  clr, fone = nil, nil 
end

w, h = gpu.getResolution()
path = fls.name(args[1])
if uni.len(path) > 4 and uni.sub(path, uni.len(path) - 3, uni.len(path) - 3) == "." then
  path = uni.sub(path, 1, uni.len(path) - 3)
end
path = path.."pix"
codePIX(1, 1, w, h)
shl.execute("PIXdraw.lua "..path.." 1")