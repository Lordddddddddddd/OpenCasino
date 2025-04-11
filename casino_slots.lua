local term = require("term")
local event = require("event")
local computer = require("computer")
local os = os
local gpu = require("component").gpu
math.randomseed(os.time())

-- Геометрия машины, барабанов и кнопки
local machineX, machineY, machineW, machineH = 5, 3, 60, 26
local reelWidth, reelHeight = 15, 7
local spinText = "КРУТИТЬ"
local spinButtonWidth = string.len(spinText)+4
local spinButtonHeight = 3
local spinButtonX = machineX + math.floor((machineW - spinButtonWidth)/2)
local spinButtonY = machineY + machineH - spinButtonHeight - 1

-- Таблица символов с ASCII‑артом и цветом
local symbols = {
  {name="Cherry", art = {
    "  _____  ",
    " /     \\ ",
    "| Cherry|",
    " \\_____/ ",
    "         "
  }, color=0xFF0000},
  {name="Lemon", art = {
    "  _____  ",
    " /     \\ ",
    "| Lemon |",
    " \\_____/ ",
    "         "
  }, color=0xFFFF00},
  {name="Bell", art = {
    "  _____  ",
    " /     \\ ",
    "|  BELL |",
    " \\_____/ ",
    "         "
  }, color=0xFFD700},
  {name="Seven", art = {
    "  _____  ",
    " |  7  | ",
    " |  7  | ",
    " |  7  | ",
    "         "
  }, color=0xFFFFFF},
  {name="BAR", art = {
    " ______  ",
    "|  BAR | ",
    "|  BAR | ",
    "|______| ",
    "         "
  }, color=0x0000FF},
  {name="Diamond", art = {
    "   /\\    ",
    "  /  \\   ",
    " |DMD |  ",
    "  \\  /   ",
    "   \\/    "
  }, color=0x00FFFF}
}

local function clearScreen() term.clear() end

local function drawMachineFrame()
  gpu.setBackground(0x000000)
  gpu.fill(machineX, machineY, machineW, machineH, " ")
  gpu.setForeground(0xFFD700)
  for x = machineX, machineX+machineW-1 do
    gpu.set(x, machineY, "-")
    gpu.set(x, machineY+machineH-1, "-")
  end
  for y = machineY, machineY+machineH-1 do
    gpu.set(machineX, y, "|")
    gpu.set(machineX+machineW-1, y, "|")
  end
  gpu.set(machineX, machineY, "+")
  gpu.set(machineX+machineW-1, machineY, "+")
  gpu.set(machineX, machineY+machineH-1, "+")
  gpu.set(machineX+machineW-1, machineY+machineH-1, "+")
end

local function drawReels(values)
  local reelStartX = machineX + 3
  local reelStartY = machineY + 3
  for i = 1, 3 do
    local cellX = reelStartX + (i - 1) * (reelWidth + 2)
    local cellY = reelStartY
    gpu.setForeground(0xFFFFFF)
    for x = cellX, cellX+reelWidth-1 do
      gpu.set(x, cellY, "-")
      gpu.set(x, cellY+reelHeight-1, "-")
    end
    for y = cellY, cellY+reelHeight-1 do
      gpu.set(cellX, y, "|")
      gpu.set(cellX+reelWidth-1, y, "|")
    end
    gpu.set(cellX, cellY, "+")
    gpu.set(cellX+reelWidth-1, cellY, "+")
    gpu.set(cellX, cellY+reelHeight-1, "+")
    gpu.set(cellX+reelWidth-1, cellY+reelHeight-1, "+")
    local symIndex = values[i]
    local symData = symbols[symIndex]
    local art = symData.art
    local vOffset = math.floor((reelHeight - #art) / 2)
    for j = 1, #art do
      local line = art[j]
      local hOffset = math.floor((reelWidth - string.len(line)) / 2)
      gpu.setForeground(symData.color)
      gpu.set(cellX + hOffset, cellY + vOffset + j, line)
    end
  end
end

local function drawSpinButton(selected)
  local bgColor = selected and 0xFFD700 or 0xAAAAAA
  gpu.setBackground(bgColor)
  for y = spinButtonY, spinButtonY+spinButtonHeight-1 do
    gpu.fill(spinButtonX, y, spinButtonWidth, 1, " ")
  end
  gpu.setForeground(0x000000)
  local textX = spinButtonX + math.floor((spinButtonWidth - string.len(spinText)) / 2)
  local textY = spinButtonY + math.floor(spinButtonHeight / 2)
  gpu.set(textX, textY, spinText)
  gpu.setBackground(0x000000)
end

local function animateReels()
  local current = {1, 1, 1}
  local spinDurations = {math.random(3,5), math.random(5,7), math.random(7,9)}
  local startTime = computer.uptime()
  local finished = {false, false, false}
  while not (finished[1] and finished[2] and finished[3]) do
    for i = 1, 3 do
      if not finished[i] then
        current[i] = math.random(#symbols)
        if computer.uptime() - startTime > spinDurations[i] then finished[i] = true end
      end
    end
    drawMachineFrame()
    drawReels(current)
    drawSpinButton(false)
    os.sleep(0.1)
  end
  return current
end

local function waitForSpinButton()
  drawMachineFrame()
  drawSpinButton(true)
  local function inButton(x, y)
    return x >= spinButtonX and x < spinButtonX + spinButtonWidth and y >= spinButtonY and y < spinButtonY + spinButtonHeight
  end
  while true do
    local _, _, tx, ty = event.pull("touch")
    if inButton(tx, ty) then break end
  end
end

local function displayResult(final)
  local resultStr = symbols[final[1]].name.." | "..symbols[final[2]].name.." | "..symbols[final[3]].name
  local win = (final[1] == final[2] and final[2] == final[3])
  local msg = win and "ПОБЕДА!" or "ПРОИГРЫШ"
  gpu.setForeground(0xFFFFFF)
  gpu.set(machineX+3, machineY+machineH-4, "Результат: "..resultStr)
  gpu.set(machineX+3, machineY+machineH-3, msg)
end

local function playSlots()
  clearScreen()
  drawMachineFrame()
  drawSpinButton(true)
  gpu.setForeground(0xFFFFFF)
  gpu.set(machineX+3, machineY-1, "Casino Slots")
  waitForSpinButton()
  local final = animateReels()
  displayResult(final)
  gpu.set(machineX+3, machineY+machineH, "Нажмите любую клавишу для повтора")
  event.pull("key_down")
end

local function main()
  while true do playSlots() end
end

main()
