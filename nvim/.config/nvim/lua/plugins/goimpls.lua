local M = {}

-- Function to execute the `gopls implementation` command at the cursor position
M.gopls_implementation = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0) -- Get cursor position {line, col}
  local filepath = vim.api.nvim_buf_get_name(bufnr) -- Get the current file path
  local line = cursor[1] -- Current line
  local col = cursor[2] + 1 -- Current column (adjusted for 1-based indexing)

  -- Construct the `gopls` command
  local cmd = string.format("gopls implementation %s:%d:%d", filepath, line, col)

  -- Run the command and process the results
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 1 then
        -- Prepare results for Telescope
        local results = {}
        local mappings = {} -- Map clean file paths to original lines
        for _, line in ipairs(data) do
          if line ~= "" then
            local clean_path = line:match "^(.-):%d+:%d+-?%d*$" -- Extract file path
            if clean_path then
              table.insert(results, clean_path)
              mappings[clean_path] = line -- Map clean path to the full line
            end
          end
        end

        -- Pass results to Telescope
        require("telescope.pickers")
          .new({}, {
            prompt_title = "gopls Implementations",
            finder = require("telescope.finders").new_table {
              results = results,
            },
            sorter = require("telescope.config").values.generic_sorter {},
            previewer = require("telescope.previewers").new_buffer_previewer {
              define_preview = function(self, entry, status)
                local full_line = mappings[entry.value]
                if not full_line then return end

                -- Parse the full line to get the file path, line, and column
                local file_info = vim.split(full_line, ":")
                local file_path = file_info[1]
                local target_line = tonumber(file_info[2])

                -- Read the file content and set up the preview
                vim.fn.jobstart({ "cat", file_path }, {
                  stdout_buffered = true,
                  on_stdout = function(_, content)
                    vim.schedule(function()
                      if content and #content > 0 then
                        -- Set file content in the preview buffer
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)

                        -- Set syntax highlighting
                        local file_extension = vim.fn.fnamemodify(file_path, ":e")
                        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", file_extension)

                        -- Highlight the target line
                        vim.api.nvim_buf_add_highlight(
                          self.state.bufnr,
                          0,
                          "TelescopePreviewLine",
                          target_line - 1,
                          0,
                          -1
                        )

                        -- Move the cursor to the target line
                        vim.api.nvim_win_set_cursor(status.preview_win, { target_line, 0 })
                      end
                    end)
                  end,
                })
              end,
            },
            attach_mappings = function(_, map)
              map("i", "<CR>", function(prompt_bufnr)
                local entry = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                if entry and entry.value then
                  local full_line = mappings[entry.value]
                  if full_line then
                    -- Parse the full line to get the file path, line, and column
                    local file_info = vim.split(full_line, ":")
                    local file_path = file_info[1]
                    local target_line = tonumber(file_info[2])
                    local from_to = vim.split(file_info[3], "-")
                    local target_col = tonumber(from_to[1])

                    -- Open the file and move the cursor
                    vim.cmd("edit " .. file_path)
                    vim.api.nvim_win_set_cursor(0, { target_line, target_col })
                  end
                end
              end)
              return true
            end,
          })
          :find()
      else
        vim.notify("No implementations found", vim.log.levels.INFO)
      end
    end,
    on_stderr = function(_, err)
      if err then vim.notify("Error: " .. table.concat(err, "\n"), vim.log.levels.ERROR) end
    end,
  })
end

-- Create a Neovim command to run the function
vim.api.nvim_create_user_command("GoplsImplementation", M.gopls_implementation, {})

return M

-- local M = {}
--
-- -- Function to execute the `gopls implementation` command at the cursor position
-- M.gopls_implementation = function()
--   local bufnr = vim.api.nvim_get_current_buf()
--   local cursor = vim.api.nvim_win_get_cursor(0) -- Get cursor position {line, col}
--   local filepath = vim.api.nvim_buf_get_name(bufnr) -- Get the current file path
--   local line = cursor[1] -- Current line
--   local col = cursor[2] + 1 -- Current column (adjusted for 1-based indexing)
--
--   -- Construct the `gopls` command
--   local cmd = string.format("gopls implementation %s:%d:%d", filepath, line, col)
--
--   -- Run the command and process the results
--   vim.fn.jobstart(cmd, {
--     stdout_buffered = true,
--     on_stdout = function(_, data)
--       if data and #data > 1 then
--         -- Prepare results for Telescope
--         local results = {}
--         local mappings = {} -- Map clean file paths to original lines
--         for _, line in ipairs(data) do
--           if line ~= "" then
--             local clean_path = line:match "^(.-):%d+:%d+-?%d*$" -- Extract file path
--             if clean_path then
--               table.insert(results, clean_path)
--               mappings[clean_path] = line -- Map clean path to the full line
--             end
--           end
--         end
--
--         -- Pass results to Telescope
--         require("telescope.pickers")
--           .new({}, {
--             prompt_title = "gopls Implementations",
--             finder = require("telescope.finders").new_table {
--               results = results,
--             },
--             sorter = require("telescope.config").values.generic_sorter {},
--             previewer = require("telescope.previewers").new_buffer_previewer {
--               define_preview = function(self, entry, status)
--                 local full_line = mappings[entry.value]
--                 if not full_line then return end
--
--                 -- Parse the full line to get the file path, line, and column
--                 local file_info = vim.split(full_line, ":")
--                 local file_path = file_info[1]
--                 local target_line = tonumber(file_info[2])
--
--                 -- Read the file content and set up the preview
--                 vim.fn.jobstart({ "cat", file_path }, {
--                   stdout_buffered = true,
--                   on_stdout = function(_, content)
--                     vim.schedule(function()
--                       if content and #content > 0 then
--                         vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
--                         vim.api.nvim_buf_add_highlight(
--                           self.state.bufnr,
--                           0,
--                           "TelescopePreviewLine",
--                           target_line - 1,
--                           0,
--                           -1
--                         )
--                         vim.api.nvim_win_set_cursor(status.preview_win, { target_line, 0 })
--                       end
--                     end)
--                   end,
--                 })
--               end,
--             },
--             attach_mappings = function(_, map)
--               map("i", "<CR>", function(prompt_bufnr)
--                 local entry = require("telescope.actions.state").get_selected_entry()
--                 require("telescope.actions").close(prompt_bufnr)
--                 if entry and entry.value then
--                   local full_line = mappings[entry.value]
--                   if full_line then
--                     -- Parse the full line to get the file path, line, and column
--                     local file_info = vim.split(full_line, ":")
--                     local file_path = file_info[1]
--                     local target_line = tonumber(file_info[2])
--                     local target_col = tonumber(file_info[3])
--
--                     -- Open the file and move the cursor
--                     vim.cmd("edit " .. file_path)
--                     vim.api.nvim_win_set_cursor(0, { target_line, target_col - 1 })
--                   end
--                 end
--               end)
--               return true
--             end,
--           })
--           :find()
--       else
--         vim.notify("No implementations found", vim.log.levels.INFO)
--       end
--     end,
--     on_stderr = function(_, err)
--       if err then vim.notify("Error: " .. table.concat(err, "\n"), vim.log.levels.ERROR) end
--     end,
--   })
-- end
--
-- -- Create a Neovim command to run the function
-- vim.api.nvim_create_user_command("GoplsImplementation", M.gopls_implementation, {})
--
-- return M
