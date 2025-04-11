local internet = require("internet")
local file = io.open("/home/image.png", "wb")
for chunk in internet.request("https://github.com/Lordddddddddddd/OpenCasino/blob/main/image.png") do
    file:write(chunk)
end
file:close()
print("Изображение успешно загружено!")
