package Log::ger::Output::LogDispatchOutput;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use Log::ger::Util;

sub get_hooks {
    my %conf = @_;

    $conf{output} or die "Please specify output (e.g. ".
        "ArrayWithLimits for Log::Dispatch::ArrayWithLimits)";

    require Log::Dispatch;
    my $mod = "Log::Dispatch::$conf{output}";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    return {
        create_logml_routine => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_; # see Log::ger::Manual::Internals/"Arguments passed to hook"

                my $logger = sub {
                    my ($ctx, $level, $msg) = @_;

                    return if $level > $Log::ger::Current_Level;

                    # we can use init_args to store per-target stuffs
                    $hook_args{init_args}{_ld} ||= Log::Dispatch->new(
                        outputs => [
                            [
                                $conf{output},
                                min_level => 'warning',
                                %{ $conf{args} || {} },
                            ],
                        ],
                    );
                    $hook_args{init_args}{_ld}->warning($msg);
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
