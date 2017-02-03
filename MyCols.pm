#!/usr/bin/perl 

package MyCols;
use Exporter();
use Math::Trig;
@ISA=qw(Exporter);

@EXPORT=qw(ReadFile GetColNum CheckView StripHeader GetLine Finish SetOpts CheckSkip PrintHead PrintArgs LoadArrs LoadArrs2 LoadGrid GetColName ChangePrecision nint MakeFortString Conv2Fort);

sub CheckView 
{
  my $arg1 = shift(@_);
  my $arg2 = shift(@_);
  my $argv = shift(@_);
  if ($arg1 eq "-" && $arg2 == 0) {
    shift(@$argv);
    shift(@$argv);
    $gview=0;
  } else {
    $gview=1;
  }
  return $gview;
}

sub StripHeader 
{
  my $lines = shift(@_);
  if (@$lines[0] =~ m/^#/) {
    shift(@$lines);
  } 
  if (@$lines[0] =~ m/^#/) {
    shift(@$lines);
  }
}
sub GetColNum
{
  my $header = shift(@_);
  my $colname = shift(@_);
  my @heads=split(" ",$header);
  $i=0;
  if ($heads[0] eq '#') {
    foreach (@heads) {
      if ($colname eq $_) {
        return $i;
      } 
      $i++;
    }
  }
  if ($colname =~ m/\D/ ){
    print "$colname is invalid column\n";
    die;
  }
  if ($colname < 1 ){
    print "$colname is invalid column\n";
    die;
  }
#  if (scalar(@heads)-1 < $colname) {
#    print "There are less than $colname columns\n";
#    die;
#  }
  return $colname;
}

sub GetColFull
{
  my $header = shift(@_);
  my $colname = shift(@_);
  my $letter = shift(@_);
  my @heads=split(" ",$header);
  $i=0;
 
  if ($colname =~ m/\$([0-9]+)/) {
    $string=$colname;
    $string="set $letter=$string\n";
    while($string =~ m/\$([0-9]+)/) {
      $string =~ s/\$([0-9]+)/c$+/;
      $string = "read c$+ $+\n".$string;
    }
  } else {
    $colnum=GetColNum($header,$colname);
    $string="read $letter $colnum\n";
  }

  return $string;

}

sub GetColEval
{
  my $header = shift(@_);
  my $colname = shift(@_);
  my @heads=split(" ",$header);
  $i=0;
 
  if ($colname =~ m/\$([c0-9]+)/) {
    $colname =~ s/\$([0-9]+)/\(\$cols\[$+-1\]\)/g;
  } else {
    $colnum=GetColNum($header,$colname);
    $colname = "\$cols[$colnum-1]";
  }

  return $colname;

}

sub GetColName
{
  my ($colname);
  my $header = shift(@_);
  my $colnum = shift(@_);
  my @heads=split(" ",$header);
  $i=0;
  if ($heads[0] eq '#') {
    $colname=$heads[$colnum];
  } else { 
    $colname=$colnum;
  }
  return $colname;
}

sub ChangePrecision
{
  my $number=shift(@_);
  my $prec=shift(@_);
  $numbernew=int($number*10**$prec)/10.0**$prec;  
  return $numbernew;
}

sub GetLine 
{
  $filehandle=shift(@_);
  $line=shift(@_);
  $char=shift(@_);
  if (!defined($char)) {
    $char="\n";
  }
  $testchar='';
  $testchars='';
  $readtest=1;
  while($testchar ne $char && $readtest == 1) {
    $readtest=read($filehandle,$testchar,1);
    $testchars=$testchars.$testchar;
  }
  $$line=$testchars;
  return $readtest;
}

sub GetMin
{
my $aref=shift(@_);
my $min=$$aref[0];
my $i=0;
my $imin;
foreach $val (@$aref) {
  if ($val < $min) {
    $min=$val;
    $imin=$i;
  } 
  $i++;
}
return ($imin,$min);
}

sub GetMax
{
my $aref=shift(@_);
my $max=$$aref[0];
my $i=0;
my $imax;
foreach $val (@$aref) {
  if ($val > $max) {
    $max=$val;
    $imax=$i;
  } 
  $i++;
}
return ($imax,$max);
}

sub GetRange
{
my $aref=shift(@_);
my $max=$$aref[0];
my $min=$$aref[0];
foreach $val (@$aref) {
  if ($val > $max) {
    $max=$val;
  } 
  if ($val < $min) {
    $min=$val;
  } 
}
return ($max-$min);
}

sub LoadArrs
{
my ($aref,$aref2,$j,$i,@arrarr);
$aref=shift(@_);
$aref2=shift(@_);
for($i=1;$i<=scalar(@_);$i++) {
  push(@arrarr,$_[$i-1]);
} 
$i=0;
foreach (@$aref) {
  if (CheckSkip($_)) {
    next;
  }
  @cols=split;
  $j=0;
  foreach $arr (@arrarr) {
    $$arr[$i]=$cols[$$aref2[$j]-1];
    $j++;
  }
  $i++;
}
}

sub LoadArrs2
{
my ($file,$colsref,$cols2ref,$i,@arrarr);
$file=shift(@_);
$colsref=shift(@_);
$cols2ref=shift(@_);
for($i=1;$i<=scalar(@_);$i++) {
  push(@arrarr,$_[$i-1]);
} 
$i=0;
foreach (@$aref) {
  if (CheckSkip($_)) {
    next;
  }
  @cols=split;
  $j=0;
  foreach $arr (@arrarr) {
    $$arr[$i]=$cols[$$aref2[$j]-1];
    $j++;
  }
  $i++;
}
}


sub LoadGrid
{
my ($aref,$xcol,$ycol,$i,@cols,$xval,@fcol);
$aref=shift(@_);
$xcol=shift(@_);
$fcol=shift(@_);
$xsize=shift(@_);
$ysize=shift(@_);
$xmin=shift(@_);
$xmax=shift(@_);
$ymin=shift(@_);
$ymax=shift(@_);
$i=-1;
foreach (@$aref) {
  @cols=split;
  if ($cols[$xcol-1]!=$xval) {
    $xval=$cols[$xcol-1];
    if ($i==-1) {
      $$xmin=$xval;
      $$ymin=$cols[$xcol];
    }
    $j=0;
    $i++;
  } else {
    $j++;
  }
  $fcol[$i][$j]=$cols[$fcol-1];
}
$$xsize=$i+1;
$$ysize=$j+1;
$$xmax=$cols[$xcol-1];
$$ymax=$cols[$xcol];
$xbin=($$xmax-$$xmin)/($$xsize-1);
$ybin=($$ymax-$$ymin)/($$ysize-1);
$$xmax+=$xbin/2;
$$ymax+=$ybin/2;
$$xmin-=$xbin/2;
$$ymin-=$ybin/2;
return \@fcol;
}

sub spline
{
  my ($array,$bin,$yp1,@u,$i,$n,@y2,$k,$qn,$ypn,$sig,$p,$un);
  $array=shift(@_);
  $bin=shift(@_);

  $n=scalar(@$array);

  $yp1=($$array[1]-$$array[0])/$bin;
  $ypn=($$array[$n-1]-$$array[$n-2])/$bin;
  if ($yp1>0.99e30) {
    $y2[1]=0;
    $u[1]=0;
  } else {
    $y2[1]=-0.5;
    $u[1]=(3./$bin*(($$array[1]-$$array[0])/$bin-$yp1));
  }
  for ($i=2;$i<=$n-1;$i++) {
    $sig=0.5;
    $p=$sig*$y2[$i-1]+2;
    $y2[$i]=($sig-1)/$p;
    $u[$i]=(6*(($$array[$i]-$$array[$i-1])/$bin-($$array[$i-1]-$$array[$i-2])/$bin)/(2*$bin)-$sig*$u[$i-1])/$p;
  }
  if ($ypn>0.99e30) {
    $qn=0;
    $un=0;
  } else {
    $qn=0.5;
    $un=(3/$bin)*($ypn-($$array[$n-1]-$$array[$n-2])/$bin);
  }
  $y2[$n]=($un-$qn*$u[$n-1])/($qn*$y2[$n-1]+1);
  for ($k=$n-1;$k>0;$k--) {
    $y2[$k]=$y2[$k]*$y2[$k+1]+$u[$k];
  }
  return \@y2;
}

sub spline2
{
  my ($array,$bin,$yp1,@u,$i,$n,@y2,$k,$qn,$ypn,$sig,$p,$un);
  $array=shift(@_);
  $array2=shift(@_);

  $n=scalar(@$array);

  $yp1=($$array2[1]-$$array2[0])/($$array[1]-$$array[0]);
  $ypn=($$array2[$n-1]-$$array2[$n-2])/($$array[$n-1]-$$array[$n-2]);
  if ($yp1>0.99e30) {
    $y2[1]=0;
    $u[1]=0;
  } else {
    $y2[1]=-0.5;
    $u[1]=(3./($$array[1]-$$array[0])*(($$array2[1]-$$array2[0])/($$array[1]-$$array[0])-$yp1));
  }
  for ($i=2;$i<=$n-1;$i++) {
    $sig=0.5;
    $p=$sig*$y2[$i-1]+2;
    $y2[$i]=($sig-1)/$p;
    $u[$i]=(6*(($$array2[$i]-$$array2[$i-1])/($$array[$i]-$$array[$i-1])-($$array2[$i-1]-$$array2[$i-2])/($$array[$i-1]-$$array[$i-2]))/(2*($$array[$i]-$$array[$i-2]))-$sig*$u[$i-1])/$p;
  }
  if ($ypn>0.99e30) {
    $qn=0;
    $un=0;
  } else {
    $qn=0.5;
    $un=(3/($$array[$n-1]-$$array[$n-2]))*($ypn-($$array2[$n-1]-$$array2[$n-2])/($$array[$n-1]-$$array[$n-2]));
  }
  $y2[$n]=($un-$qn*$u[$n-1])/($qn*$y2[$n-1]+1);
  for ($k=$n-1;$k>0;$k--) {
    $y2[$k]=$y2[$k]*$y2[$k+1]+$u[$k];
  }
  return \@y2;
}

sub splint
{
  my ($k,$khi,$klo,$a,$b,$h,$val,$bin,$min,$array,$array2,$n);
  $array=shift(@_);
  $val=shift(@_);
  $bin=shift(@_);
  $min=shift(@_);
  $array2=shift(@_);

  $n=scalar(@$array);

  $klo=1;
  $khi=$n;
  while ($khi-$klo>1) {
    $k=($khi+$klo)/2;
    if ($bin*$k+$min-3*$bin/2>$val) {
      $khi=$k;
    } else {
      $klo=$k;
    }
  }
  $h=$bin*$khi-$bin*$klo;
  if ($h==0) {
    die "Bad input to splint";
  }
  $a=($bin*$khi+$min-3*$bin/2-$val)/$h;
  $b=($val-$bin*$klo-$min+3*$bin/2)/$h;
  $y=$a*$$array[$klo-1]+$b*$$array[$khi-1]+(($a**3-$a)*$$array2[$klo]+($b**3-$b)*$$array2[$khi])*$h**2/6;
  return $y;
}

sub splint2
{
  my ($k,$khi,$klo,$a,$b,$h,$val,$bin,$min,$array,$array2,$n);
  $array=shift(@_);
  $array2=shift(@_);
  $val=shift(@_);
  $array3=shift(@_);

  $n=scalar(@$array2);

  $klo=1;
  $khi=$n;
  while ($khi-$klo>1) {
    $k=($khi+$klo)/2;
    if ($$array[$k-1]>$val) {
      $khi=$k;
    } else {
      $klo=$k;
    }
  }
  $h=$$array[$khi-1]-$$array[$klo-1];
  if ($h==0) {
    die "Bad input to splint";
  }
  $a=($$array[$khi-1]-$val)/$h;
  $b=($val-$$array[$klo-1])/$h;
  $y=$a*$$array2[$klo-1]+$b*$$array2[$khi-1]+(($a**3-$a)*$$array3[$klo]+($b**3-$b)*$$array3[$khi])*$h**2/6;
  return $y;
}

sub trap
{
  my ($func,$lowbound,$upbound,$sum,$order,$y);
  $func=shift(@_);
  $lowbound=shift(@_);
  $upbound=shift(@_);
  $sum=shift(@_);
  $order=shift(@_);
  $y=shift(@_);

  if ($order==1) {
    $x=($upbound+$lowbound)/2;
    $sum=0.5*($upbound-$lowbound)*(eval($func)+eval($func));
  } else {
    $tnm=2**($order-2);
    $del=($upbound-$lowbound)/$tnm;
    $x=$lowbound+0.5*$del;
    $sum2=0;
    for ($count=1;$count<=$tnm;$count++) {
      $sum2+=eval($func);
      $x+=$del;
    }
    $sum=0.5*($sum+($upbound-$lowbound)*$sum2/$tnm);
  }
  return $sum;
}

sub polint
{
  my ($array,$val,$bin,$min,$ind,$funcval,$i,$y,@c,@d,$ns,$dy,$m,$dif,$dift);

  $array=shift(@_);
  $val=shift(@_);
  $bin=shift(@_);
  $min=shift(@_);

  $ns=1;
  $dif=abs($val-$min-$bin/2);
  for ($i=1;$i<scalar(@$array)+1;$i++) {
    $dift=abs($val-$min-$bin*$i+3*$bin/2);
    if ($dift<$dif) {
      $ns=$i;
      $dif=$dift;
    }
    $c[$i]=$$array[$i-1];
    $d[$i]=$$array[$i-1];
  }
  $y=$$array[$ns-1];
  $ns=$ns-1;
  for ($m=1;$m<scalar(@$array);$m++) {
    for ($i=1;$i<scalar(@$array)-$m+1;$i++) {
      $h0=$i*$bin-$min-3*$bin/2-$val;
      $hp=($i+$m)*$bin-$min-3*$bin/2-$val;
      $w=$c[$i+1]-$d[$i];
      $den=$h0-$hp;
      if ($den==0) {
        die "Failure in polint";
      }
      $den=$w/$den;
      $d[$i]=$hp*$den;
      $c[$i]=$h0*$den;
    }
    if (2*$ns<scalar(@$array)-$m) {
      $dy=$c[$ns+1];
    } else {
      $dy=$d[$ns];
      $ns=$ns-1;
    }
    $y=$y+$dy;
  }
  return $y;
}

sub PrintArgs
{
  my ($i,$k,$l,$m,$args,$names,$string,$description,$j,$thisname,$fileind);
  my ($n,@indarr,@filearr,$name,$name2,$hasfile,$program);
  $args=shift(@_);
  $names=shift(@_);
  $description=shift(@_);
  $hasfile=shift(@_);
  $program=shift(@_);
  $cols=shift(@_);

  
  $j=0;
  $m=1;
  $indarr[0]=0;
  $filearr[0]='temp';
  $optcheck=0;
  $fileind=$hasfile if ($hasfile>0);
  $fileind=1 if ($hasfile==0);
  if ($$args[0] =~ m/^\-/) {
    $thefile=$$args[$fileind];
    $optcheck=1;
  } else {
    $thefile=$$args[$fileind-1];
  }
  if ($hasfile && $thefile =~ m/[\[\*\?]/) {
    system("ls $thefile > colsall_temp");
    open(A,"<colsall_temp");
    @linesA=<A>;
    close(A);
    foreach $file (@linesA) {
      chop($file);
      $argstring="";
      $i=0;
      foreach $arg (@$args) {
        $i++;
        next if (($i==1 && !$optcheck) || ($i<3 && $optcheck));
        $argstring=$argstring."$arg "; 
      }
      if ($optcheck) {
        system("$program $$args[0] $file $argstring");
      } else {
        system("$program $file $argstring");
      }
    }
    die;
  }
  while ($j < scalar(@$args)) {
    $name=$$args[$j];
    $name2=$$args[$j+1];
    if ($name =~ m/^-/ && $name !~ m/^-[0-9]/ && $j==0) {
      $k=1;
      while ($k< length($name)) {
        $options{substr($name,$k,1)}=1;
	$k++;
      }
      splice(@$args,$j,1);
    } elsif ($name =~ m/^-/ && $name !~ m/^-[0-9]/) {
      if (substr($name,1) eq 'F') {
 	$indarr[$m]=$j;
	$filearr[$m]=$name2;
	$m++;
      } else {
        $options{substr($name,1)}=$name2;
      }
      splice(@$args,$j,2);
    } else {
      $j++;
    }
  }
  $indarr[$m]=1e99;
  $k=0;
  $l=$j;
  if ($hasfile && $$args[$fileind-1] =~ m/[\[\*\?]/) {
    system("ls $$args[$fileind-1] > colsall_temp");
    open(A,"<colsall_temp");
    @linesA=<A>;
    close(A);
    foreach $file (@linesA) {
      chop;
      $argstring="";
      $i=0;
      foreach $arg (@$args) {
        $i++;
        next if ($i==1);
        $argstring=$argstring."$arg "; 
      }
      print "$program $file $argstring\n";
      system("$program $file $argstring");
    }
    die;
  }
  $i=0;
  if ($j>0 && $hasfile && !stat("$$args[$fileind-1]")) {
    $j++;
    $l++;
#    print STDERR "STDIN\n";
    unshift(@$args,"stdin_temp");
    @linesA=<STDIN>;
    open(B,">stdin_temp");
    print B @linesA;
    close(B);
  }
  close(A);
  foreach $name (@$names) {
    if ($name !~ m/\!/) {
      $i++;
    } elsif ($name !~ m/^\!/) {
      if (!defined($$args[$k])) {
        ($thisname,$value)=split("!",$name);
        $$args[$k]=$value;
        $l++;
      }
    }
    $k++;
  }
  if (scalar(@$names)>scalar(@$args)) {
    $k=scalar(@$names);
  } else {
    $k=$l;
  }
  $$args[$k]=\%options;
  if (($j>0 && scalar(@$names)>0)) {
    if ($j<$i) {
      print "Need at least $i arguments in $program\n";
      die;
    }
  } else {
    $i=1;
    if ($description =~ m/!(.*)/) {
      $requires=$1;
      $description =~ s/!(.*)//g;
      print "\nDescription\n-----------\n$description\n\nRequires: $requires\n\n";
    } else {
      print "\nDescription\n-----------\n$description\n\n";
    }
    foreach (@$names) {
      if ($$names[$i-1] =~ m/\!/) {
	if ($$names[$i-1] =~ m/^\!/) {
          $string=substr($$names[$i-1],1);
          print "$i) $string (Optional)\n";
	} else {
          ($thisname,$value)=split("!",$$names[$i-1]);
          print "$i) $thisname (Default=$value)\n";
        }
      } elsif ($$names[$i-1] =~ m/^\*/) {
        $string=substr($$names[$i-1],1);
	print "$i-?) $string\n";
      } else {
        print "$i) $$names[$i-1]\n";
      }  
      $i++;
    }   
    die;
  }
  $i=0;
  foreach (@args) {
    $m=0;
    foreach $ind (@indarr) {
      if ($ind>$i) {
        $$cols[$i]=$filearr[$m-1];
        last;
      }
      $m++;
    }
    $i++;
  }

# Make a log of the program call

  open(X,">>.cols.log");
  print X "$program @$args\n";
  close(X);

  return $j;
}

sub PrintHead
{
  my ($array,$headvals);
  $array=shift(@_);
  $headvals=shift(@_);
  if ($$array[0] =~ m/^#/) {
    chop($$array[0]);
    print "$$array[0] ";
    foreach $head (@$headvals) {
      print "$head ";
    } 
    print "\n#\n";
  }
}

sub ReadFile 
{
  my ($file,@linesA);
  $file=shift(@_);
  $bincheck=shift(@_);
  $bincheck2=shift(@_);
  if (!defined($bincheck)) {
    if (!open(A,"<$file")) {
      print "Couldn't open $file\n";
      die;
    } else {
      @linesA=<A>;
      if ($linesA[0] =~ m/^#/) {
	shift(@linesA);
      }
      if ($linesA[0] =~ m/^#/) {
	shift(@linesA);
      }
    }
  } elsif ($bincheck2) {
    if (!open(A,"<$file")) {
      print "Couldn't open $file\n";
      die;
    } else {
      sysread(A,$bina,-s $file);
      @lines=unpack("(x4 $bincheck x4)\*",$bina);
      $i=0;
      while($linesA[$i]=join(" ",splice(@lines,0,length($bincheck)))) {
        $i++;
      }
    }
  } else {
    if (!open(A,"<$file")) {
      print "Couldn't open $file\n";
      die;
    } else {
      sysread(A,$bina,-s $file);
      @lines=unpack("($bincheck)\*",$bina);
      $i=0;
      while($linesA[$i]=join(" ",splice(@lines,0,length($bincheck)))) {
        $i++;
      }
    }
  }
  close(A);
  return \@linesA;
}

sub CheckSkip
{
  if ($_[0] =~ m/^#/ || $_[0] !~ m/\S/) {
    return 1;
  }
  return 0;
}

sub SumArr
{
  my ($arr,$i,$sum);
  $arr=shift(@_);
  $sum=0;
  foreach (@$arr) {
    $sum+=$_;
  }
  return $sum;
}

sub SetOpts
{
  my ($options,$name);
  $options=shift(@_);
  $name=shift(@_);
  if (!defined($$options{'o'})) {
    $$options{'o'}="temp_$name";
  }
  if (!defined($$options{'viewer'})) {
    $$options{'viewer'}="Preview";
  }
  if (!defined($$options{'xlabel'})) {
    $$options{'xlabel'}="x";
  }
  if (!defined($$options{'ylabel'})) {
    $$options{'ylabel'}="y";
  }
  if (!defined($$options{'zlabel'})) {
    $$options{'zlabel'}="z";
  }
  if (!defined($$options{'otype'})) {
    $$options{'otype'}="postgreyfile";
  }
  if (!defined($$options{'del'})) {
    $$options{'del'}=' ';
  }
  return $options;
}

sub Angdiff
{
  my $ang1=shift(@_);
  my $ang2=shift(@_);
  my $ang1_2=atan2(sin($ang1),cos($ang1));
  my $ang2_2=atan2(sin($ang2),cos($ang2));
  my $angdiff;
  $angdiff=abs($ang1-$ang2);
  if ($angdiff>pi) {
    $angdiff=2*pi-$angdiff;
  }
  return $angdiff;
}

sub nint
{
  my $flt=shift(@_);
  if ($flt-int($flt)>=0.5) {
    $int=int($flt)+1;
  } else {
    $int=int($flt);
  }
  return $int;
}

sub Finish
{
  if (stat("stdin_temp")) {
    system("rm stdin_temp");
  }
  if (stat("colsall_temp")) {
    open(A,"<colsall_temp");
    @linesA = <A>;
    close(A);
    system("rm colsall_temp");
  }
}

sub Conv2Fort
{
  $string=shift;
  if ($string =~ m/\$([0-9a-zA-Z]+)/) {
    $string =~ s/\$([0-9a-zA-Z]+)/$+/g;
  } 
  return $string;
}


sub MakeFortString
{
  $num=shift;
  
  if ($num-int($num)==0) {
    $num=$num.".";
  }
  return $num;
}

1; #
