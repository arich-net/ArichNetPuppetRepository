(* Custom lense to parse host.allow entries /etc/host.allow
   We can replace this as soon as a lense is released within the augeas package. 
   Matthew.parry@ntt.eu
   
   14/11/11 : Rewrite to allow only name var to be added without values.
   			  This helps us when setting values with the augeas resource (tcpwrapper::service);
   			  	we can add the values in a seperate define. (tcpwrapper::addvalues)
   			  	
   example:
			hosts.allow/1
			hosts.allow/1/name = "name1"
			hosts.allow/1/value[1] = "value1"
			hosts.allow/1/value[2] = "value2"
			hosts.allow/2/name = "name2"
*)
(* Parsing /etc/hosts.allow *)
module HostsAllow =
  autoload xfm

  let sep_tab = Sep.tab
  let sep_spc = Sep.space
  let comma   = Sep.comma
  let eol     = Util.eol
  let colon = del /[ \t]*:[ \t]*/ ": "
  let space_comma = del /[, ]/ " "

  let comment = Util.comment
  let empty   = Util.empty

  (* An option label can't contain comma, comment, equals, or space *)
  let optlabel = /[^,#= \n\t]+/
  let spec    = /[^,# \n\t][^ \n\t]*/

  let comma_sep_list (l:string) =
      let lns = [ label l . store optlabel ] in
         Build.opt_list lns space_comma

  let record = [ seq "mntent" .
                   [ label "name" . store Rx.word ] . 
                    ( colon . comma_sep_list "value")?
                 . eol]

  let lns = ( comment | empty | record ) *
  let filter = (incl "/etc/hosts.allow")

  let xfm = transform lns filter

(* End: *)
