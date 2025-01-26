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

local function trim_last_newline(str)
  local len = string.len(str)
  if len > 0 and string.sub(str, -1) == "\n" then
    return string.sub(str, 1, len - 1)
  else
    return str
  end
end

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
      text = text .. lines[i] .. "\n"
    end
    i = i + 1
  end

  return i - index, { val = trim_last_newline(text), typ = textType }
end

local function parseUntypedComponent(lines, index)
  local r = "### ([a-zA-Z0-9_]+)"
  local compName = lines[index]:match(r)
  local skip, singleVal = parseText(lines, index + 1)
  return skip, compName, { val = singleVal }
end

local function parseType(lines, index)
  local r = "## ([a-zA-Z0-9_]+)%[([a-zA-Z0-9_]+)%]"
  local _, typ = lines[index]:match(r)
  local fields = {}
  local i = index + 1
  while i <= #lines do
    if isSection(lines[i]) then break end
    if isSubSection(lines[i]) then
      local skip, name, v = parseUntypedComponent(lines, i)
      i = i + skip - 1
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
      v.name = name
      table.insert(comps, v)
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

local M = {}

-- Utility function to get lines from the current buffer
local function get_buffer_lines() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end

-- Parse markdown from the current buffer
local function parse_buffer()
  local lines = get_buffer_lines()
  return parseMarkdown(table.concat(lines, "\n"))
end

-- Generate a selection from an array
local function select_from_array(name, array, callback)
  local choices = {}
  for i, item in ipairs(array) do
    table.insert(choices, item.val or tostring(item))
  end

  vim.ui.select(choices, { prompt = string.format("Select for '%s':", name) }, function(choice)
    if callback then callback(choice) end
  end)
end

-- Select all fields from the vars table
local function select_all_fields(vars, callback)
  local all_fields = {}
  local pending_count = 0

  local function on_complete()
    pending_count = pending_count - 1
    if pending_count == 0 then
      callback(all_fields) -- Call the final callback when all selections are done
    end
  end

  for name, var in pairs(vars) do
    if var.typ == "list" then
      pending_count = pending_count + 1
      select_from_array(name, var.vals, function(choice)
        all_fields[name] = trim_last_newline(choice)
        on_complete()
      end)
    elseif var.typ == "input" then
      -- Open an input box if the type is "input"
      vim.ui.input({ prompt = "Enter value for " .. name }, function(input) all_fields[name] = input end)
    end
  end

  -- If no selections were made, directly call the callback
  if pending_count == 0 then callback(all_fields) end
end

local function replace_patterns(text, all_fields)
  -- Function to replace {{variable name}} patterns with values from all_fields
  for variable_name, value in pairs(all_fields) do
    text = text:gsub("{{" .. variable_name .. "}}", value)
  end
  return text
end

local function run_command(command)
  -- Open a pipe to the command and get the handle
  local handle = io.popen(command .. " 2>&1") -- Capture both stdout and stderr

  if not handle then return nil, "Failed to run command" end

  -- Read the command's output
  local result = handle:read "*a"

  -- Close the handle
  handle:close()

  return result
end

local function compute(comps, all_fields)
  for _, comp in ipairs(comps) do
    if comp.val then
      local val = replace_patterns(comp.val.val, all_fields) -- Replace the patterns
      if comp.val.typ == "sh" then
        local output, err = run_command(val)
        if err then error(err) end
        all_fields[comp.name] = trim_last_newline(output)
      end
    end
  end
end

-- Function to generate and execute the curl command
function call_curl(fields, all_fields)
  -- Replace the placeholders with actual values
  local url = fields.url.val.val
  local headers = fields.headers.val.val
  local body
  if fields.body then local body = fields.body.val.val end

  local header_lines = {}
  for line in headers:gmatch "[^\n]+" do
    table.insert(header_lines, "-H '" .. line .. "'")
  end

  -- Join headers with space between them
  local headers_command = table.concat(header_lines, " ")

  -- Construct the curl command
  local method = fields.method.val.val:upper() -- Ensure method is uppercase (GET, POST, etc.)
  local curl_command = "curl -s -i -X " .. method .. " '" .. url .. "' " .. headers_command
  if body then curl_command = curl_command .. " -d '" .. body .. "'" end

  -- Print the final curl command (for debugging)
  print("Executing curl command: " .. curl_command)

  -- Return the result of the curl command
  local output, err = run_command(curl_command)
  if err then error(err) end

  output = string.gsub(output, "\r", "")

  -- Split the string only the first time \n\n appears
  local rs_headers, rs_body = output:match "([^\n]*\n\n)(.*)"
  all_fields["rs_headers"] = rs_headers
  all_fields["rs_body"] = rs_body
end

-- Command to parse the buffer
function M.parse_and_select()
  local file = parse_buffer()

  if file.vars and next(file.vars) then
    select_all_fields(file.vars, function(all_fields)
      if file.comps and next(file.comps) then compute(file.comps, all_fields) end

      for _, comp in pairs(file.typ.fields) do
        if comp.val then
          comp.val.val = replace_patterns(comp.val.val, all_fields) -- Replace the patterns
        end
      end

      if file.typ.typ == "curl" then
        call_curl(file.typ.fields, all_fields)

        if file.after then
          file.after.val = replace_patterns(file.after.val, all_fields)
          local output, err = run_command(file.after.val)
          if err then error(err) end
          print(output)
        else
          print(all_fields["rs_headers"])
          print(all_fields["rs_body"])
        end
      end
    end)
  else
    print "No variables found in the buffer."
  end
end

-- Setup function for the plugin
vim.api.nvim_create_user_command(
  "ParseMarkdown",
  M.parse_and_select,
  { desc = "Parse current buffer and select value" }
)

return M
