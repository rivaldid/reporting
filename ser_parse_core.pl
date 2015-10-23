#!/usr/bin/env perl

use strict;
use warnings;
use feature "switch";

my $input;

#if ( not $ARGV[0] ){
#	$input = *STDIN;
#}else{
#	open ($input, "<", $ARGV[0]) or die($!);
#}

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

my $PREAMBLE = qr!(?<giorno>$DATA)\s(?<ore>$ORA)\s$PULSAR\s(?<concen>$CONCEN)!;

my $EV_TAAB = qr!(?<giorno>$DATA)\s(?<ore>$ORA)\s(?<operatore>\w{4,6})\s(?<evento>Tastiera Abilitata)\.\s\[\s(?<operatore>\w{4,6})\s\]!;
my $EV_ALL = qr!$PREAMBLE\s+(?<evento>Allarmi Acquisiti)(?<varchi>\(H\s\d\d\)|\(H:\d-\d\d\))\.\s\[\s(?<operatore>\w{4,6})\s\]!;
my $EV_TAMPER = qr!$PREAMBLE\s+(?<evento>Allarme Tamper)\s(?<varco>$VARCO)!;
my $EV_CSTATO = qr!$PREAMBLE\s+(?<evento>Comando Cambio Stato Lettore)\s$VARCO\sABILITATO\s\.\s\[\s(?<operatore>\w{6})\s\]!;
my $EV_CADUTA = qr!$PREAMBLE\s+(?<evento>Caduta Linea)!;
my $EV_RICPROG = qr!$PREAMBLE\s+(?<evento>Richiesta Invio Programmazione)\s\.\s\[\s(?<operatore>\w+)\s\]!;
my $EV_FINEPROG = qr!$PREAMBLE\s+(?<evento>Fine invio dati di programmazione)!;
my $EV_MINPULSAR = qr!$PREAMBLE\s+(?<evento>Linea Mini Pulsar)!;
my $EV_TESANON = qr!$PREAMBLE\s\*{8}\s(?<evento>Transito effettuato)\s\s(?<varco>$VARCO)(?<verso>$VERSO)\s(?<nominativo>.+)!;
my $EV_LINEA = qr!(?<evento>LINEA (?:ON|OFF))!;

my $EV_TRANS =	qr!$PREAMBLE\s(?<tessera>$TESSERA|\*{8})\s(?<evento>Transito effettuato)\s{1,2}(?<varco>$VARCO)((?<verso>$VERSO)\s)?(?<nominativo>.+)?!;
my $EV_TRDIS = qr!$PREAMBLE\s(?<tessera>$TESSERA|\*{8})\s(?<evento>Transito lettore disabilitato)\s{1,2}(?<varco>$VARCO)((?<verso>$VERSO)\s)?(?<nominativo>.+)?!;
my $EV_NCONS =	qr!$PREAMBLE\s(?<tessera>$TESSERA)\s(?<evento>Transito non consentito)\s(?<varco>$VARCO)!;

my $EV_VARNAP =	qr!$PREAMBLE\s{1,10}(?<evento>Varco non aperto)\s(?<varco>$VARCO)!;
my $EV_VARNCH =	qr!$PREAMBLE\s(?<evento>Varco non chiuso)\s(?<varco>$VARCO)!;
my $EV_SCASSO =	qr!$PREAMBLE\s(?<evento>Scasso varco)\s(?<varco>$VARCO)!;
my $EV_VARCHI =	qr!$PREAMBLE\s(?<evento>Varco chiuso)\s(?<varco>$VARCO)!;

my $EV_RIPRL =	qr!$PREAMBLE\s(?<evento>Ripristino Linea)\s(?<varco>$VARCO)!;
my $EV_ALLING = qr!$PREAMBLE\s(?<evento>Allarme ingresso 3)\s(?<varco>$VARCO)!;
my $EV_APVARC = qr!$PREAMBLE\s(?<evento>Apertura varco Console\.)\s(?<varco>$VARCO)!;
my $EV_FINETR = qr!$PREAMBLE\s\d{8}\s(?<evento>Fine transito)\s(?<varco>$VARCO)!;
my $EV_RICCAV = qr!$PREAMBLE\s+(?<evento>Richiesta Comando Apertura Varco)\s(?<varco>$VARCO)\.\s\[\s(?<nominativo>\w+)\s\]!;

my $EV_CODAP = qr!$PREAMBLE\s+(?<evento>Coda Piena\.Comando perso)!;

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

open UNMATCHED, ">ser_unmatched.log" or die("Errore open: " . $!);

sub g{
	my $value = shift;
	if( $value ){
		$value =~ s/\r//;
		return "'$value'";
	}else{
		return 'NULL';
	}
}

my ($giorno,$ore,$pulsar,$tessera,$evento,$varco,$verso,$nominativo,$operatore);

#while(my $row = <$input>){
my $row = $ARGV[0];

	if($row =~ $EV_TRANS){
		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";

	}elsif($row =~ $EV_NCONS ){
		
		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif($row =~ $EV_VARNAP || $row =~ $EV_VARNCH || $row =~ $EV_SCASSO || $row =~ $EV_VARCHI || $row =~ $EV_RIPRL
		|| $row =~ $EV_ALLING || $row =~ $EV_FINETR || $row =~ $EV_RICCAV || $row =~ $EV_APVARC || $row =~ $EV_CODAP
		|| $row =~ $EV_TRDIS
		){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif($row =~ $EV_TESIN || $row =~ $EV_TESSO || $row =~ $EV_TESOR){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_TAAB ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{operatore})}";
		
	}elsif( $row =~ $EV_ALL ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varchi})},${\g($+{verso})},${\g($+{operatore})}";
		
	}elsif( $row =~ $EV_TAMPER ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_CSTATO ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_CADUTA ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_RICPROG ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_FINEPROG ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_MINPULSAR ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_TESANON ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}elsif( $row =~ $EV_LINEA ){

		print "${\g($+{giorno})},${\g($+{ore})},${\g($+{pulsar})},${\g($+{tessera})},${\g($+{evento})},${\g($+{varco})},${\g($+{verso})},${\g($+{nominativo})}";
		
	}else{
		print UNMATCHED $row;
	}
	
#}
close UNMATCHED;