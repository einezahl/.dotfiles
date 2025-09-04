local M = {}
local popup = require 'plenary.popup'
local function create_window()
  local width = 100
  local height = 40
  local borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
  local bufnr = vim.api.nvim_create_buf(false, false)
  local Chat_win_id, win = popup.create(bufnr, {
    title = 'ChatGPT',
    highlight = 'ChatWindow',
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  })
  vim.api.nvim_set_option_value('readonly', false, { buf = bufnr })
  local output = Content or 'No answers yet.'
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(output, '\n'))
  vim.api.nvim_set_option_value('readonly', true, { buf = bufnr })
  vim.api.nvim_set_option_value('modified', false, { buf = bufnr })
  return {
    bufnr = bufnr,
    win_id = Chat_win_id,
  }
end
local function close_menu()
  vim.api.nvim_win_close(Chat_win_id, true)
  Chat_win_id = nil
  Chat_bufh = nil
end
function M.toggle_quick_menu()
  if Chat_win_id ~= nil and vim.api.nvim_win_is_valid(Chat_win_id) then
    close_menu()
    return
  end
  local win_info = create_window()
  Chat_win_id = win_info.win_id
  Chat_bufh = win_info.bufnr
  vim.api.nvim_buf_set_option(Chat_bufh, 'modifiable', false)
  vim.api.nvim_buf_set_option(Chat_bufh, 'modified', false)
  vim.api.nvim_buf_set_keymap(Chat_bufh, 'n', 'q', "<Cmd>lua require('myplugin').toggle_quick_menu()<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(Chat_bufh, 'n', '<ESC>', "<Cmd>lua require('myplugin').toggle_quick_menu()<CR>", { silent = true })
end
function M.run_curl()
  local api_url = 'https://api.openai.com/v1/chat/completions'
  local model = os.getenv 'MODEL' or 'gpt-4o'
  local escaped_system_prompt = 'You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible.'
  local max_tokens = os.getenv 'MAX_TOKENS' or 512
  local temperature = os.getenv 'TEMPERATURE' or 0.7
  local openai_key = os.getenv 'OPENAI_KEY'
  local message = vim.fn.input 'Enter prompt: '
  local messages = string.format('[{"role": "system", "content": "%s"}, {"role": "user", "content": "%s"}]', escaped_system_prompt, message)
  local curl_command = string.format(
    'curl -sS -H \'Content-Type: application/json\' -H \'Authorization: Bearer %s\' -d \'{"model": "%s", "messages": %s, "max_tokens": %d, "temperature": %s}\' %s',
    openai_key,
    model,
    messages,
    max_tokens,
    temperature,
    api_url
  )
  -- print(curl_command)
  local handle = io.popen(curl_command)
  local json_response = handle:read '*a'
  handle:close()
  if json_response == '' then
    print 'Curl response is empty.'
    return
  end
  Content = json_response:match '"content"%s*:%s*"(.-)"'
  vim.fn.setreg('+', Content)
  M.toggle_quick_menu()
end
return M
