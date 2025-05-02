local view_component = {}

view_component.switch = function()
	-- Get current buffer file path
	local current_path = vim.fn.expand("%:p")
	local new_file_path = nil

	-- Toggle between `.rb` and `.html.erb` files
	if current_path:match("%.rb$") then
		-- Replace `.rb` extension with `.html.erb`
		new_file_path = current_path:gsub("%.rb$", ".html.erb")
	elseif current_path:match("%.html%.erb$") then
		-- Replace `.html.erb` extension with `.rb`
		new_file_path = current_path:gsub("%.html%.erb$", ".rb")
	else
		-- If neither `.rb` nor `.html.erb`, do nothing
		print("Current file is neither a Ruby (.rb) nor ERB (.html.erb) file")
		return
	end

	-- Check if the file exists
	if vim.fn.filereadable(new_file_path) == 1 then
		local original_modeline = vim.o.modeline
		vim.o.modeline = false

		-- Open the new file in the current buffer
		vim.cmd("edit " .. vim.fn.fnameescape(new_file_path))

		-- Restore the original modeline setting
		vim.o.modeline = original_modeline
	else
		print("File " .. new_file_path .. " does not exist")
	end
end

return view_component
