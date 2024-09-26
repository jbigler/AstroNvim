return {
  {
    "jake-stewart/multicursor.nvim",
    dependencies = {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local mc = require "multicursor-nvim"
        local maps = opts.mappings
        for lhs, map in pairs {

          -- Add cursors above/below the main cursor.
          ["<up>"] = { function() mc.addCursor "k" end },
          ["<down>"] = { function() mc.addCursor "j" end },

          -- Add a cursor and jump to the cursor.
          ["<m-a>"] = { function() mc.addCursor "*" end },

          -- Jump to the next word under cursor but do not add a cursor.
          ["<m-s>"] = { function() mc.skipCursor "*" end },

          -- Rotate the main cursor.
          ["<left>"] = { mc.prevCursor },
          ["<right>"] = { mc.nextCursor },

          -- Delete the main cursor.
          ["<leader>x"] = { mc.deleteCursor },

          ["<m-q"] = {
            function()
              if mc.cursorsEnabled() then
                -- Stop other cursors from moving.
                -- This allows you to reposition the main cursor.
                mc.disableCursors()
              else
                mc.addCursor()
              end
            end,
          },
        } do
          maps.n[lhs] = map
          maps.v[lhs] = map
        end

        for lhs, map in pairs {
          -- Add and remove cursors with control + left click.
          ["<c-leftmouse>"] = { mc.handleMouse },

          ["<esc>"] = {
            function()
              if not mc.cursorsEnabled() then
                mc.enableCursors()
              elseif mc.hasCursors() then
                mc.clearCursors()
              end
            end,
          },

          -- Align cursor columns.
          ["<leader>a"] = { mc.alignCursors, desc = "Align cursors" },
        } do
          maps.n[lhs] = map
        end

        for lhs, map in pairs {
          -- Split visual selections by regex.
          ["S"] = { mc.splitCursors },

          -- Append/insert for each line of visual selections.
          ["I"] = { mc.insertVisual },
          ["A"] = { mc.appendVisual },

          -- match new cursors within visual selections by regex.
          ["M"] = { mc.matchCursors },

          -- Rotate visual selection contents.
          ["<leader>t"] = { function() mc.transposeCursors(1) end },
          ["<leader>T"] = { function() mc.transposeCursors(-1) end },
        } do
          maps.v[lhs] = map
        end
      end,
    },
    opts = {},
  },
}

-- Note yet configured
--
-- -- Customize how cursors look.
-- vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
-- vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
-- vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
-- vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
-- end,
-- }
