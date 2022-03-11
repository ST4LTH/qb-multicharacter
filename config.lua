Config = {}
Config.StartingApartment = true -- Enable/disable starting apartments (make sure to set default spawn coords)
Config.Interior = vector3(-191.09, -578.79, 136.0) -- Interior to load where characters are previewed
Config.DefaultSpawn = vector3(-191.09, -578.79, 136.0) -- Default spawn coords if you have start apartments disabled
Config.PedCoords = vector4(-191.6079, -571.6968, 136.0004, 190.2479) -- Create preview ped at these coordinates
Config.HiddenCoords = vector4(-191.1, -578.75, 136.0, 357.97) -- Hides your actual ped while you are in selection
Config.CamCoords = vector4(-191.3678, -573.7756, 136.5, 6.5211) -- Camera coordinates for character preview screen

Config.DefaultNumberOfCharacters = 5 -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}