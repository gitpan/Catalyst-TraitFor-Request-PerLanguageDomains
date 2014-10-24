package Catalyst::TraitFor::Request::PerLanguageDomains;

use 5.008005;
use Moose::Role;
use I18N::AcceptLanguage;
use namespace::autoclean;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

requires qw/
    uri
    _context
    headers
/;

sub language {
    my $self    = shift;

    my $config  = ref($self->_context)->config->{'TraitFor::Request::PerLanguageDomains'};

    my $i18n_accept_language = I18N::AcceptLanguage->new( defaultLanguage => $config->{default_language} , debug => 1);

    my $host    = (($self->uri->host =~ m{^(\w{2})\.}) ? $1 : undef);
    my $session = $self->_context->can('session')->($self->_context)->{'language'};
    my $header  = $self->headers->header('Accept-Language');

    return $i18n_accept_language->accepts($host || $session || $header, $config->{selectable_language});
}

=pod

=head1 NAME

Catalyst::TraitFor::Request::PerLanguageDomains - Language detection for Catalyst::Requests

=head1 SYNOPSIS

    package MyApp;

    use Moose;
    use namespace::autoclean;

    use Catalyst;
    use CatalystX::RoleApplicator;

    extends 'Catalyst';

    __PACKAGE__->apply_request_class_roles(qw/
        Catalyst::TraitFor::Request::PerLanguageDomains
    /);
    
    __PACKAGE__->config( 
        'TraitFor::Request::PerLanguageDomains' => {
            default_language => 'de',
            selectable_language => ['de','en'],
        }
	};
	
    __PACKAGE__->setup;

#config general style:
<TraitFor::Request::PerLanguageDomains>
    default_language de
    selectable_language de
    selectable_language en
</Catalyst::Request>

=head1 DESCRIPTION

Extend request objects with a method for language detection

=head1 METHODS

=head2 language

    my $language = $ctx->request->language;

Returns a string that is the two digit code for the request language.

The following things are checked to find the request language, in order:

=over

=item The lang part of the domain (e.g. de from de.example.org)

=item The C<language> key set in the session (if L<Catalyst::Plugin::Session> is loaded)

=item The C<Accept-Language> header of the request.

=back

=head1 AUTHOR

  Stephan Jauernick <stephan@stejau.de>

=head1 LICENSE

This software is copyright (c) 2009 by Stephan Jauernick.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 

1;
