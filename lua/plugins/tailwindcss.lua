return {
  { import = "astrocommunity.pack.html-css" },
  {
    "AstroNvim/astrocore",
    optional = true,
    opts = function(_, opts)
      -- Neovim filetype -> rustywind `--language` value. rustywind >= 0.26 uses
      -- this to treat template tags (`<%= %>`, `{{ }}`, ...) as opaque barriers
      -- so it sorts the literal classes around them without reordering code.
      local languages = {
        eruby = "erb",
        html = "html",
        htmldjango = "django",
        handlebars = "handlebars",
        liquid = "liquid",
        svelte = "svelte",
        astro = "astro",
        javascriptreact = "jsx",
        typescriptreact = "tsx",
        php = "php",
        ruby = "ruby",
      }

      -- Compiled-CSS candidates, relative to the project root. rustywind can
      -- derive its sort order from the order rules appear in your built
      -- stylesheet, which makes custom `@theme` tokens sort in their real
      -- position -- byte-identical to prettier-plugin-tailwindcss. Without it,
      -- rustywind hoists anything missing from its built-in v3-era class list
      -- to the FRONT of the attribute.
      local css_candidates = {
        "app/assets/builds/tailwind.css",
        "app/assets/builds/application.css",
        "public/assets/tailwind.css",
      }

      -- A stylesheet can be present and non-empty yet yield NO ordering at all,
      -- in which case rustywind exits 0 and echoes its input back -- which looks
      -- exactly like "nothing to sort". The known cause is minification:
      -- rustywind's CSS parser needs whitespace between selector and `{`, so
      -- `.block{...}` is invisible to it while `.block {` is fine. (`@layer`
      -- nesting is NOT a problem.) So probe the file with a pair that any sane
      -- Tailwind order reverses, and only trust it if the order actually moves.
      local probe_cache = {} ---@type table<string, { mtime: integer, ok: boolean }>

      ---@param path string
      ---@return boolean
      local function css_usable(path)
        local stat = vim.uv.fs_stat(path)
        if not stat or stat.type ~= "file" or stat.size == 0 then return false end

        -- Re-probe whenever the watcher rebuilds
        local cached = probe_cache[path]
        if cached and cached.mtime == stat.mtime.sec then return cached.ok end

        local probe = vim
          .system({
            "rustywind",
            "--stdin",
            "--custom-regex",
            "([\\s\\S]*)",
            "--output-css-file",
            path,
          }, { stdin = "p-4 flex", text = true })
          :wait()

        local ok = probe.code == 0 and vim.trim(probe.stdout or "") ~= "p-4 flex"
        probe_cache[path] = { mtime = stat.mtime.sec, ok = ok }
        if not ok then
          vim.notify(
            ("rustywind: %s yields no class order (minified?) -- using built-in order"):format(
              vim.fn.fnamemodify(path, ":~:.")
            ),
            vim.log.levels.WARN
          )
        end
        return ok
      end

      ---@return string? path to a stylesheet that actually drives the sort order
      local function tailwind_css(buf)
        if vim.fn.executable "rustywind" ~= 1 then return nil end
        local root = vim.fs.root(buf, { "Gemfile", "package.json", ".git" })
        if not root then return nil end
        for _, rel in ipairs(css_candidates) do
          local path = vim.fs.joinpath(root, rel)
          if css_usable(path) then return path end
        end
      end

      --- Sort Tailwind classes via rustywind.
      --- Heads up: rustywind always collapses a multi-line class attribute onto
      --- one line. Sort first, then break the lines by hand. Passing a range
      --- lets you sort a single new attribute without disturbing ones you have
      --- already formatted elsewhere in the file.
      ---@param line1? integer 1-indexed first line, nil for the whole buffer
      ---@param line2? integer 1-indexed last line
      local function sort_classes(line1, line2)
        if vim.fn.executable "rustywind" ~= 1 then
          return vim.notify("rustywind not on PATH -- try `:MasonInstall rustywind`", vim.log.levels.ERROR)
        end

        local buf = vim.api.nvim_get_current_buf()
        if not vim.bo[buf].modifiable then return vim.notify("Buffer is not modifiable", vim.log.levels.WARN) end

        local whole = line1 == nil
        local first = whole and 0 or line1 - 1
        local last = whole and -1 or line2
        local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
        if #lines == 0 then return end

        local cmd = { "rustywind", "--stdin" }
        local language = languages[vim.bo[buf].filetype]
        if language then
          vim.list_extend(cmd, { "--language", language })
        else
          -- Fall back to letting rustywind infer from the filename
          local name = vim.api.nvim_buf_get_name(buf)
          if name ~= "" then vim.list_extend(cmd, { "--stdin-filename", name }) end
        end
        local css = tailwind_css(buf)
        if css then vim.list_extend(cmd, { "--output-css-file", css }) end

        local result = vim.system(cmd, { stdin = table.concat(lines, "\n") .. "\n", text = true }):wait()
        if result.code ~= 0 then
          local detail = vim.trim(result.stderr or "")
          return vim.notify("rustywind failed: " .. detail, vim.log.levels.ERROR)
        end

        -- rustywind exits 0 and echoes its input when it finds no classes, so
        -- comparing before writing keeps the buffer from being marked modified.
        local sorted = vim.split(((result.stdout or ""):gsub("\n$", "")), "\n", { plain = true })
        if vim.deep_equal(lines, sorted) then return vim.notify("rustywind: nothing to sort", vim.log.levels.INFO) end

        local view = vim.fn.winsaveview()
        vim.api.nvim_buf_set_lines(buf, first, last, false, sorted)
        vim.fn.winrestview(view)
        vim.notify(("rustywind: sorted %s"):format(whole and "buffer" or ("lines %d-%d"):format(line1, line2)))
      end

      opts.commands = opts.commands or {}
      opts.commands.RustywindSort = {
        function(args)
          if args.range == 2 then
            sort_classes(args.line1, args.line2)
          else
            sort_classes()
          end
        end,
        desc = "Sort Tailwind classes with rustywind",
        range = true,
      }

      -- Dialects tried in order against a visual selection; the first one that
      -- actually changes something wins. Each safely echoes its input back when
      -- it doesn't apply (rustywind reports "no classes found" and exits 0), so
      -- letting rustywind decide beats sniffing the text with heuristics.
      local dialects = {
        {
          label = "inside quotes",
          -- Capture the body of each quoted run. Everything outside the quotes
          -- -- Ruby locals, method names, commas, newlines -- is left alone, and
          -- quoted strings that aren't classes (`"Save changes"`) are skipped
          -- individually rather than aborting the whole pass.
          regex = "[\"']([^\"']*)[\"']",
          wrapping = "no-wrapping",
        },
        {
          label = "comma-separated strings",
          regex = "([\\s\\S]*)",
          wrapping = "comma-double-quotes",
        },
        {
          label = "comma-separated strings",
          regex = "([\\s\\S]*)",
          wrapping = "comma-single-quotes",
        },
        {
          label = "bare list",
          -- Leading indent sits OUTSIDE the capture group so it survives.
          regex = "[ \\t]*([\\S][\\s\\S]*)",
          wrapping = "no-wrapping",
        },
      }

      --- Sort Tailwind classes within the visual selection.
      ---
      --- Handles, in precedence order:
      ---   class_names("block py-3 px-2", completed_classes)  -- sorts inside the quotes only
      ---   ["p-4", "flex", "text-white"]                      -- sorts across the quoted items
      ---   block py-3 px-2                                    -- selection is itself a class list
      ---
      --- Safe to trigger on anything: if nothing in the selection parses as a
      --- class list, every dialect no-ops and the buffer is left untouched.
      local function sort_selection()
        if vim.fn.executable "rustywind" ~= 1 then
          return vim.notify("rustywind not on PATH -- try `:MasonInstall rustywind`", vim.log.levels.ERROR)
        end

        local buf = vim.api.nvim_get_current_buf()
        if not vim.bo[buf].modifiable then return vim.notify("Buffer is not modifiable", vim.log.levels.WARN) end

        local from, to = vim.fn.getpos "'<", vim.fn.getpos "'>"
        local srow, scol = from[2] - 1, from[3] - 1
        local erow, ecol = to[2] - 1, to[3]
        -- linewise (V) reports a sentinel end column, so clamp to the real line
        local tail = vim.api.nvim_buf_get_lines(buf, erow, erow + 1, false)[1] or ""
        ecol = math.min(ecol, #tail)
        if srow > erow or (srow == erow and scol >= ecol) then return end

        local text = table.concat(vim.api.nvim_buf_get_text(buf, srow, scol, erow, ecol, {}), "\n")
        local css = tailwind_css(buf)

        for _, dialect in ipairs(dialects) do
          local cmd = {
            "rustywind",
            "--stdin",
            "--custom-regex",
            dialect.regex,
            "--class-wrapping",
            dialect.wrapping,
          }
          if css then vim.list_extend(cmd, { "--output-css-file", css }) end

          local result = vim.system(cmd, { stdin = text, text = true }):wait()

          if result.code ~= 0 then
            return vim.notify("rustywind failed: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
          end

          local sorted = (result.stdout or ""):gsub("\n$", "")
          if sorted ~= "" and sorted ~= text then
            -- Write back as lines: quoted mode preserves the selection's
            -- newlines and indentation, bare-list mode collapses to one line.
            vim.api.nvim_buf_set_text(buf, srow, scol, erow, ecol, vim.split(sorted, "\n", { plain = true }))
            return vim.notify("rustywind: sorted " .. dialect.label)
          end
        end

        vim.notify("rustywind: nothing to sort", vim.log.levels.INFO)
      end

      opts.commands.RustywindSortList = {
        sort_selection,
        desc = "Sort Tailwind classes within the visual selection",
      }

      opts.commands.RustywindInfo = {
        function()
          local buf = vim.api.nvim_get_current_buf()
          local lines = {}
          local exe = vim.fn.exepath "rustywind"
          lines[#lines + 1] = "rustywind: " .. (exe ~= "" and exe or "NOT FOUND on PATH")
          if exe ~= "" then
            local v = vim.system({ "rustywind", "--version" }, { text = true }):wait()
            lines[#lines + 1] = "version  : " .. vim.trim(v.stdout or "")
          end

          local root = vim.fs.root(buf, { "Gemfile", "package.json", ".git" })
          lines[#lines + 1] = "root     : " .. (root or "not detected")
          lines[#lines + 1] = "filetype : "
            .. vim.bo[buf].filetype
            .. " -> "
            .. (languages[vim.bo[buf].filetype] or "(inferred from filename)")
          lines[#lines + 1] = "stylesheet candidates:"

          if root then
            for _, rel in ipairs(css_candidates) do
              local path = vim.fs.joinpath(root, rel)
              local stat = vim.uv.fs_stat(path)
              local status
              if not stat then
                status = "missing"
              elseif stat.size == 0 then
                status = "empty"
              else
                status = css_usable(path) and "USABLE" or "present but yields no order (minified?)"
                status = ("%s, %.1f KB"):format(status, stat.size / 1024)
              end
              lines[#lines + 1] = ("  %-40s %s"):format(rel, status)
            end
          end

          local active = tailwind_css(buf)
          lines[#lines + 1] = "active   : " .. (active or "none -- using rustywind's built-in order")
          vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
        end,
        desc = "Show rustywind / Tailwind stylesheet resolution",
      }

      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}
      opts.mappings.v = opts.mappings.v or {}
      opts.mappings.n["<Leader>lw"] = { "<cmd>RustywindSort<cr>", desc = "Sort Tailwind classes (buffer)" }
      opts.mappings.v["<Leader>lw"] = { ":RustywindSort<cr>", desc = "Sort Tailwind classes (line range)" }
      opts.mappings.v["<Leader>lW"] =
        { ":<C-u>RustywindSortList<cr>", desc = "Sort Tailwind classes (within selection)" }
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "tailwindcss" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "tailwindcss-language-server", "rustywind" })
    end,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      config = {
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  -- Any `…class…` key with either separator and either quote style:
                  --   class="…"  class='…'  class=`…`  class: "…"  className={"…"}
                  --   wrapper_class: '…'  data-class="…"  :class="…"  classes: […]
                  -- Container match grabs the whole value (including array/concat
                  -- forms spanning lines), then each quoted string inside it.
                  {
                    "[\\w-]*[cC]lass(?:Name|List|es|_name|_names)?\\s*[:=]\\s*[\\[{(]?\\s*((?:[\"'`][^\"'`]*[\"'`]\\s*[,+]?\\s*)+)",
                    "[\"'`]([^\"'`]*)[\"'`]",
                  },
                  -- Ruby word arrays: %w[foo bar] / %w(foo bar)
                  "%[wW]\\[([^\\]]*)\\]",
                  "%[wW]\\(([^)]*)\\)",
                  -- Helper calls: class_names("foo", "bar"), token_list(…), cn/clsx/tw(…)
                  {
                    "\\b(?:class_names|token_list|classnames|clsx|cva|cn|cx|tw|twMerge|twJoin)\\(([^)]*)\\)",
                    "[\"'`]([^\"'`]*)[\"'`]",
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  -- Disable colorizer in favor of oklch-color-picker
  { "NvChad/nvim-colorizer.lua", optional = true, enabled = false },
}
