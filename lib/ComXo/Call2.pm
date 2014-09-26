package ComXo::Call2;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use Carp;
use SOAP::Lite;
use IO::Socket::SSL qw( SSL_VERIFY_NONE );

use vars qw/$errstr/;
sub errstr { $errstr }

sub new {
    my $class = shift;
    my %args  = @_ % 2 ? %{$_[0]} : @_;

    for (qw/account password/) {
        $args{$_} || croak "Param $_ is required.";
    }

    $args{soup} = SOAP::Lite->proxy("https://www.comxo.com/webservices/buttontel.cfc")->uri("http://webservices");
    $args{soup}->transport->ssl_opts(
        verify_hostname => 0,
        SSL_verify_mode => SSL_VERIFY_NONE
    );
    SOAP::Trace->import('all') if $args{debug}; # for debug

    return bless \%args, $class;
}

sub InitCall {
    my $self = shift;
    my %args  = @_ % 2 ? %{$_[0]} : @_;

    my $anumber = $args{anumber} or croak 'anumber is required.';
    my $bnumber = $args{bnumber} or croak 'bnumber is required.';
    $anumber =~ s/^[+]//;
    $bnumber =~ s/^[+]//;
    croak 'invalid anumber' unless $anumber =~ /^[0-9]+$/;
    croak 'invalid bnumber' unless $bnumber =~ /^[0-9]+$/;

    $args{amessage} = '0' unless exists $args{amessage};
    $args{bmessage} = '0' unless exists $args{bmessage};
    $args{delay} = 0 unless exists $args{delay};

    my @args = ();
    foreach my $x ('account', 'password', 'amessage', 'bmessage', 'adigits', 'bdigits', 'anumber', 'bnumber', 'delay', 'alias', 'name', 'company', 'postcode', 'email', 'product', 'url', 'extra1', 'extra2', 'extra3', 'extra4', 'extra5') {
        $args{$x} = '' unless exists $args{$x};
        my $v = $args{$x};
        $v = $self->{$x} if not $v and exists $self->{$x}; # self for account/password
        my $type = ($x eq 'delay') ? 'double' : 'string';
        push @args, SOAP::Data->type($type)->name($x)->value($v);
    }

    my $som = $self->{soup}->InitCall(@args);
    if ($som->fault) {
        $errstr = $som->faultstring;
        return;
    }

    my %possible_err = (
        '*01' => 'Number Failed',
        '*02' => 'Alias Does Not Exist',
        '*03' => 'No Call Records',
        '*04' => 'Account details incorrect',
        '*05' => 'Not enough credit on account',
        '*06' => 'ID not recognised',
        '*07' => 'Possible Fraud Attempt',
    );
    if (exists $possible_err{$som->result}) {
        $errstr = $possible_err{$som->result};
        return;
    }

    return $som->result;
}

1;
__END__

=encoding utf-8

=head1 NAME

ComXo::Call2 - API for the ComXo Call2 service (www.call2.com)

=head1 SYNOPSIS

  use ComXo::Call2;

=head1 DESCRIPTION

ComXo::Call2 is a perl implemention for L<http://www.comxo.com/webservices/buttontel.cfm>

=head1 METHODS

=head2 new

=over 4

=item * account

required.

=item * password

required.

=item * debug

enable SOAP trace. default is off.

=back

=head2 InitCall

Initiate A Call

    my $call_id = $call2->InitCall(
        anumber  => $call_to,   # to number
        bnumber  => $call_from, # from number
        alias    => 'alias',    # optional
    ) or die $call2->errstr;

=over 4

=item * amessage

integer - ID of message to play to customer (0=no message, 15=standard message)

=item * bmessage

integer - ID of message to play to company (0=no message, 15=standard message)

=item * anumber

string, anumber - Customer Phone Number

=item * bnumber

string, bnumber - Company Phone Number

=item * delay

integer, delay - Delay in Seconds

=item * alias

string, alias - Button Alias (A preset alias or your own identifier)

=item * name

string, name - Customer's Name

=item * company

string, company - Customer's Company

=item * postcode

string, postcode - Customer's Post Code

=item * email

string, email - Customer's Email Address

=item * product

string, product - Product Interest

=item * url

string, url - URL of Button

=item * extra1

string, extra1 - Additional Information 1

=item * extra2

string, extra2 - Additional Information 2

=item * extra3

string, extra3 - Additional Information 3

=item * extra4

string, extra4 - Additional Information 4

=item * extra5

string, extra5 - Additional Information 5

=back

=head1 AUTHOR

Binary.com E<lt>fayland@binary.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Binary.com

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
