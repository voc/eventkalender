process   = ENV['PROCESS'] || 1
listen    = ENV['LISTEN']  || 8000

worker_processes process

listen listen

stdout_path '/var/log/unicorn/stdout.log'
stderr_path '/var/log/unicorn/stderr.log'
