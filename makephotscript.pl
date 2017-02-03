#!/usr/bin/perl 

use lib "/astro/grads/arh5361/code/perl";
use MyCols;

$description="Makes an IRAF script used to run PHOT at the V-band centroids of the LAEs";
@names=("file list","aper int","aper max","aper min!0");
MyCols::PrintArgs(\@ARGV,\@names,$description,1,"makephotscript.pl");
$options=$ARGV[scalar(@ARGV)-1];
$options=MyCols::SetOpts($options,"makephotscript.pl");

$file = shift(@ARGV);
$apint = shift(@ARGV);
$apmax = shift(@ARGV);
$apmin = shift(@ARGV);

if ($apmin==0) {
  $apmin=$apint;
}

if (!defined($$options{'scalefac'})) {
  $$options{'scalefac'}=0.03;
}

$lA=ReadFile($file);
open(C,">$$options{'o'}.cl");

foreach (@$lA) {
  ($pref,$x,$y,$fluxtot,$ra,$dec,$sig)=split;
    if ($pref =~ m/_bs/) {
      ($dum1,$dum2)=split("_",$pref);
      $pref=$dum1."_".$dum2;
    } else {
      $pref2=$pref.'_bs';
    }
    if (defined($$options{'sig'})) {
      $sig=$$options{'sig'};
    }
    open(X,">$pref.coo");
    print X "$x $y\n";
    close(X);
    for ($aper=$apmin;$aper<=$apmax;$aper+=$apint) {
        $apsky=$$options{'scalefac'}*$aper;
        print C "phot $pref2 coords=$pref.coo sigma=$sig apertur=$apsky output=$pref.r$aper\n";
    }
}

MyCols::Finish();
