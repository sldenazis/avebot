package Mate;
use strict;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	$self->_init();
	return $self;
}

sub _init {
	my $self = shift;
	$self->tomando;
}

sub tomando {
	my $self = shift;
	my $tomando;
	if (@_) {
		$self->{owner} = shift;
	} else {
		$self->{owner} = $tomando;
	}
	return $self->{owner};
}

sub cebar {
	my $self = shift;
	my $cebo_a = shift if (@_) or die;
	if ( $self->tomando() eq $cebo_a ) {
		return 1;
	} else {
		$self->tomando($cebo_a);
		return 0;
	}
}

sub devolver {
	my $self = shift;
	my $devuelve = shift if (@_) or die;
	if ( $devuelve ne $self->tomando() ) {
		return 0;
	}
	return 1;
}

sub quitar {
	my $self = shift;
	my $quitar_a = shift if (@_) or die;
	if ( $self->tomando() eq $quitar_a ) {
		$self->tomando();
		return 0;
	} else {
		return 1;
	}
}

1;
