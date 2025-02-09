# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: let
  lua = flakes.lib.nixvim.lua;
in {
  programs.nixvim.plugins.telescope = {
    enable = true;

    luaConfig.pre = let
      leader = ",";
    in ''
      local Telescope = {
        core = require 'telescope',
        builtin = require 'telescope.builtin',
      }
      Telescope.core.load_extension('git_worktree')
      Telescope.git_worktree = Telescope.core.extensions.git_worktree.git_worktree;
      Telescope.todo = Telescope.core.extensions['todo-comments'].todo;
      function Telescope.map(mode, l, r, desc)
        desc = desc and 'Telescope: ' .. desc
        _M.map(mode, l, r, desc)
      end

      Telescope.map('n', '<C-p>', Telescope.builtin.git_files, 'git_files')
      Telescope.map('n', '<C-s>', Telescope.builtin.live_grep, 'live_grep')
      Telescope.map('n', '${leader}<C-p>', Telescope.builtin.find_files, 'find_files')
      Telescope.map('n', '${leader}<C-r>', Telescope.builtin.lsp_references, 'lsp_references')
      Telescope.map('n', '${leader}${leader}', Telescope.builtin.buffers, 'buffers')
      Telescope.map('n', '${leader}<C-s>', function ()
        local function wrap(value)
          Telescope.builtin.grep_string { search = value }
        end
        vim.ui.input({ prompt = 'Telescope grep > ' }, wrap)
      end, 'grep_string')
      Telescope.map('n', '${leader}<C-g>', Telescope.git_worktree, 'git_worktree')
      Telescope.map('n', '${leader}<C-t>', Telescope.todo, 'todo')

      function Telescope.image_preview()
        local supported_images = { "svg", "png", "jpg", "jpeg", "gif", "webp", "avif" }
        local from_entry = require("telescope.from_entry")
        local path = require("plenary.path")
        local conf = require("telescope.config").values

        local previewers = require("telescope.previewers")
        local image_api = require("image")

        local is_image_preview = false
        local image = nil
        local last_file_path = ""

        local is_supported_image = function(filepath)
          local split_path = vim.split(filepath:lower(), ".", { plain = true })
          local extension = split_path[#split_path]
          return vim.tbl_contains(supported_images, extension)
        end

        local delete_image = function()
          if not image then return end

          image:clear()
          is_image_preview = false
        end

        local create_image = function(filepath, winid, bufnr)
          filepath = filepath:gsub("\\ ", " "):gsub("\\&", "&")
          image = image_api.hijack_buffer(filepath, winid, bufnr)

          if not image then return end
          vim.schedule(function() image:render() end)
          is_image_preview = true
        end

        local function defaulter(f, default_opts)
          default_opts = default_opts or {}
          return {
            new = function(opts)
              if conf.preview == false and not opts.preview then
                return false
              end
              opts.preview = type(opts.preview) ~= "table" and {} or opts.preview
              if type(conf.preview) == "table" then
                for k, v in pairs(conf.preview) do
                  opts.preview[k] = vim.F.if_nil(opts.preview[k], v)
                end
              end
              return f(opts)
            end,
            __call = function()
              local ok, err = pcall(f(default_opts))
              if not ok then error(debug.traceback(err)) end
            end,
          }
        end

        -- NOTE: Add teardown to cat previewer to clear image when close Telescope
        local file_previewer = defaulter(function(opts)
          opts = opts or {}
          local cwd = opts.cwd or vim.fn.getcwd()
          return previewers.new_buffer_previewer({
            title = "File Preview",
            dyn_title = function(_, entry)
              return path:new(from_entry.path(entry, true)):normalize(cwd)
            end,

            get_buffer_by_name = function(_, entry)
              return from_entry.path(entry, true)
            end,

            define_preview = function(self, entry, _)
              local p = from_entry.path(entry, true)
              if p == nil or p == "" then return end

              conf.buffer_previewer_maker(p, self.state.bufnr, {
                bufname = self.state.bufname,
                winid = self.state.winid,
                preview = opts.preview,
              })
            end,

            teardown = function(_)
              if is_image_preview then delete_image() end
            end,
          })
        end, {})

        local buffer_previewer_maker = function(filepath, bufnr, opts)
          -- NOTE: Clear image when preview other file
          if is_image_preview and last_file_path ~= filepath then
            delete_image()
          end

          last_file_path = filepath

          if is_supported_image(filepath) then
            create_image(filepath, opts.winid, bufnr)
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end

        return {
          buffer_previewer_maker = buffer_previewer_maker,
          file_previewer = file_previewer.new
        }
      end

      Telescope.settings = Telescope.image_preview()
    '';

    settings.defaults = lua "Telescope.settings";
  };
}
