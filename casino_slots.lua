local term = require("term")
local event = require("event")
local computer = require("computer")
local gpu = require("component").gpu
local os = os
math.randomseed(os.time())

local symbols = {
  {s = "Cherry", f = 0xFF0000},
  {s = "Lemon", f = 0xFFFF00},
  {s = "Bell", f = 0xFFD700},
  {s = "Seven", f = 0xFFFFFF},
  {s = "BAR", f = 0x0000FF},
  {s = "Diamond", f = 0x00FFFF}
}

local machineX, machineY, machineW, machineH = 10, 5, 40, 12

local function clearScreen()
  term.clear()
end

local function drawMachineFrame()
  gpu.setBackground(0x000000)
  gpu.fill(machineX, machineY, machineW, machineH, " ")
  gpu.setForeground(0xFFD700)
  for x = machineX, machineX + machineW - 1 do
    gpu.set(x, machineY, "-")
    gpu.set(x, machineY + machineH - 1, "-")
  end
  for y = machineY, machineY + machineH - 1 do
    gpu.set(machineX, y, "|")
    gpu.set(machineX + machineW - 1, y, "|")
  end
  gpu.set(machineX, machineY, "+")
  gpu.set(machineX + machineW - 1, machineY, "+")
  gpu.set(machineX, machineY + machineH - 1, "+")
  gpu.set(machineX + machineW - 1, machineY + machineH - 1, "+")
end

local function drawReels(values)
  local reelWidth, reelHeight = 10, 5
  local startX, startY = machineX + 3, machineY + 3
  for i = 1, 3 do
    local rx = startX + (i - 1) * (reelWidth + 2)
    gpu.setForeground(0xFFFFFF)
    for x = rx, rx + reelWidth - 1 do
      gpu.set(x, startY, "-")
      gpu.set(x, startY + reelHeight - 1, "-")
    end
    for y = startY, startY + reelHeight - 1 do
      gpu.set(rx, y, "|")
      gpu.set(rx + reelWidth - 1, y, "|")
    end
    gpu.set(rx, startY, "+")
    gpu.set(rx + reelWidth - 1, startY, "+")
    gpu.set(rx, startY + reelHeight - 1, "+")
    gpu.set(rx + reelWidth - 1, startY + reelHeight - 1, "+")
    local symIndex = values[i]
    local symData = symbols[symIndex]
    local sym = symData.s
    gpu.setForeground(symData.f)
    local cx = rx + math.floor((reelWidth - string.len(sym)) / 2)
    local cy = startY + math.floor(reelHeight / 2)
    gpu.set(cx, cy, sym)
  end
end

local function animateReels()
  local current = {1, 1, 1}
  local spinTime = {math.random(3,5), math.random(5,7), math.random(7,9)}
  local startTime = computer.uptime()
  local finished = {false, false, false}
  while not (finished[1] and finished[2] and finished[3]) do
    for i = 1, 3 do
      if not finished[i] then
        current[i] = math.random(#symbols)
        if computer.uptime() - startTime > spinTime[i] then finished[i] = true end
      end
    end
    drawMachineFrame()
    drawReels(current)
    os.sleep(0.1)
  end
  return current
end

local function displayResult(final)
  local resultText = "Result: " .. symbols[final[1]].s .. " | " .. symbols[final[2]].s .. " | " .. symbols[final[3]].s
  local win = (final[1] == final[2] and final[2] == final[3])
  local message = win and "YOU WIN!" or "YOU LOSE!"
  gpu.setForeground(0xFFFFFF)
  gpu.set(machineX + 2, machineY + machineH, resultText)
  gpu.set(machineX + 2, machineY + machineH + 1, message)
end

local function playSlots()
  clearScreen()
  drawMachineFrame()
  gpu.setForeground(0xFFFFFF)
  gpu.set(machineX + 2, machineY - 1, "Casino Slots")
  local final = animateReels()
  displayResult(final)
  gpu.set(machineX + 2, machineY + machineH + 3, "Press any key to play again...")
  event.pull("key_down")
end

local function main()
  while true do
    playSlots()
  end
end

main()
