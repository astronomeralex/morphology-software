#!/usr/bin/perl 

use lib "/astro/grads/arh5361/code/perl";
use MyCols;
use Math::Trig;

$description="Runs SExtractor on the postage stamps and compiles the results into a file.";
@names=("stamp file list","radius threshold","configuration file!gems_v.sex","output file!all.sout");
$nargs=MyCols::PrintArgs(\@ARGV,\@names,$description,1,"runsex.pl");
$options=$ARGV[scalar(@ARGV)-1];
$options=MyCols::SetOpts($options,"runsex.pl");

$file=shift(@ARGV);
$radthresh=shift(@ARGV);
$cfile=shift(@ARGV);
$ofile=shift(@ARGV);

if (defined($$options{'magthresh'})) {
  $magthresh=$$options{'magthresh'}; 
} else {
  $magthresh=-100000;
}

$lA=ReadFile("$file");

open(C,">$ofile.temp");
open(E,">brightest.sout");
open(F,">closest.sout");
open(Z,">nodetect.sout");

if (!defined($$options{'imcenter'})) {
  $imcenter=40;
} else {
  $imcenter=$$options{'imcenter'};
}
$nav=0;
$i=0;
foreach (@$lA) {
  $i++;
  ($stamp)=split;
  ($pref)=split('\.',$stamp);
  if (defined($$options{'suf'})) {
    $weightim=$pref."_".$$options{'suf'}.".fits";
  } else {
    $weightim=$pref."_wt.fits";
  }
  $backim=$pref."_bs.fits";
  if ($$options{'w'}) {
  system("sex $stamp -c $cfile -catalog_name $pref.sout -weight_type none");
  } else {
  system("sex $stamp -c $cfile -weight_image $weightim -catalog_name $pref.sout");
  }
  system("mv check.fits $backim");
#  print("sex $stamp -c $cfile -weight_image $weightim -catalog_name $pref.sout\n");
  system("grep -v \"^#\" $pref.sout > temp");
  $lB=ReadFile("temp");
  $templine=$$lB[scalar(@$lB)-1];
  ($objcount)=split(" ",$templine);
  $magmin=100;
  $rmin[$pref]=200;
  $magmax[$pref]=-2000;
  if (scalar(@$lB)==0) {
#    print Z "$pref\n";
    print C "$pref dum\n";
  }
  foreach $line (@$lB) {
    chop($line);
    ($dum,$flux,$fluxerr,$mag,$dum,$x,$y)=split(" ",$line);
    $r=sqrt(($x-$imcenter)**2+($y-$imcenter)**2);
    if ($mag<$magmin) {
      $magmin=$mag;
      $linebright=$line;
    }
    if ($r<$rmin[$pref]) {
      $rmin[$pref]=$r;
      $lineclose=$line;
    }
    if ($r<$radthresh&&$mag>$magmax[$pref]) {
      $magmax[$pref]=$mag;
    }
    if (!$$options{'l'}) {
    print C "$pref $line $objcount\n";
    } else {
    print C "$pref $line $objcount\n";
    }
  }
  $nav+=scalar(@$lB);
  if (!$$options{'l'}) {
    if (scalar(@$lB)>0) {
      print E "$pref $linebright\n"; 
      print F "$pref $lineclose\n"; 
    }
  } else {
    if (scalar(@$lB)>0) {
      print E "$pref $linebright\n"; 
      print F "$pref $lineclose\n"; 
    }
  }
}
if (!$$options{'l'}) {
print C "#0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n";
} else {
print C "#0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n";
}
$nav=$nav/$i;
close(C);
close(E);
close(F);
$lQ=MyCols::ReadFile("$ofile.temp");
open(R,">$ofile");
open(S,">$ofile.centroid");
$i=1;
$check=1;
$sourcecount=1;
$numold='';
foreach (@$lQ) {
  @cols=split;
  $num=$cols[0];
  if ($num ne $numold) {
    $xav=$xav/$fluxtot if ($fluxtot!=0);
    $yav=$yav/$fluxtot if ($fluxtot!=0);
    $xav=$imcenter if ($xav<=0);
    $yav=$imcenter if ($yav<=0);
    $xav2=$xav2/$fluxtot if ($fluxtot!=0);
    $yav2=$yav2/$fluxtot if ($fluxtot!=0);
    $xav2=$imcenter if ($xav<=0);
    $yav2=$imcenter if ($yav<=0);
    open(T,">$numold.coo");
    if (defined($$options{'k'})) {
      print S "$numold $xav $yav $fluxtot $xav2 $yav2\n" if ($fluxtot>0);
    } else {
      print S "$numold $xav $yav $fluxtot $xav2 $yav2\n" if ($numold ne '');
    }
    print T "$xav $yav\n" if ($numold ne '');
    close(T);
    $xav=0;
    $yav=0;
    $xav2=0;
    $yav2=0;
    $fluxtot=0;
    $sourcecount=1;
  }
  if (!$$options{'l'}) {
    $flux=$cols[3];
    $x=$cols[7];
    $y=$cols[8];
    $x2=$cols[16];
    $y2=$cols[17];
  } else {
    $flux=$cols[2];
    $x=$cols[6];
    $y=$cols[7];
    $x2=$cols[15];
    $y2=$cols[16];
  }
  $numold=$num;
  if ($num!=$oldnum) {
    $check=1;
  }
  $radsource=sqrt(($x-$imcenter)**2+($y-$imcenter)**2);
  if ($radsource<$radthresh) {
    $xav+=$flux*$x;
    $yav+=$flux*$y;
    $xav2+=$flux*$x2;
    $yav2+=$flux*$y2;
    $fluxtot+=$flux;
  }
  if (defined($$options{'k'})) {
      if ($radsource<$radthresh && $sourcecount==1) {
        $xav=$flux*$x;
        $yav=$flux*$y;
        $xav2=$flux*$x2;
        $yav2=$flux*$y2;
        $fluxtot=$flux;
        $sourcecount++;
      } elsif ($radsource<$radthresh) {
        $xav=0;
        $yav=0;
        $fluxtot=0;
      }
  }

  $errorcode=$cols[12];
#  print "$errorcode $cols[0] $rmin[$i]\n";
  if ($rmin[$num]<$radthresh && $magmax[$num]>$magthresh && $cols[1] ne 'dum') {
    print R "$_" if (!($radsource>$radthresh && $$options{'c'}));
#    print "$magmax[$num] $magthresh\n";
  } elsif ($check) {
    print Z "$_";
#    print Z "$num $rmin[$num] $magmax[$num]\n";
    $check=0;
  }
  $oldnum=$num;
}
close(R);
close(G);
close(S);
if (defined($$options{'ma'})) {
open(X,">>minarea_test.out");
print X "$$options{'ma'} $nav\n";
}
MyCols::Finish();

