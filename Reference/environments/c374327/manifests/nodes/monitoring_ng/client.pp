node client inherits monitoring_ng_base {
  include 'mng_agent'
}

node /^client\d+/ inherits client {}
