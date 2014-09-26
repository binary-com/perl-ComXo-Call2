package ComXo::Call2;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use SOAP::Lite;
use IO::Socket::SSL qw( SSL_VERIFY_NONE );

sub makecall {
    my $args     = shift;
    my $USER     = $args->{user};
    my $PASS     = $args->{pass};
    my $callfrom = $args->{callfrom};
    my $callto   = $args->{callto};

    $callto   =~ s/^[+]//;
    $callfrom =~ s/^[+]//;
    die 'invalid callto'   unless $callto   =~ /^[0-9]+$/;
    die 'invalid callfrom' unless $callfrom =~ /^[0-9]+$/;

    my $soap_request = SOAP::Lite->proxy("https://www.comxo.com/webservices/buttontel.cfc")->uri("http://webservices");
    $soap_request->transport->ssl_opts(
        verify_hostname => 0,
        SSL_verify_mode => SSL_VERIFY_NONE
    );
    $soap_request->InitCall(
        SOAP::Data->type('string')->name('account')->value($USER),   SOAP::Data->type('string')->name('password')->value($PASS),
        SOAP::Data->type('string')->name('amessage')->value('0'),    SOAP::Data->type('string')->name('bmessage')->value('0'),
        SOAP::Data->type('string')->name('adigits')->value(''),      SOAP::Data->type('string')->name('bdigits')->value(''),
        SOAP::Data->type('string')->name('anumber')->value($callto), SOAP::Data->type('string')->name('bnumber')->value($callfrom),
        SOAP::Data->type('double')->name('delay')->value(0),         SOAP::Data->type('string')->name('alias')->value('FixedOdds'),
        SOAP::Data->type('string')->name('name')->value(''),         SOAP::Data->type('string')->name('company')->value(''),
        SOAP::Data->type('string')->name('postcode')->value(''),     SOAP::Data->type('string')->name('email')->value(''),
        SOAP::Data->type('string')->name('product')->value(''),      SOAP::Data->type('string')->name('url')->value(''),
        SOAP::Data->type('string')->name('extra1')->value(''),       SOAP::Data->type('string')->name('extra2')->value(''),
        SOAP::Data->type('string')->name('extra3')->value(''),       SOAP::Data->type('string')->name('extra4')->value(''),
        SOAP::Data->type('string')->name('extra5')->value(''),
    );
    my $res = $soap_request->result;
    return ($res =~ /^[0-9]+$/ ? 1 : ());
}

1;
__END__

=encoding utf-8

=head1 NAME

ComXo::Call2 - API for the ComXo Call2 service (www.call2.com)

=head1 SYNOPSIS

  use ComXo::Call2;

=head1 DESCRIPTION

ComXo::Call2 is

=head1 AUTHOR

Binary.com E<lt>fayland@binary.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Binary.com

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
