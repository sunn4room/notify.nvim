---@class notify.Opts
---@field kind "begin" | "report" | "end"
---@field percentage integer | nil

---@class notify.Notification
---@field time string
---@field level integer
---@field message string

---@overload fun(msg: string, level: integer | nil, opts: notify.Opts | nil)
local M = setmetatable({
  ---@type notify.Notification[]
  notifications = {},
  ---@type { [string]: { [integer]: integer } }
  progresses = {},
}, {
  ---@param self { notifications: notify.Notification[], progresses: { [string]: { [integer]: integer } } }
  ---@param msg string
  ---@param level integer | nil
  ---@param opts notify.Opts | nil
  __call = function(self, msg, level, opts)
    if opts then
      if opts.kind == "begin" then
        self.progresses[msg] = self.progresses[msg] or {}
        self.progresses[msg][level or 1] = 0
      elseif opts.kind == "report" then
        self.progresses[msg][level or 1] = opts.percentage or 0
      else
        self.progresses[msg][level or 1] = nil
        if vim.tbl_isempty(self.progresses[msg]) then
          self.progresses[msg] = nil
        end
      end
    else
      self.notifications[#self.notifications + 1] = {
        time = tostring(os.date("%Y-%m-%d %H:%M:%S")),
        level = level or 2,
        message = msg,
      }
    end
    vim.cmd [[doautocmd User Notified]]
  end,
})

return M
