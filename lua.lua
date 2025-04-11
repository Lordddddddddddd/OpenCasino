local internet = require("internet")
local file = io.open("/home/image.png", "wb")
for chunk in internet.request("https://raw.githubusercontent.com/user/repo/branch/image.png") do
    file:write(chunk)
end
file:close()
print("Изображение успешно загружено!")
