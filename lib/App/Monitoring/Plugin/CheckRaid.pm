package App::Monitoring::Plugin::CheckRaid;

use Carp qw(croak);
use Module::Pluggable instantiate => 'new', sub_name => '_plugins';
use strict;

# constructor
sub new {
	my $class = shift;

	croak 'Odd number of elements in argument hash' if @_ % 2;

	my $self = {
		@_,
	};

	my $obj = bless $self, $class;

	# setup search path for Module::Pluggable
	$self->search_path(add => __PACKAGE__ . '::Plugins');

	return $obj;
}

# create list of plugins
sub plugins {
	my ($this) = @_;

	# call this once
	if (!defined $this->{plugins}) {
		my @plugins = $this->_plugins(options => $this->{options});
		$this->{plugins} = \@plugins;
	}

	wantarray ? @{$this->{plugins}} : $this->{plugins};
}

# get plugin by name
sub plugin {
	my ($this, $name) = @_;

	if (!defined $this->{plugin_names}) {
		my %names;
		foreach my $plugin ($this->plugins) {
			my $name = $plugin->{name};
			$names{$name} = $plugin;
		}
		$this->{plugin_names} = \%names;
	}

	croak "Plugin '$name' Can not be created" unless exists $this->{plugin_names}{$name};

	$this->{plugin_names}{$name};
}

# Get active plugins.
# Returns the plugin objects
sub active_plugins {
	my $this = shift;

	my @plugins = ();

	# go over all registered plugins
	foreach my $plugin ($this->plugins) {
		# skip inactive plugins (disabled or no tools available)
		next unless $plugin->active;

		push(@plugins, $plugin);
	}

	return wantarray ? @plugins : \@plugins;
}

1;