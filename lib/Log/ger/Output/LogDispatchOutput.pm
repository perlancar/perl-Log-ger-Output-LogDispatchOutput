package Log::ger::Output::LogDispatchOutput;

# DATE
# VERSION

use strict;
use warnings;

use Log::ger::Util;

sub get_hooks {
    my %conf = @_;

    $conf{output} or die "Please specify output (e.g. ".
        "ArrayWithLimits for Log::Dispatch::ArrayWithLimits)";

    my $mod = "Log::Dispatch::$conf{output}";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    return {
        create_log_routine => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                my $logger = sub {
                    my ($ctx, $msg) = @_;

                    # we can use init_args to store per-target stuffs
                    $args{init_args}{_ldo} ||= $mod->new(
                        min_level => Log::ger::Util::string_level(
                            $Log::ger::Current_Level),
                        %{ $conf{args} || {} },
                    );
                    $args{init_args}{_ldo}->log_message(message => $msg);
                };
                [$logger];
            }],
    };
}

1;
# ABSTRACT: Send logs to a Log::Dispatch output

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Output LogDispatchOutput => (
     output => 'Screen', # choose Log::Dispatch::Screen
     args => {stderr=>1, newline=>1},
 );


=head1 DESCRIPTION

This output sends logs to a Log::Dispatch output.


=head1 CONFIGURATION

=head2 output

=head2 args


=head1 SEE ALSO

L<Log::ger::Output::LogDispatch>

L<Log::ger>

L<Log::Dispatch>

=cut
