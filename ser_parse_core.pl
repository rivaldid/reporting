#!/usr/bin/env perl

use strict;
use warnings;
use feature "switch";


if ( not $ARGV[0] ){
	print "Need a Serchio Record String";
	exit 1;
}

# DEFINIZIONI REGOLARI

my $DATA = 	qr!\d{2}/\d{2}/\d{4}!;
my $ORA =	qr!\d{2}:\d{2}!;
my $PULSAR =	qr!PULSAR (?<pulsar>1|2)!;
my $CONCEN =	qr!\(000\)|\(001\)!;
my $NOME =	qr![[:alpha:][:space:]]{10}!;
my $COGNOME =	qr![[:alpha:][:space:]]{16}!;
my $VARCO =	qr!H\(\d\d\)!;
my $VERSO =	qr!USCITA|ENTRATA!;
my $TESSERA =	qr!\d{8}!;

my $PREAMBLE = qr!(?<giorno>$DATA)\s(?<ore>$ORA)\s$PULSAR\s{1,2}(?<concen>$CONCEN)!;

my $EV_TAAB = qr!(?<giorno>$DATA)\s(?<ore>$ORA)\s(?<operatore>\w{6})\s+(?<evento>Tastiera Abilitata)!;
my $EV_ALL = qr!$PREAMBLE\s+(?<evento>Allarmi Acquisiti)(?<varchi>(?:\(H\s\d\d\))|(?:\(H:\d-\d\d\)))!;
my $EV_TAMPER = qr!$PREAMBLE\s+(?<evento>Allarme Tamper)\s(?<varco>$VARCO)!;
my $EV_CSTATO = qr!$PREAMBLE\s+(?<evento>Comando Cambio Stato Lettore)\s$VARCO\sABILITATO\s\.\s\[\s(?<operatore>\w{6})\s\]!;
my $EV_CADUTA = qr!$PREAMBLE\s+(?<evento>Caduta Linea)!;
my $EV_RICPROG = qr!$PREAMBLE\s+(?<evento>Richiesta Invio Programmazione)\s\.\s\[\s(?<operatore>\w+)\s\]!;
my $EV_FINEPROG = qr!$PREAMBLE\s+(?<evento>Fine invio dati di programmazione)!;
my $EV_MINPULSAR = qr!$PREAMBLE\s+(?<evento>Linea Mini Pulsar)!;
my $EV_TESANON = qr!$PREAMBLE\s\*{8}\s(?<evento>Transito effettuato)\s\s(?<varco>$VARCO)(?<verso>$VERSO)\s(?<nominativo>.+)!;
my $EV_LINEA = qr!(?<evento>LINEA (?:ON|OFF))!;


my $EV_TRANS =	qr!$PREAMBLE\s(?<tessera>$TESSERA)\s(?<evento>Transito effettuato)\s{1,2}(?<varco>$VARCO)((?<verso>$VERSO)\s)?(?<nominativo>.+)?!;
my $EV_NCONS =	qr!$PREAMBLE\s(?<tessera>$TESSERA)\s(?<evento>Transito non consentito)\s(?<varco>$VARCO)!;

my $EV_VARNAP =	qr!$PREAMBLE\s{10}(?<evento>Varco non aperto)\s(?<varco>$VARCO)!;
my $EV_VARNCH =	qr!$PREAMBLE\s{10}(?<evento>Varco non chiuso)\s(?<varco>$VARCO)!;
my $EV_SCASSO =	qr!$PREAMBLE\s{10}(?<evento>Scasso varco)\s(?<varco>$VARCO)!;
my $EV_VARCHI =	qr!$PREAMBLE\s{10}(?<evento>Varco chiuso)\s(?<varco>$VARCO)!;

my $EV_TESSO =	qr!$PREAMBLE\s(?<tessera>$TESSERA)\s(?<evento>Tessera sospesa)\s(?<varco>$VARCO)!;
my $EV_TESOR =	qr!$PREAMBLE\s(?<tessera>$TESSERA)\s(?<evento>Tessera fuori orario)\s(?<varco>$VARCO)!;
my $EV_TESIN =	qr!$PREAMBLE\s(?<tessera>$TESSERA)\s(?<evento>Tessera inesistente)\s(?<varco>$VARCO)!;

sub neat{
	my $str = shift;
	$str =~ s/\s+$//;
	$str =~ s/\s+/ /g;
	return $str;
}

sub convdate{
	my $d = shift;
	$d =~ m!(\d{2})/(\d{2})/(\d{4})!;
	return "$3-$2-$1";
}

open UNMACHED, ">>unmatched.txt" or die("Errore open: " . $!);

my $row = $ARGV[0];


#my $PREAMBLE = qr!(?<giorno>$DATA)\s(?<ore>$ORA)\s(?<pulsar>$PULSAR)\s{12}(?<concen>$CONCEN)!;

#while IFS=$'\n' read -ra line; do
#                …
#done < $subfile


given($row){
	when( $EV_TRANS ){
		print "$+{giorno} \n$+{ore} \n$+{pulsar} \n$+{tessera} \n$+{evento} \n$+{varco} \n$+{verso} \n$+{nominativo} \n";
	}
	
	default{
		print "UNABLE TO PARSE: " . $row . "\n";
	}
}

# if($row =~ $EV_TRANS){
	#print RES "$row\n";
	#print "Cognome: ".neat(substr($+{nominativo},0,16))." - Nome: ".neat(substr($+{nominativo},16))."(Tessera $+{tessera})";
	#print " - $+{evento} alle $+{ore} il $+{giorno} ($+{pulsar} $+{varco} $+{verso})\n";
		# $sttrans->execute( (
				# $+{giorno},
				# $+{ore},
				# $+{pulsar},
				# $+{concen},
				# $+{tessera},
				# $+{evento},
				# $+{varco},
				# $+{verso},
				# neat($+{nominativo})
			# ) ) or die($sttrans->errstr);
# }elsif($row =~ $EV_NCONS ){
	#print RES "$row\n";
	#print "Tessera: $+{tessera} ore: $+{ore} - pulsar: $+{pulsar} il $+{giorno} attraverso $+{varco}\n";
		# $stncons->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{pulsar},
				# $+{concen},
				# $+{tessera},
				# $+{evento},
				# $+{varco}
			# ));
			
# }elsif($row =~ $EV_VARNAP || $row =~ $EV_VARNCH || $row =~ $EV_SCASSO || $row =~ $EV_VARCHI){
	#print RES "$row\n";
	#print "$+{evento} il $+{giorno} alle $+{ore} $+{varco}\n";
		# $stvarc->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{pulsar},
				# $+{concen},
				# $+{evento},
				# $+{varco}
			# ));
# }elsif($row =~ $EV_TESIN || $row =~ $EV_TESSO || $row =~ $EV_TESOR){
	#print RES "$row\n";
	#print "$+{evento} ($+{tessera}) il $+{giorno} alle $+{ore} $+{varco}\n";
		# $sttes->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{pulsar},
				# $+{concen},
				# $+{tessera},
				# $+{evento},
				# $+{varco}
			# ));
# }elsif( $row =~ $EV_TAAB ){
		# $sttaab->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{azione},
				# $+{utente}
			# ));
	
# }elsif( $row =~ $EV_ALL ){
	#print "$row\n";
		# $stall->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento},
				# $+{varchi}
			# ));
# }elsif( $row =~ $EV_TAMPER ){
	#print "$row\n";
		# $sttamper->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento},
				# $+{varco}
			# ));
# }elsif( $row =~ $EV_CSTATO ){
	#print "$row\n";	
		# $stcstato->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento},
				# $+{varco},
				# $+{operatore}
			# ));
# }elsif( $row =~ $EV_CADUTA ){
	#print "$row\n";	
		# $stcaduta->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento}
			# ));
# }elsif( $row =~ $EV_RICPROG ){
	#print "$row\n";	
		# $stricprog->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento},
				# $+{operatore}
			# ));
# }elsif( $row =~ $EV_FINEPROG ){
	#print "$row\n";	
		# $stfineprog->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento}
			# ));
# }elsif( $row =~ $EV_MINPULSAR ){
	#print "$row\n";	
		# $stminipulsar->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento}
			# ));
# }elsif( $row =~ $EV_TESANON ){
	#print "--- $row\n";	
		# $sttesanon->execute((
				# convdate($+{giorno}),
				# $+{ore},
				# $+{centrale},
				# $+{concentratore},
				# $+{evento},
				# $+{varco},
				# $+{verso},
				# $+{utente}
			# ));
# }elsif( $row =~ $EV_LINEA ){
	#print "$row\n";
		# $stlinea->execute((
				# $+{evento}
			# ));
# }else{
	# print UNMACHED $row,"\n";
# }
	
close UNMACHED;