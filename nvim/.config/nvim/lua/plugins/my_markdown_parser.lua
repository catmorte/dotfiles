local function printTale(tbl, indent)
  indent = indent or 0 -- Default indent level

  for k, v in pairs(tbl) do
    local spacing = string.rep("  ", indent) -- Create indentation string

    if type(v) == "table" then
      print(spacing .. tostring(k) .. " = {")
      printTale(v, indent + 1) -- Recursive call for nested tables
      print(spacing .. "}")
    else
      print(spacing .. tostring(k) .. " = " .. tostring(v))
    end
  end
end

local function isSection(s) return s:match "^## " end

local function isSubSection(s) return s:match "^### " end

local function parseText(lines, index)
  local textType = "text"
  local found = false
  local text = ""
  local i = index
  while i <= #lines do
    if isSection(lines[i]) or isSubSection(lines[i]) then break end
    if lines[i]:match "^```" then
      if not found then
        local trimmed = lines[i]:gsub("^```", ""):match "^%s*(.-)%s*$"
        if trimmed ~= "" then textType = trimmed end
        found = true
      else
        break
      end
    elseif found then
      text = text .. lines[i]
    end
    i = i + 1
  end
  return i - index, { val = text, typ = textType }
end

local function parseUntypedComponent(lines, index)
  local r = "### ([a-zA-Z0-9_]+)"
  local compName = lines[index]:match(r)
  local skip, singleVal = parseText(lines, index + 1)
  return skip, compName, { val = singleVal }
end

local function parseType(lines, index)
  local r = "## ([a-zA-Z0-9_]+)%[([a-zA-Z0-9_]+)%]"
  local name, typ = lines[index]:match(r)
  local fields = {}
  local i = index + 1
  while i <= #lines do
    if isSection(lines[i]) then break end
    if isSubSection(lines[i]) then
      local skip, name, v = parseUntypedComponent(lines, i)
      i = i + skip - 1
      print(name)
      printTale(v)

      fields[name] = v
    end
    i = i + 1
  end
  return i - index, { typ = typ, fields = fields }
end

local function parseComps(lines, index)
  local comps = {}
  local i = index + 1
  while i <= #lines do
    if isSection(lines[i]) then break end
    if isSubSection(lines[i]) then
      local skip, name, v = parseUntypedComponent(lines, i)
      i = i + skip - 1
      print(name)
      printTale(v)
      comps[name] = v
    end
    i = i + 1
  end
  return i - index, comps
end

local function parseList(lines, index)
  local vals = {}
  local i = index
  while i <= #lines do
    if isSection(lines[i]) or isSubSection(lines[i]) then break end
    if lines[i]:match "^%- " then table.insert(vals, { val = lines[i]:sub(3), typ = "text" }) end
    i = i + 1
  end
  return i - index, vals
end

local function parseVar(lines, index)
  local r = "### ([a-zA-Z0-9_]+)%[([a-zA-Z0-9_]+)%]"
  local varName, varType = lines[index]:match(r)
  local vals = {}
  local i = index + 1
  if varType == "list" then
    local skip, multipleVals = parseList(lines, i)
    vals = multipleVals
    i = i + skip
  elseif varType == "text" then
    local skip, singleVal = parseText(lines, i)
    vals = { singleVal }
    i = i + skip
  end
  return i - index, varName, { typ = varType, vals = vals }
end

local function parseVars(lines, index)
  local vars = {}
  local i = index + 1
  while i <= #lines do
    if isSection(lines[i]) then break end
    if isSubSection(lines[i]) then
      local skip, name, v = parseVar(lines, i)
      i = i + skip - 1
      print(name)
      printTale(v)
      vars[name] = v
    end
    i = i + 1
  end
  return i - index, vars
end

local function parseMarkdown(s)
  local lines = {}
  for line in s:gmatch "([^\n]*)\n?" do
    table.insert(lines, line)
  end

  local file = {
    vars = nil,
    comps = nil,
    typ = nil,
    after = nil,
  }

  local i = 1
  while i <= #lines do
    if lines[i] == "## vars" then
      local skip, vars = parseVars(lines, i)
      i = i + skip
      file.vars = vars
    elseif lines[i] == "## computed" then
      local skip, comps = parseComps(lines, i)
      i = i + skip
      file.comps = comps
    elseif lines[i] == "## after" then
      local skip, after = parseText(lines, i + 1)
      i = i + skip
      file.after = after
    elseif lines[i]:match "^## type" then
      local skip, typ = parseType(lines, i)
      i = i + skip
      file.typ = typ
    else
      i = i + 1
    end
  end

  return file
end
return { parseMarkdown = parseMarkdown }
