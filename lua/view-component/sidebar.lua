local M = {}

local data_file = vim.fn.stdpath("data") .. "/view-component-projects.json"

local state = {
  buf = nil,
  win = nil,
  projects = nil,
}

local function load_projects()
  if vim.fn.filereadable(data_file) == 0 then
    return {}
  end
  local lines = vim.fn.readfile(data_file)
  local content = table.concat(lines, "\n")
  local ok, data = pcall(vim.fn.json_decode, content)
  if ok and type(data) == "table" then
    return data
  end
  return {}
end

local function save_projects(projects)
  vim.fn.writefile({ vim.fn.json_encode(projects) }, data_file)
end

local function get_projects()
  if not state.projects then
    state.projects = load_projects()
  end
  return state.projects
end

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end

  local projects = get_projects()
  local lines = { "  ViewComponent Projects", "  " .. string.rep("─", 26), "" }

  if #projects == 0 then
    table.insert(lines, "  No projects yet.")
    table.insert(lines, "  Press 'a' to add the current directory.")
  else
    for i, project in ipairs(projects) do
      local name = vim.fn.fnamemodify(project.path, ":t")
      table.insert(lines, string.format("  %d. %s", i, name))
      table.insert(lines, "     " .. vim.fn.fnamemodify(project.path, ":~"))
      table.insert(lines, "")
    end
  end

  table.insert(lines, "")
  table.insert(lines, "  [a]dd  [d]elete  [<CR>]cd  [q]uit")

  vim.api.nvim_set_option_value("modifiable", true, { buf = state.buf })
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })
end

-- Returns the 1-based project index for the line the cursor is on, or nil.
local function project_index_at_cursor()
  if not state.win or not vim.api.nvim_win_is_valid(state.win) then
    return nil
  end
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  -- Projects start at line 4; each entry occupies 3 lines (name, path, blank).
  if line < 4 then
    return nil
  end
  local idx = math.ceil((line - 3) / 3)
  local projects = get_projects()
  if idx < 1 or idx > #projects then
    return nil
  end
  return idx
end

local function setup_keymaps()
  local buf = state.buf
  local map = function(key, fn)
    vim.keymap.set("n", key, fn, { noremap = true, silent = true, buffer = buf })
  end

  map("q", function()
    M.close()
  end)

  map("a", function()
    M.add_project()
  end)

  map("d", function()
    local idx = project_index_at_cursor()
    if not idx then
      return
    end
    local projects = get_projects()
    local name = vim.fn.fnamemodify(projects[idx].path, ":t")
    local choice = vim.fn.confirm("Remove '" .. name .. "' from sidebar?", "&Yes\n&No", 2)
    if choice == 1 then
      table.remove(projects, idx)
      save_projects(projects)
      render()
      vim.notify("Removed: " .. name, vim.log.levels.INFO)
    end
  end)

  map("<CR>", function()
    local idx = project_index_at_cursor()
    if not idx then
      return
    end
    local path = get_projects()[idx].path
    vim.cmd("cd " .. vim.fn.fnameescape(path))
    vim.notify("Project: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
  end)
end

M.add_project = function(path)
  path = path or vim.fn.getcwd()
  path = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")

  local projects = get_projects()
  for _, p in ipairs(projects) do
    if p.path == path then
      vim.notify("Already in sidebar: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
      return
    end
  end

  table.insert(projects, { path = path })
  save_projects(projects)
  render()
  vim.notify("Added: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
end

M.open = function()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = state.buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = state.buf })
  vim.api.nvim_set_option_value("filetype", "view-component-sidebar", { buf = state.buf })

  vim.cmd("topleft vsplit")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_width(state.win, 40)

  vim.api.nvim_set_option_value("number", false, { win = state.win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = state.win })
  vim.api.nvim_set_option_value("wrap", false, { win = state.win })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = state.win })
  vim.api.nvim_set_option_value("cursorline", true, { win = state.win })

  setup_keymaps()
  render()

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = state.buf,
    once = true,
    callback = function()
      state.win = nil
      state.buf = nil
    end,
  })
end

M.close = function()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

M.toggle = function()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

return M
