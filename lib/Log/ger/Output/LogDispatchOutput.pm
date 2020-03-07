package Log::ger::Output::LogDispatchOutput;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use Log::ger::Util;

sub get_hooks {
    my %plugin_conf = @_;

    $plugin_conf{output} or die "Please specify output (e.g. ".
        "ArrayWithLimits for Log::Dispatch::ArrayWithLimits)";

    require Log::Dispatch;
    my $mod = "Log::Dispatch::$plugin_conf{output}";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    return {
        create_outputter => [
            __PACKAGE__, # key
            # we want to handle all levels, thus we need to be higher priority
            # than default Log::ger hooks (10) which will install null loggers
            # for less severe levels.
            9,           # priority
            sub {        # hook
                my %hook_args = @_;

                my $outputter = sub {
                    my ($per_target_conf, $msg, $per_msg_conf) = @_;
                    my $level = $per_msg_conf->{level} // $hook_args{level};

                    return if $level > $Log::ger::Current_Level;

                    # we can use per-target conf to store per-target stuffs
                    $hook_args{per_target_conf}{_ld} ||= Log::Dispatch->new(
                        outputs => [
                            [
                                $plugin_conf{output},
                                min_level => 'warning',
                                %{ $plugin_conf{args} || {} },
                            ],
                        ],
                    );
                    $hook_args{per_target_conf}{_ld}->warning($msg);
                };
                [$outputter];
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
