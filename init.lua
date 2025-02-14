local M = {}

-- Импортируем необходимые модули
local http = require("plenary.http")
local json = require("plenary.json")

-- Функция для отправки запроса к API Qwen
function M.query_qwen(prompt)
  -- Получаем API ключ из переменной окружения или настроек Neovim
  local api_key = vim.env.QWEN_API_KEY or vim.g.qwen_api_key
  if not api_key then
    vim.notify("API key for Qwen is not set!", vim.log.levels.ERROR)
    return
  end

  -- URL для запроса к API Qwen (замените на реальный URL)
  local url = "https://api.qwen.com/v1/completions"

  -- Тело запроса
  local body = {
    model = "qwen", -- Модель Qwen
    prompt = prompt,
    max_tokens = 100,
    temperature = 0.7,
  }

  -- Отправляем POST-запрос
  local response = http.post(url, {
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. api_key,
    },
    body = json.encode(body),
  })

  -- Обрабатываем ответ
  if response.status == 200 then
    local result = json.decode(response.body)
    local text = result.choices[1].text
    vim.notify("Qwen: " .. text, vim.log.levels.INFO)
    return text
  else
    vim.notify("Error querying Qwen: " .. response.status, vim.log.levels.ERROR)
    return nil
  end
end

-- Команда для вызова из Neovim
function M.setup()
  vim.api.nvim_create_user_command("Qwen", function(opts)
    local prompt = opts.args
    if prompt == "" then
      vim.notify("Please provide a prompt for Qwen.", vim.log.levels.WARN)
      return
    end
    M.query_qwen(prompt)
  end, { nargs = "*" })
end

return M
