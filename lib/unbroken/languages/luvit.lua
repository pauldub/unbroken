local luvit = {
  name = 'unbroken-luvit',
  author = 'Paul d\'Hubert <paul.dhubert@yandex.ru>',
  description = 'Unbroken support for luvit.',
  -- url, license, etc.
  
  steps = {
    beforeInstall = function(remote, done)
      remote:run('apt-get install -y luajit')
      remote:run('apt-get install -y luarocks')

      done()
    end,

    install = function(remote, done)
      remote:run({
        'mkdir bin/',
        'curl http://luvit.io/dist/latest/ubuntu-latest/x86_64/luvit-bundled -o bin/luvit',
        'chmod +x bin/luvit',
        'curl https://github.com/dvv/luvit-lui/raw/master/lui --location -o bin/lui',
        'chmod +x bin/lui',
      })
      done()
    end,

    beforeScript = function(remote, done)
      remote:run('lui') 

      -- Here I would like to set remote env vars. 
      -- export PATH=$PATH:$PWD/bin
      done()
    end 
  }
}

return luvit
