function love.conf(t)
    t.identity = "aplua-sandbox"
    t.version = "11.5"
    t.console = false

    t.window.title = "Aplua Engine"
    t.window.icon = nil
    t.window.width = 960
    t.window.height = 540
    t.window.resizable = false
    t.window.vsync = 1
    t.window.minwidth = 480
    t.window.minheight = 270

    -- Módulos LÖVE utilizados
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end