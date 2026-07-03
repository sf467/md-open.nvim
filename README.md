# md-open.nvim

一个简单实用的 Neovim 插件：在 Markdown 文件中，将光标置于图片链接上时，按快捷键用**系统默认图片查看器**打开图片。

## 功能

- 支持 `![](path)` 和 `![alt text](path)` 格式
- 自动处理相对路径
- 支持 macOS / Linux / Windows

## 安装

使用 [lazy.nvim](https://github.com/folke/lazy.nvim)：

```lua
{
  "sf467/md-open.nvim",
  keys = { "<leader>io" },
  config = function()
    require("md-open").setup()
  end,
}
