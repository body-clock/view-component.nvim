local view_component = {}

-- Convert snake_case to CamelCase
local function to_camel_case(str)
  return (str:gsub("_(%a)", string.upper):gsub("^%a", string.upper))
end

-- Derive a Ruby class name from a component file path
-- e.g. app/components/ui/button_component.rb -> Ui::ButtonComponent
local function class_name_from_path(path)
  local rel = path:match("app/components/(.+)%.rb$")
  if not rel then
    return nil
  end

  local parts = {}
  for segment in rel:gmatch("[^/]+") do
    table.insert(parts, to_camel_case(segment))
  end
  return table.concat(parts, "::")
end

-- Generate boilerplate lines for a new .rb ViewComponent file
local function rb_boilerplate(path)
  local class_name = class_name_from_path(path)
  if not class_name then
    return {}
  end

  local segments = {}
  for segment in class_name:gmatch("[^:]+") do
    table.insert(segments, segment)
  end

  local lines = {}

  if #segments == 1 then
    table.insert(lines, "class " .. segments[1] .. " < ViewComponent::Base")
    table.insert(lines, "  def initialize")
    table.insert(lines, "  end")
    table.insert(lines, "end")
  else
    for i = 1, #segments - 1 do
      table.insert(lines, string.rep("  ", i - 1) .. "module " .. segments[i])
    end

    local indent = string.rep("  ", #segments - 1)
    table.insert(lines, indent .. "class " .. segments[#segments] .. " < ViewComponent::Base")
    table.insert(lines, indent .. "  def initialize")
    table.insert(lines, indent .. "  end")
    table.insert(lines, indent .. "end")

    for i = #segments - 1, 1, -1 do
      table.insert(lines, string.rep("  ", i - 1) .. "end")
    end
  end

  return lines
end

local function open_file(path)
  local original_modeline = vim.opt.modeline:get()
  vim.opt.modeline = false
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  vim.opt.modeline = original_modeline
end

view_component.switch = function()
  local current_path = vim.fn.expand("%:p")

  -- Guard: must be a file under app/components/
  if not current_path:match("app/components/") then
    vim.notify("Not a ViewComponent file (must be under app/components/)", vim.log.levels.WARN)
    return
  end

  -- Determine the alternate file path
  local new_file_path
  if current_path:match("%.rb$") then
    new_file_path = current_path:gsub("%.rb$", ".html.erb")
  elseif current_path:match("%.html%.erb$") then
    new_file_path = current_path:gsub("%.html%.erb$", ".rb")
  else
    vim.notify("Current file is neither a Ruby (.rb) nor ERB (.html.erb) file", vim.log.levels.WARN)
    return
  end

  -- Open if it exists, otherwise prompt to create it
  if vim.fn.filereadable(new_file_path) == 1 then
    open_file(new_file_path)
  else
    local display_path = vim.fn.fnamemodify(new_file_path, ":~:.")
    local choice = vim.fn.confirm("Create " .. display_path .. "?", "&Yes\n&No", 2)

    if choice == 1 then
      vim.fn.mkdir(vim.fn.fnamemodify(new_file_path, ":h"), "p")

      local lines = {}
      if new_file_path:match("%.rb$") then
        lines = rb_boilerplate(new_file_path)
      end

      vim.fn.writefile(lines, new_file_path)
      open_file(new_file_path)
    end
  end
end

return view_component
