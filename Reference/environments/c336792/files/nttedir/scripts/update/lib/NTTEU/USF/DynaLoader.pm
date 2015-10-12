package NTTEU::USF::DynaLoader;

# creates a new object from the class specified as an string
# args
#  classname as a string
#  logger, can be 0 if we don't have a logger
#  rest of the parameters (variable list)
#  the rest of the paramenters are going to be passed to the constructor.
# returns
#  0: bad
#  != 0, reference to the new object

our $VERSION='0.5';

sub create_dyn_object($$;@){
	my $class = shift;
	my $logger = shift;
	my @constr_params = @_;
	my $res = 0;

	$logger->debug("About to create instance of $class") if $logger;
	eval "use $class";
	if ($@){
		$logger->error("Error when dynamically loading the class $class: $@") if $logger;
		$res = 0;
	}else{
		$res = $class->new(@constr_params);
		$logger->debug("Instance of $class  created with result: $res") if $logger;
	}
	return $res;
}

1;
