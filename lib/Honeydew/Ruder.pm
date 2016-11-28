package Honeydew::Ruder;

# ABSTRACT: Talk to the Ruder nodeJS service
use strict;
use warnings;
use Moo;
use Honeydew::Config;
use LWP::UserAgent;

=for markdown [![Build Status](https://travis-ci.org/gempesaw/Honeydew-Ruder.svg?branch=master)](https://travis-ci.org/gempesaw/Honeydew-Ruder)

=head1 SYNOPSIS

    my $req = Honeydew::Ruder->new('GET https://www.google.com');
    my $res = $req->execute;
    say $res;

=head1 DESCRIPTION

Use this module to interact with the Ruder NodeJS service. Instantiate
an object by passing in a multiline string of an HTTP request and
invoke L</execute> to get the result.

=cut

has request => (
    is => 'ro',
    required => 1
);

has ua => (
    is => 'lazy',
    default => sub { return LWP::UserAgent->new }
);

has config => (
    is => 'lazy',
    default => sub { return Honeydew::Config->instance }
);

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;

    return { request => $args[0] }
      if @args == 1 && !ref $args[0];

    return $class->$orig(@args);
};

sub execute {
    my ($self, %args) = @_;

    my $response = $self->ua->post(
        $self->_ruder_addr,
        data => $self->request
    );

    if ($args{debug}) {
        return $response;
    }
    else {
        return $response->content;
    }
}

sub _ruder_addr {
    my ($self) = @_;
    return $self->config->{ruder}->{server};
}

1;
