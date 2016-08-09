# Put github auth file:
  config/github.yml
<pre>
COMMON: &COMMON
  github:
    org: xxxx
    user: xxxx
    pass: "xxxx"
    proxy_host: 
    proxy_port: 
development:
  <<: *COMMON
test:
  <<: *COMMON
production:
  <<: *COMMON
</pre>
