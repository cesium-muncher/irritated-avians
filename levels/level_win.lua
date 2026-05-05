local birds = {"birds"}
for i=1, 100 do
    table.insert(birds, "j")
    table.insert(birds, "red")
    table.insert(birds, "yellow")
    table.insert(birds, "black")
end

return {
    birds,

    {"terrain", 400, 90-10000, 150, 25}, -- purgatory pig
    {"pig", 400, 50-10000, 25, 25},
    {"terrain", 400, 00-10000, 150, 25},
    {"terrain", 350, 50-10000, 25, 150},
    {"terrain", 450, 50-10000, 25, 150},

    {"stone", 300, 487, 100, 25},
    {"stone", 260, 425, 25, 100},
    {"stone", 340, 425, 25, 100}, -- w
    {"stone", 300, 425, 25, 100},

    {"stone", 410, 487, 100, 25}, -- i
    {"stone", 410, 362, 100, 25},
    {"stone", 410, 425, 25, 100},


    {"stone", 520, 387, 100, 25},
    {"stone", 560, 450, 25, 100}, -- n
    {"stone", 480, 450, 25, 100}, -- n

}



