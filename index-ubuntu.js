const emoji = require('node-emoji')
const config = require('./config')
const command = require('./lib_node/command')

const installPackages = function(type){
    console.info(emoji.get('coffee'), ' installing '+type+' packages')
    config[type].map(function(item){
      console.info(type+':', item)
      command('. lib_sh/echos.sh && . lib_sh/requirers.sh && require_'+type+' ' + item, __dirname, function(err, out) {
        if(err) console.error(emoji.get('fire'), err)
      })
    })
  }

  installPackages('npm')
  installPackages('gem')
