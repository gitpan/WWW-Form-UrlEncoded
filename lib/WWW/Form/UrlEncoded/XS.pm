package WWW::Form::UrlEncoded::XS;

use strict;
use warnings;
use base qw/Exporter/;

our $VERSION = 0.01;
our @EXPORT_OK = qw/parse_urlencoded/;

use XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;

__END__

=encoding utf-8

=head1 NAME

WWW::Form::UrlEncoded::XS - XS implementation of parser for application/x-www-form-urlencoded

=head1 SYNOPSIS

    use WWW::Form::UrlEncoded::XS qw/parse_urlencoded/;

    my $query_string = "foo=bar&baz=param";
    my @params = parse_urlencoded($query_string);
    # ('foo','bar','baz','param')

=head1 DESCRIPTION

WWW::Form::UrlEncoded::XS provides application/x-www-form-urlencoded parser that is implemented by XS.
see L<WWW::Form::UrlEncoded>'s document.

=head1 LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo@gmail.comE<gt>

=cut

