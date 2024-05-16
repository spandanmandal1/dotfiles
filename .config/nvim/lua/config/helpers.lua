-- show path
local function show_path()
	local current_path = vim.fn.expand("%:p")
	print("Current Path: " .. current_path)
end

-- Register the command
vim.api.nvim_create_user_command("ShowPath", show_path, { nargs = "?" })
