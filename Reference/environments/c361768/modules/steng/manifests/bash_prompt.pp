class steng::bash_prompt($prompt = $hostname,$order = 99){
  file{"/etc/profile.d/${order}-bash_prompt.sh":
    owner => root,
    group => root,
    mode => 0644,
    content => inline_template("PS1='<%=@prompt%>'"),
  }
}
