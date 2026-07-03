local M = {}

---@param path string
function M.open_file(path)
    path = vim.trim(path)

    -- 解码常见 URL 编码
    path = path:gsub("%%20", " ")

    local full_path

    -- 判断是否为绝对路径
    if path:match("^/") or path:match("^[A-Za-z]:") then
        full_path = vim.fs.normalize(path)
    else
        full_path = vim.fs.normalize(
            vim.fs.joinpath(vim.fn.expand("%:p:h"), path)
        )
    end

    if vim.fn.filereadable(full_path) == 0 then
        vim.notify("文件不存在:\n" .. full_path, vim.log.levels.ERROR)
        return
    end

    if vim.fn.has("win32") == 1 then
        vim.fn.jobstart({
            "cmd",
            "/c",
            "start",
            "",
            full_path,
        }, {
            detach = true,
        })
    elseif vim.fn.has("mac") == 1 then
        vim.fn.jobstart({
            "open",
            full_path,
        }, {
            detach = true,
        })
    else
        vim.fn.jobstart({
            "xdg-open",
            full_path,
        }, {
            detach = true,
        })
    end

    vim.notify(
        "已打开: " .. vim.fn.fnamemodify(full_path, ":t"),
        vim.log.levels.INFO
    )
end

local function open_embed_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Lua 字符串是 1-based

    local pattern = "%!%[.-%]%((.-)%)"
    local search_from = 1

    while true do
        local s, e, path = line:find(pattern, search_from)

        if not s then
            break
        end

        -- 光标位于整个 ![]() 范围内即可
        if col >= s and col <= e then
            M.open_file(path)
            return
        end

        search_from = e + 1
    end

    vim.notify("光标当前位置不是 Markdown 嵌入链接", vim.log.levels.WARN)
end

function M.setup(opts)
    opts = opts or {}

    vim.keymap.set(
        "n",
        opts.keymap or "<leader>io",
        open_embed_under_cursor,
        {
            desc = "Open embedded file under cursor",
            silent = true,
        }
    )
end

M.setup()

return M
