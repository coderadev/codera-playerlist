Config = {}

Config.Command            = 'playerlist'
Config.OpenKey            = 'L'
Config.OpenKeyDescription = 'Open/Close Player List'

Config.TabControls = {
    online       = { control = 44, label = 'Q' },
    disconnected = { control = 38, label = 'E' },
}

Config.CloseControl = 322

Config.AreaRadius         = 100.0
Config.AreaUpdateInterval = 1000
Config.IncludeSelfInArea  = false
Config.MaxDisconnected    = 30
Config.SortBy             = 'id'
Config.ShowPing           = false

Config.UI = {
    position          = 'right',
    width             = 420,
    accentColor       = '#00e5ff',
    activeColor       = '#10e8c0',
    idColor           = '#22e04a',
    disconnectedColor = '#ff4040',
}

Config.Text = {
    title             = 'PLAYER LIST',
    subtitle          = 'ONLINE',
    totalLabel        = 'PLAYER LIST',
    areaLabel         = 'PLAYERS IN AREA',
    tabOnline         = 'ONLINE',
    tabDisconnected   = 'DISCONNECTED',
    active            = 'Active',
    id                = 'ID',
    emptyOnline       = 'No players online',
    emptyDisconnected = 'No disconnected players yet',
}
