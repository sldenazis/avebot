use strict;
use warnings;
use feature qw/switch/;
use Irssi;
Irssi::signal_add 'message public', 'sig_message_public';

our $VERSION = '1.00';
our %IRSSI = (
    authors => 'Santiago Lopez Denazis',
    contact => 'sldenazis at gmail dot com',
    name    => 'avebot',
    description => 'bot for #avelibre on freenode',
    license => 'public domain',
);

###{{{ Config
our $MESSAGES_FILE = "messages.txt";
our @OWNERS = ('~buenavent@unaffiliated/buenaventura');
our @ADMINS = @OWNERS;
our $MATE_OWNER = "";
###}}}

###{{{ Custom messages
sub loadMessages {
    ## FIXME: el file lo toma desde el path de donde se ejecuta irssi
    my @messages_list = ();
    open (MESSAGES, $MESSAGES_FILE) or return @messages_list;
    @messages_list = <MESSAGES>;
    close (MESSAGES) or return @messages_list;
    return @messages_list;
}

our @MESSAGES = loadMessages();

sub getMessage {
    my $selected = $_[0];
    my $message = "";
    for ( my $option = 0; $option <= $#MESSAGES and $message eq ""; $option++ ) {
        if ( $MESSAGES[$option] =~ m/^$selected:[\s]*.*/i ) {
            $message = $MESSAGES[$option];
        }
    }
    $message =~ s/^[\S]*://g;
    return $message;
}

sub reloadFile {
    @MESSAGES = loadMessages();
}

sub pushMessage {
    my $message = $_[0];
    if ( $message ne "" ) {
        open(MESSAGES, ">>" . $MESSAGES_FILE);
        print MESSAGES $message . "\n";
        close(MESSAGES);
        reloadFile();
    }
}
###}}}

###{{{ Devuelve los argumentos pasados al comando si los hay
sub getArgs {
    my $arguments = $_[0];
    $arguments =~ s/^![\S]*[\s]*//g;
    ## Quito espacios en blanco del final
    $arguments =~ s/[\s]*$//g;
    return $arguments;
}
###}}}

sub shortener {
	my $url = $_[0];
	my $tin = `curl -s http://tinyurl.com/api-create.php?url=$url`;	
    return $tin;
}

sub flipcoin {
    my ($message, $server, $target) = @_;
    my $salio = "cara";
    if ( rand(2)%2 eq 0 ) {
        $salio = "seca";
    }
    $server->command("action $target tira una moneda y sale $salio");
}

sub sig_message_public {
    my $index;

    my ( $server, $msg, $nick, $nick_addr, $target ) = @_;

    given($msg) {
        when ( m/^!fortune$/i ) {
            my $f_message = `/usr/games/fortune -o`;
            $server->command("msg $target $f_message");
        }
        when ( m/^!devolver[\s]*$/i ) {
            if ( $MATE_OWNER ne $nick ) {
                $server->command("msg $target $nick, pero si no tenés el mate!");
            } else {
                $server->command("msg $target $nick, gracias!");
                $MATE_OWNER = "";
            }
        }
        when ( m/^!(quitar$|quitar[\s]+.*)/i ) {
            my $reference = getArgs($msg);
            if ( $reference eq $MATE_OWNER ) {
                $server->command("msg $target $reference, devolvé el mate, no seas void!");
                $server->command("action $target le quita el mate a $reference.");
                $MATE_OWNER = "";
            }
        }
        when ( m/^!(mate$|mate[\s]+.*$)/i ) {
            my $reference = getArgs($msg);
            if ( $reference ne "" ) {
                if ( $MATE_OWNER eq $reference ) {
                    $server->command("msg $target $nick, pero si $reference ya tiene el mate!");
                } else {
                    if ( $MATE_OWNER eq "" ) {
                        $server->command("action $target le pasa un amargo a $reference.");
                        $MATE_OWNER = $reference;
                    } elsif ( $MATE_OWNER eq $reference ) {
                        $server->command("msg $target $nick, $reference ya tiene el mate!");
                    } else {
                        $server->command("msg $target $nick, el mate lo tiene $MATE_OWNER!");
                    }
                }
            } else {
                if ( $MATE_OWNER eq $nick ) {
                    $server->command("msg $target primero devolvelo $nick!");
                } elsif ( $MATE_OWNER ne "" ) {
                    $server->command("msg $target $nick, pero si el mate lo tiene $MATE_OWNER!");
                } else {
                    $server->command("action $target le pasa un mate a $nick.");
                    $MATE_OWNER = $nick;
                }
            }
        }
        when ( m/^!(moneda|flipcoin)$/i ) {
            flipcoin($msg, $server, $target);
        }
        when ( m/^!tiny htt(p|ps):\/\/\S*$/i ) {
            $msg =~ s/!tiny //g;
            my $shortened = shortener($msg);
            $server->command("msg $target $shortened");
        }
        when ( m/^!reload$/i ) {
            if ( $nick_addr ~~ @OWNERS ) {
                reloadFile();
                $server->command("msg $target $nick, done");
            } else {
                $server->command("msg $target $nick, tomatelá guachín");
            }
        }
        when ( m/^!add[\s]+[\S^:]*/i ) {
            if ( $nick_addr ~~ @ADMINS ) {
                $msg =~ s/^!add[\s]//g;
                pushMessage($msg);
                $server->command("msg $target $nick, done");
            } else {
                $server->command("msg $target $nick, permission denied.");
            }
        }
        when ( m/^!newadmin[\s]+[\S]+@[\S]+/i ) {
            if ( $nick_addr ~~ @OWNERS ) {
                my $new_admin = $msg;
                $new_admin =~ s/^!newadmin[\s]+//g;
                push( @ADMINS, $new_admin );
                $server->command("msg $target sure, $nick");
            } else {
                $server->command("msg $target $nick, permission denied.");
            }
        }
        when ( m/^![\S]*/i ) {
            my $reference = getArgs($msg);
            # Le quito el ! y me quedo solo con la clave
            $msg =~ s/^!//g;
            $msg =~ s/[\s]+.*//g;
            my $message = getMessage($msg);
            if ( $message ne "" ) {
                if ( $reference ne "" ) {
                    $server->command("msg $target $reference: $message");
                } else {
                    $server->command("msg $target $message");
                }
            } else {
                $server->command("msg $target no sé nada de '$msg'");
            }
        }
        default {}
    }
}       

# vim: ts=4 expandtab nu:
