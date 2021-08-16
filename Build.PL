use 5.006;
use strict;
use warnings;
use Module::Build;

if ($^O ne 'linux' && $^O ne 'freebsd') {
	print "No support for OS\n";
	exit 0;
}

my $builder = Module::Build->new(
	module_name         => 'Linux::FD::Mem',
	##{ $plugin->get_prereqs ##}
	##{ $plugin->get_default('share_dir') ##}
);

$builder->create_build_script();
