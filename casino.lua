local term = require("term")
local event = require("event")
local computer = require("computer")
local io = require("io")
local gpu = require("component").gpu
math.randomseed(os.time())

local function clear()
  term.clear()
end

local function pause()
  print("Нажмите любую клавишу...")
  event.pull("key_down")
end

local function showMenu()
  clear()
  print("=== Казино ===")
  print("1. Слот-машина")
  print("2. Выход")
  io.write("Выберите игру: ")
  local choice = io.read()
  return choice
end

local function slotMachine()
  clear()
  print("=== Слот-машина ===")
  print("Нажмите любую клавишу для запуска")
  event.pull("key_down")
  local symbols = {"BAR", "7", "Cherry", "Diamond", "Lemon"}
  local res = {symbols[math.random(#symbols)], symbols[math.random(#symbols)], symbols[math.random(#symbols)]}
  print("Результат: " .. res[1] .. " | " .. res[2] .. " | " .. res[3])
  if res[1] == res[2] and res[2] == res[3] then
    print("Поздравляем, вы выиграли!")
  else
    print("Не повезло, попробуйте снова.")
  end
  pause()
end

local function main()
  while true do
    local choice = showMenu()
    if choice == "1" then
      slotMachine()
    elseif choice == "2" then
      break
    else
      print("Неверный выбор.")
      pause()
    end
  end
  clear()
  print("Спасибо за игру!")
  pause()
end

main()
