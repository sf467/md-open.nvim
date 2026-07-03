-- lua/md-open/init.lua
local M = {}

---@param path string
local function open_image(path)
  local full_path = vim.fn.expand(path)
  
  -- 处理相对路径
  if not full_path:match("^/") and not full_path:match("^[a-zA-Z]:") then
    full_path = vim.fn.expand("%:p:h") .. "/" .. full_path
  end

  if vim.fn.filereadable(full_path) == 0 then
    vim.notify("图片不存在: " .. full_path, vim.log.levels.ERROR)
    return
  end

  local opener
  if vim.fn.has("mac") == 1 then
    opener = "open"
  elseif vim.fn.has("win32") == 1 then
    opener = "start"
  else
    opener = "xdg-open"
  end

  vim.fn.jobstart({opener, full_path}, {detach = true})
  vim.notify("已打开: " .. vim.fn.fnamemodify(full_path, ":t"), vim.log.levels.INFO)
end

local function open_image_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  -- Markdown 图片匹配: ![alt](path) 或 ![](path)
  local pattern = "%!%[.-%]%((.-)%)"
  for path in line:gmatch(pattern) do
    local start_pos = line:find(vim.pesc(path), 1, true)
    if start_pos and col >= start_pos and col <= start_pos + #path then
      open_image(path)
      return
    end
  end

  vim.notify("光标位置未找到图片链接", vim.log.levels.WARN)
end

function M.setup(opts)
  opts = opts or {}
  
  local keymap = opts.keymap or "<leader>io"
  
  vim.keymap.set("n", keymap, open_image_under_cursor, {
    desc = "Open image under cursor (md-open.nvim)",
    silent = true,
  })
end

-- 默认自动 setup
M.setup()

return M
