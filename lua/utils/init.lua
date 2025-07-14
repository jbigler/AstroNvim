local utils = {
  "marks",
}

for _, mod in ipairs(utils) do
  local ok, err = pcall(require, "utils." .. mod)
  if not ok then vim.notify("Error loading utils module '" .. mod .. "': " .. err, vim.log.levels.ERROR) end
end
