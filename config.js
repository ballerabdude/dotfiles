module.exports = {
  brew: [
    // http://conqueringthecommandline.com/book/ack_ag
    'ack',
    'ag',
    // Install GNU core utilities (those that come with macOS are outdated)
    // Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
    'coreutils',
    'dos2unix',
    // Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
    'findutils',
    'fortune',
    'readline', // ensure gawk gets good readline
    'gawk',
    // http://www.lcdf.org/gifsicle/ (because I'm a gif junky)
    'gifsicle',
    'gnupg',
    // Install GNU `sed`, overwriting the built-in `sed`
    // so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
    'gnu-sed --with-default-names',
    // better, more recent grep
    'homebrew/dupes/grep',
    // https://github.com/jkbrzt/httpie
    'httpie',
    // jq is a sort of JSON grep
    'jq',
    // Mac App Store CLI: https://github.com/mas-cli/mas
    'mas',
    // Install some other useful utilities like `sponge`
    'moreutils',
    'nmap',
    'openconnect',
    'reattach-to-user-namespace',
    // better/more recent version of screen
    'homebrew/dupes/screen',
    'tmux',
    'tree',
    'ttyrec',
    // better, more recent vim
    'vim --with-override-system-vi',
    'watch',
    // Install wget with IRI support
    'wget --enable-iri',
    // DB
    'postgres',
    //Ruby Version Managemnet
    'rbenv',
    'ruby-build',
    // rabbitmq server
    'rabbitmq',
    //Python version manager
    'pyenv',
    'pyenv-virtualenv',
    'yarn',
    'mediainfo',
    'packer',
    'ffmpeg --with-fdk-aac --with-ffplay --with-freetype --with-frei0r --with-libass --with-libvo-aacenc --with-libvorbis --with-libvpx --with-opencore-amr --with-openjpeg --with-opus --with-openssl --with-rtmpdump --with-schroedinger --with-speex --with-theora --with-tools --with-x265 --with-faac --with-lame --with-x264 --with-xvid',
    'md5sha1sum',
    'fdupes',
    'cmake',
    'mongodb',
    'redis',
    'mp4box'
  ],
  cask: [
    //'adium',
    //'amazon-cloud-drive',
    //'atom',
    // 'box-sync',
    //'comicbooklover',
    'diffmerge',
    'dropbox',
    //'evernote',
    'gpgtools',
    //'ireadfast',
    'iterm2',
    'little-snitch',
    'micro-snitch',
    //'macvim',
    // 'sizeup',
    //'sketchup',
    'slack',
    'the-unarchiver',
    'torbrowser',
    //'transmission',
    'vlc',
    'xquartz',
    'chefdk',
    'java',
    'java8',
    'docker',
    'spotify',
    'cyberduck',
    'postman',
    'firefox',
    'skitch',
    'jetbrains-toolbox',
    'alfred',
    'robo-3t'
  ],
  gem: [
  ],
  npm: [
    'antic',
    'buzzphrase',
    'eslint',
    'instant-markdown-d',
    // 'generator-dockerize',
    'gulp',
    'npm-check',
    'prettyjson',
    'trash',
    'vtop'
    // ,'yo'
  ]
};
