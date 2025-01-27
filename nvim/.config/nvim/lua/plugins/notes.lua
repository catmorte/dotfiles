-- Define a module table to hold our functions
local M = {}

-- Function to open Telescope in a specific folder
-- @param folder: The folder path to open in Telescope
M.open_telescope_in_folder = function(folder)
  require("telescope.builtin").find_files {
    prompt_title = "Find Files in " .. folder, -- Set the prompt title to indicate the folder
    cwd = folder, -- Set the current working directory to the specified folder
  }
end

-- Function to list folders in a specific directory using Telescope
-- @param base_folder: The base directory to list folders from
M.select_folder = function(base_folder, callback)
  require("telescope.builtin").find_files {
    prompt_title = "Select Folder in " .. base_folder,
    cwd = base_folder,
    find_command = { "find", ".", "-type", "d", "-mindepth", "1", "-maxdepth", "1" }, -- Exclude the base directory itself
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local action_state = require "telescope.actions.state"
        local actions = require "telescope.actions"
        local selected = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        callback(base_folder .. "/" .. selected.value)
      end)
      return true
    end,
  }
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

-- Example usage: First select a folder in "notes/remarks" and then select a file within that folder
M.open_notes_folder = function()
  M.select_folder("~/notes/remarks", M.open_telescope_in_folder) -- Call the function to select a folder within the base path
end

M.ensure_folder_exists = function(folder) run_command("mkdir -p " .. folder) end

-- Function to create a new note in a specific folder
-- @param folder: The folder path to create the new note in
M.create_new_note = function(folder)
  vim.ui.input({ prompt = "Enter remark name: " }, function(note_name)
    if note_name then
      local current_date = os.date "%Y.%m.%d"
      local current_time = os.date "%H:%M:%S"
      local note_folder = folder .. "/" .. current_date .. "_" .. current_time .. "_" .. note_name

      -- Check if the folder exists
      M.ensure_folder_exists(note_folder)

      local note_path = note_folder .. "/note.md"
      vim.cmd("edit " .. note_path)

      -- Insert text into the new note
      local lines = {
        "# " .. note_name,
        "## " .. current_date .. " " .. current_time,
        "",
        "```text",
        "",
        "```",
      }
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
  end)
end

-- Function to select a folder and then create a new note in that folder
M.create_note_in_selected_folder = function() M.select_folder("~/notes/remarks", M.create_new_note) end

-- Create a Neovim command to open the notes folder
-- This allows the user to run :OpenNotes in Neovim to trigger the function
vim.api.nvim_create_user_command("OpenNotes", M.open_notes_folder, {})

-- Create a Neovim command to create a new note in a selected folder
-- This allows the user to run :CreateNote in Neovim to trigger the function
vim.api.nvim_create_user_command("CreateNote", M.create_note_in_selected_folder, {})

-- Return the module table to make the functions accessible
return M
