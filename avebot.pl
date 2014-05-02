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

our $MESSAGES_FILE = "messages.txt";

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
    $message =~ s/^[\w\d]*://g;
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
    $arguments =~ s/^![\w]*[\s]*//g;
    ## Quito espacios en blanco del final
    $arguments =~ s/[\s]*$//g;
    return $arguments;
}
###}}}

###{{{ Test cartas
our @CARTAS = ({ valor => 1, numero => "Cuatro", palo => "copas" },{ valor => 1, numero => "Cuatro", palo => "oros" },{ valor => 1, numero => "Cuatro", palo => "bastos" },{
                 valor => 1, numero => "Cuatro", palo => "espadas" },{ valor => 2, numero => "Cinco", palo => "copas" },{ valor => 2, numero => "Cinco", palo => "oros" },{
                 valor => 2, numero => "Cinco", palo => "bastos" },{ valor => 2, numero => "Cinco", palo => "espadas" },{ valor => 3, numero => "Séis", palo => "copas" },{
                 valor => 3, numero => "Séis", palo => "oros" },{ valor => 3, numero => "Séis", palo => "bastos" },{ valor => 3, numero => "Séis", palo => "espadas" },{
                 valor => 4, numero => "Siete", palo => "Bastos" },{ valor => 4, numero => "Siete", palo => "copas" },{ valor => 5, numero => "Diez", palo => "copas" },{
                 valor => 5, numero => "Diez", palo => "oros" },{ valor => 5, numero => "Diez", palo => "bastos" },{ valor => 5, numero => "Diez", palo => "espadas" },{
                 valor => 6, numero => "Once", palo => "copas" },{ valor => 6, numero => "Once", palo => "oros" },{ valor => 6, numero => "Once", palo => "bastos" },{
                 valor => 6, numero => "Once", palo => "espadas" },{ valor => 7, numero => "Doce", palo => "espadas" },{ valor => 7, numero => "Doce", palo => "copas" },{
                 valor => 7, numero => "Doce", palo => "oros" },{ valor => 7, numero => "Doce", palo => "bastos" },{ valor => 8, numero => "Ancho", palo => "basto" },{
                 valor => 8, numero => "Ancho", palo => "oro" },{ valor => 9, numero => "Dos", palo => "bastos" },{ valor => 9, numero => "Dos", palo => "oros" },{
                 valor => 9, numero => "Dos", palo => "copas" },{ valor => 9, numero => "Dos", palo => "espadas" },{ valor => 10, numero => "Tres", palo => "espadas" },{
                 valor => 10, numero => "Tres", palo => "oros" },{ valor => 10, numero => "Tres", palo => "copas" },{ valor => 10, numero => "Tres", palo => "bastos" },{
                 valor => 11, numero => "Siete", palo => "oros" },{ valor => 12, numero => "Siete", palo => "espada" },{ valor => 13, numero => "Ancho", palo => "basto" },{
                 valor => 14, numero => "Ancho", palo => "espada"});

sub entrega {
	my $range = $#CARTAS + 1;
	my $first = int(rand($range));
	my $second = int(rand($range));
	my $third = int(rand($range));

	while ( $second eq $first ) {
		$second = int(rand($range));
	}

	while ( $third eq $second or $third eq $first ){
		$third = int(rand($range));
	}

	my $cartas = "Tenés el " . $CARTAS[$first]{numero} . " de " . $CARTAS[$first]{palo} . ", el " . $CARTAS[$second]{numero} . " de " . $CARTAS[$second]{palo} . " y el " . $CARTAS[$third]{numero} . " de " . $CARTAS[$third]{palo} . "\n";

    return $cartas;
}
###}}}

###{{{ Mate
our $MATE_OWNER = "";
###}}}

###{{{ Varias
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

our @NOTES = ({ nick => "test", messages => ["hello world", "bye world"] });

sub hasNotes {
    ## Devuelvo el index del array o -1
    my $who = $_[0];
    my $has_notes = -1;

    for ( my $index = 0; $index le $#NOTES and $who ne $NOTES[$index]{nick} and $has_notes eq 0; $index++ ) {
        $has_notes = 1 if ( $NOTES[$index]{nick} eq "$who" );
    }
    return $has_notes;
}

sub leaveNote {
    my ($nick, $who, $note) = @_;
    my $index = hasNotes($who);
    my $message = "<" . $nick . "> '" . $note . "'";

    if ( $index ge 0 ) {
        push ( $NOTES[$index]{messages}, $message );
    } else {
        my %new_message = (
            nick => $who,
            messages => [ $message ]
        );
        push ( @NOTES, %new_message );
    }
    print $NOTES[1]{messages}[0];
}
###}}}

sub sig_message_public {
    my $index;

    my ( $server, $msg, $nick, $nick_addr, $target ) = @_;

    given($msg) {
        when ( m/^!note/ ) {
            leaveNote( "kalinixta", "buenaventura", "tu vieja" );
        }
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
                $server->command("msg $target $reference, no es micrófono!");
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
        when ( m/^!cartas[\s]*[\S]*$/i ) {
            my $reference = getArgs($msg);
            my $cartas = entrega();
            if ( $reference ne "" ) {
                $server->command("msg $target $reference: $cartas");
            } else {
                $server->command("msg $target $nick: $cartas");
            }
        }
        when ( m/^!(moneda|flipcoin)$/i ) {
            flipcoin($msg, $server, $target);
        }
        when ( m/^!tiny htt(p|ps):\/\/[a-z0-9.\/]*$/i ) {
            $msg =~ s/!tiny //g;
            my $shortened = shortener($msg);
            $server->command("msg $target $shortened");
        }
        when ( m/^!reload$/i ) {
            if ( $nick_addr eq "~buenavent\@unaffiliated/buenaventura" ) {
                reloadFile();
                $server->command("msg $target $nick, done");
            }
        }
        when ( m/^!add[\s]+[\w\s]*/i ) {
            if ( $nick_addr eq "~buenavent\@unaffiliated/buenaventura" ) {
                $msg =~ s/^!add[\s]//g;
                pushMessage($msg);
                $server->command("msg $target $nick, done");
            }
        }
        when ( m/^![\w\d]*/i ) {
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
