#!/usr/bin/perl 

use lib "/astro/grads/arh5361/code/perl";
use MyCols;

$description="Makes an IRAF script used to run PHOT at the V-band centroids of the LAEs";
@names=("file list","aper int","aper max","aper min!0");
MyCols::PrintArgs(\@ARGV,\@names,$description,1,"processphot.pl");
$options=$ARGV[scalar(@ARGV)-1];
$options=MyCols::SetOpts($options,"processphot.pl");

$file = shift(@ARGV);
$apint = shift(@ARGV);
$apmax0 = shift(@ARGV);
$apmin = shift(@ARGV);

if ($apmin==0) {
  $apmin=$apint;
}

$lA=ReadFile($file);
if (defined($$options{'inp'})) {
  $lQ=ReadFile("$$options{'inp'}");
} 
system("rm $$options{'o'}");

$k=0;
foreach (@$lA) {
  ($pref,$dum,$dum,$fluxtot,$ra,$dec)=split;
    $pref=~s/\_bs//;
    $pref=~s/\.fits//;
    open(C,">$pref.apphot");
    if (defined($$options{'inp'})) {
      ($dum,$apmax)=split(" ",$$lQ[$k]);
    } else {
      $apmax=$apmax0;
    }
    $lB=ReadFile("$pref.r$apmax");
    $line=$$lB[scalar(@$lB)-1];
    $line2=$$lB[scalar(@$lB)-4];
    ($dum,$dum,$dum,$fluxmax,$magmax,$magmaxerr)=split(" ",$line);
#    print "$fluxmax\n";
    ($dum,$dum,$dx,$dy,$ex,$ey)=split(" ",$line2);
    $halfflux=$fluxmax/2;
    $check=0;
    $fluxold=0;
    for ($aper=$apmin;$aper<=$apmax0;$aper+=$apint) {
        $lB=ReadFile("$pref.r$aper");
	$line=$$lB[scalar(@$lB)-1];
        ($dum,$dum,$dum,$flux,$mag,$magerr)=split(" ",$line);
        if (!$check && $flux>$halfflux) {
          $check=1;
          $halfrad=$aper-$apint+$apint/($flux-$fluxold)*($halfflux-$fluxold);
        }
        $halfrad=0 if ($fluxmax<=0);
        $fluxold=$flux;
        print C "$aper $flux $mag $magerr\n";
#        print C "phot $pref coords=$pref.coo sigma=0.024 apertur=$apsky output=$pref.r$aper\n";
        system("rm $pref.r$aper") if (!$$options{'v'});
    }
    close(C);
#    $halfrad=0 if ($ra==0);
   if (defined($$options{'inp'})) {
    system("echo $pref $halfrad $magmax $magmaxerr $ra $dec $dx $dy $ex $ey >> $$options{'o'}");
   } else {
    system("echo $pref $halfrad $mag $magerr $ra $dec $dx $dy $ex $ey >> $$options{'o'}");
   }
#    system("interp_splint -f $pref.apphot 2 1 $halfflux | printcol 'substr(\$1,0,-7)' 2 'substr(\$1,0,0).$mag' 'substr(\$1,0,0).$magerr' >> $$options{'o'}");
#    print("interp_splint -f $pref.apphot 2 1 $halfflux | printcol 'substr(\$1,0,-7)' 2 'substr($1,0,0).$mag' 'substr($1,0,0).$magerr' >> $$options{'o'}\n");
     $k++;
}

MyCols::Finish();
