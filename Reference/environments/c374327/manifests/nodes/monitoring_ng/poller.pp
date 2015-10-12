node /^poller\d+/ {
  # this has to be set before including mng_agent, inheritance won't work
  $role = 'poller'
  include 'mng_agent'
}
