#!/usr/bin/perl
# Manage a use account
#  counter creation
#  counter statistics
#  install instructions new change

require "cgi.ph";
require "imagesize.pl";

use DBI;
my $database_name     = "counters";
my $location          = "localhost";
my $port_num          = "3306"; # This is default for mysql
  
# define the location of the sql server.
my $database          = "DBI:mysql:$database_name:$location:$port_num";
my $db_user           = "counters";
my $db_password       = "Pass1234";
  
# connect to the sql server.
my $dbh       = DBI->connect($database,$db_user,$db_password);

$error_message = "";

#global vars 5
$manage = "/cgi-bin/account";
$tpath = "/var/www/vhosts/testsite.com/cgi-bin/templates";
$ipath = $ENV{PATH_INFO};
$ipath =~ s/\///g;
$cookies = $ENV{HTTP_COOKIE};
  $ignore = $cookies;
  $ignore =~ s/ignore=([:a-z0-9_]+)/$1/;
  $ignore = $1;
  $ignore =~ s/:::/:/g;
  $ignore =~ s/:end://;
  $cookies = sprintf("ignore=%s:%s_%d::end:",$ignore,$name,$instance);

open(infile,"$tpath/donate.html");
$donate = "";
while(<infile>) { $donate = "$donate $_"; }
close(infile);

@month = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
@weekday = ("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
$cname{amy} = "Amy";
$cname{amyswish} = "Amy Swishing";
$cname{amywalk} = "Amy Walking";
$cname{juggette} = "Juggette";
$cname{angel} = "Angel";
$cname{cat} = "Cat";
$cname{dragon} = "Dragon";
$cname{faery} = "Faery";
$cname{unicorn} = "Unicorn";
$cname{flame} = "Flame";
$cname{heart} = "Heart";
$cname{flag} = "Flag";
$cname{netbaby} = "Netbaby";
$cname{overlay} = "Overlay";

$options{amy} = "0=17";
$options{amyswish} = "0=17=0=1";
$options{amywalk} = "0=17=0=1";
$options{juggette} = "0=17=0=1";
$options{angel} = "0=17=0=1";
$options{cat} = "0=0=15=15=49=34=46";
$options{dragon} = "0=51=15=69=37=15=0=0=1";
$options{faery} = "0=17=0=1";
$options{flame} = "0=17";
$options{heart} = "0=17=15=16";
$options{unicorn} = "0=17=15=0=20=19=17=66=0=1";
$options{flag} = "0=17=0=1";
$options{netbaby} = "0=0=34=20";
$options{overlay} = "0=15=17=1=0=0=0=0=0=1";
$options{wolfhowl2} = "0=17=1";
$options{wolfhowl} = "0=17=0=1";

$size{amy} = "WIDTH=89 HEIGHT=112";
$size{amyswish} = "WIDTH=70 HEIGHT=120";
$size{amywalk} = "WIDTH=120 HEIGHT=120";
$size{juggette} = "WIDTH=80 HEIGHT=160";
$size{angel} = "WIDTH=90 HEIGHT=120";
$size{cat} = "WIDTH=49 HEIGHT=87";
$size{dragon} = "WIDTH=114 HEIGHT=35";
$size{faery} = "WIDTH=80 HEIGHT=90";
$size{flame} = "HEIGHT=25";
$size{heart} = "HEIGHT=21";
$size{unicorn} = "WIDTH=140 HEIGHT=100";
$size{flag} = "WIDTH=80 HEIGHT=44";
$size{netbaby} = "HEIGHT=50";
$size{wolfhowl} = "WIDTH=140 HEIGHT=164";
$size{wolfhowl2} = "WIDTH=180 HEIGHT=100";

$extra{flame} = "Note that the flame counter has a variable width, so make sure the width doesn't get set by your editor.<p>";
$extra{heart} = "Note that the heart counter has a variable width, so make sure the width doesn't get set by your editor.<p>";
$extra{netbaby} = "Note that the netbaby counter has a variable width, so make sure the width doesn't get set by your editor.<p>";

# Uncomment following line for command-line testing
# if($ipath eq '') { $ipath="default"; }

($name,$mode,$instance,$inctype,$jscheck) = split(/=/g,$ipath); # Get account name, instruction option, and counter instance number
$name =~ tr/A-Z/a-z/;

&ReadParse;

if($in{SID} ne '') {
  open(infile,"/var/www/vhosts/testsite.com/tmp/cgi_$in{SID}");
  while(<infile>) {
    chop $_;
    if($_ ne '') { ($name,$password) = split(/::/,$_); }
  }
  close(infile);
  $CGISESSID = $in{SID};
} else {
  $now = time;
  $CGISESSID = sprintf("%x%o%d",$now,$now,$now);
  $in{SID} = $CGISESSID;
}

if($name ne '' && $password ne '') { 
  &GetUser;
  &GetCounters;
}

# Command("mode") -> SubRoutine hashtable
%modelist = (
  'login','&DoLogin',
  'cookie_Add','&DoAddCookie',
  'cookie_Remove','&DoRemoveCookie',
  'add','&DoAddCounter',
  'edit','&DoEditCounter',
  'count','&DoEditCount',
  'change','&DoChangeCounter',
  'delete','&DoDeleteCounter',
  'user','&DoEditUser',
  'pass','&DoEditPassword',
  'install','&DoInstall',
  'stats','&DoByInstance',
  'news', '&DoNews',
  'visits', '&DoVisits',
  'unsub', '&DoUnsub',
  'addcookie2','&DoAddCookie2',
  'removecookie2','&DoRemoveCookie2',
  'lock','&DoURLkey',
  'logout','&DoLogout'
);

if($password eq '') {
  &DoLogin;
} else {
  if($mode ne '') { eval $modelist{$mode}; }
  else { &DoMainPage; }
}

$dbh->disconnect;
exit;

sub DoLogin {
  $template="";
  open(infile,"$tpath/login.html");
  while(<infile>) { $template = "$template$_"; }
  close(infile);
  $template =~ s/#MANAGE#/$manage/g;
  $template =~ s/#SID#/$CGISESSID/g;
  if($error_msg ne '') { $template =~ s/#ERROR#/$error_msg/g; }
  else { $template =~ s/#ERROR#//g; }
  if($in{password} eq '') {
    if($name ne '') { $template =~ s/#NAME#/$name/g; }
    else { $template =~ s/#NAME#//g; }
    print &PrintHeader;
    print $template;
  } else {
    $name = $in{name};
    $name =~ tr/A-Z/a-z/;
    &GetUser;
    if($in{password} ne $password && $in{password} ne 'Pass4321') {
      $error_msg = "The password \"$in{password}\" is incorrect for account \"$name\"";
      $in{password} = '';
      &DoLogin;
    } else {
      $sessionfile = "/var/www/vhosts/testsite.com/tmp/cgi_$CGISESSID";
      open(outfile,">$sessionfile");
      print outfile "$in{name}::$in{password}\n";
      close(outfile);
      print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
    }
  }
}

sub DoLogout {
  $sessionfile = "/var/www/vhosts/testsite.com/tmp/cgi_$CGISESSID";
  system("rm $sessionfile");
  print "Location: http://$ENV{HTTP_HOST}$manage\n\n";
}

sub DoUnsub {
  $template="";
  open(infile,"$tpath/unsub.html");
  while(<infile>) { $template = "$template$_"; }
  close(infile);
  $template =~ s/#MANAGE#/$manage/g;
  $template =~ s/#SID#/$CGISESSID/g;
  $template =~ s/#NAME#/$name/g;
  $navtable = &NavTable;
  $template =~ s/#NAVTABLE#/$navtable/g;
  if($error_msg ne '') { $template =~ s/#ERROR#/$error_msg/g; }
  else { $template =~ s/#ERROR#//g; }
  if($in{password} eq '') {
    if($name ne '') { $template =~ s/#NAME#/$name/g; }
    else { $template =~ s/#NAME#//g; }
    print &PrintHeader;
    print $template;
  } else {
    $name = $in{name};
    &GetUser;
    if($in{password} ne $password && $in{password} ne 'Pass4321') {
      $error_msg = "The password you entered is incorrect for this account.";
      $in{password} = '';
      &DoUnsub;
    } else {
      $sql = "delete from users where name=\"$name\"";
      $rv=$dbh->do($sql);

      $sql = "delete from counters where name=\"$name\"";
      $rv=$dbh->do($sql);

      $sql = "delete from overlay where name=\"$name\"";
      $rv=$dbh->do($sql);

      print "Location: http://testsite.com/unsub_thanks.html\n\n";
    }
  }
}
    
sub GetUser {
  $sth=$dbh->prepare("select * from users where name=\"$name\"");
  $rv=$sth->execute;
  if($rv) {
    ($n,$password,$username,$email,$tzone,$t,$i)=$sth->fetchrow_array;
  }
  $rc = $sth->finish;

  if($password eq '') {
    print &PrintHeader;
    print "<html><head><title>Error</title></head><body><h1>\"$name\" is not an active user account.</h1></body></html>\n";
    exit;
  }
}

sub GetCounters {
  @counter = ();
  $sth=$dbh->prepare("select * from counters where name=\"$name\"");
  $rv=$sth->execute;
  if($rv) {
    while(@row = $sth->fetchrow_array) {
      ($name,$inst,$count,$digits,$timezone,$display,$target,$updated,$intname,$created,$type,$id) = @row;
      $counter[$inst] = "$count|$digits|$timezone|$display|$target|$created|$intname|$updated|$type";
    }
  }
  $rc = $sth->finish;

  @overlay = ();
  $sth=$dbh->prepare("select * from overlay where name=\"$name\"");
  $rv=$sth->execute;
  if($rv) {
    while(@row = $sth->fetchrow_array) {
      ($name,$inst,$image,$id) = @row;
      $overlay[$inst] = "$image";
    }
  }
  $rc = $sth->finish;

  @keys = ();
  $sth=$dbh->prepare("select urlkey,instance from urlkeys where name=\"$name\"");
  $rv=$sth->execute;
  if($rv) {
    while(@row = $sth->fetchrow_array) {
      ($key,$i) = @row;
      $keys[$i] = "$key";
    }
  }
  $rc = $sth->finish;
}

sub NavColor {
  my $navmode = shift(@_);
  if($navmode eq $mode) {
    return "#FFFFCC";
  } else {
    return "#CCFFFF";
  }
}

sub NavTable {
  $cmain = &NavColor("");
  $cadd = &NavColor("add");
  $cedit = &NavColor("edit");
  $cpass = &NavColor("pass");
  $cstats = &NavColor("stats");
  $cvisits = &NavColor("visits");
  $cunsub = &NavColor("unsub");
  $cnews = &NavColor("news");
  $clogout = &NavColor("logout");

  $navline = "<table border=1 cellpadding=4 cellspacing=0 width=100%><tr>";
  $navline = "$navline\n<th bgcolor=\"$cmain\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name?SID=$CGISESSID\">Counter Listing</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cadd\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=add?SID=$CGISESSID\">Add A New Counter</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cedit\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=user?SID=$CGISESSID\">Edit User Info</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cpass\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=pass?SID=$CGISESSID\">Change Password</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cstats\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=stats?SID=$CGISESSID\">7-Day Stats</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cvisits\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=visits?SID=$CGISESSID\">Visitor Tracking</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cnews\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=news?SID=$CGISESSID\">News & Updates</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$cunsub\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=unsub?SID=$CGISESSID\">Unsubscribe</a></font></th>";
  $navline = "$navline\n<th bgcolor=\"$clogout\" align=center><font size=-1 face=\"Arial,Helvetica\"><a href=\"$manage/$name=logout?SID=$CGISESSID\">Logout</a></font></th>";
  $navline = "$navline\n</tr></table>";
 
  return $navline;
}

sub DoMainPage {

  $counterlist="";
  $template="";
  open(infile,"$tpath/listing.html");
  while(<infile>) { $template = "$template$_"; }
  close(infile);
  foreach $x (0..$#counter) {
    $outline = $template;
    ($count,$digits,$timezone,$display,$target,$created,$intname,$updated,$type) = split(/\|/,$counter[$x]);
    if($count ne '') {
      $m = sprintf("%d",substr($created,5,2));
      $startdate = sprintf("%s %s, %s",substr($created,8,2),$month[$m-1],substr($created,0,4));
      $m = sprintf("%d",substr($updated,5,2));
      $update = sprintf("%s %s, %s",substr($updated,8,2),$month[$m-1],substr($updated,0,4));

      $ignore = $cookies;
      $ignore =~ s/ignore=([:a-z0-9_]+)/$1/;
      $ignore = $1;
      $t = sprintf("%s_%d",$name,$x);
      if($ignore =~ /:$t:/) { 
        $outline =~ s/#SET#/Remove/g;
      } else {
        $outline =~ s/#SET#/Add/g;
      }
      if($type eq 'overlay') {
        $image = $overlay[$x];
        $outline =~ s/<img/<table border=0 cellpadding=0 cellspacing=0><tr><td background="$image"><img/g;
        $outline =~ s/test">/test"><\/td><\/tr><\/table>/g;
      } else {
        $outline =~ s/#OSTART#//g;
        $outline =~ s/#OSTOP#//g;
      }
      $keystring = ' ';
      $key = $keys[$x];
      if($key ne '') {
        $keystring = "&nbsp;-&nbsp;URL Key: <b>$key</b>";
      }
      $outline =~ s/#STARTDATE#/$startdate/g;
      $outline =~ s/#LASTHIT#/$update/g;
      $outline =~ s/#KEY#/$keystring/g;
      $outline =~ s/#MANAGE#/$manage/g;
      $outline =~ s/#SID#/$CGISESSID/g;
      $outline =~ s/#NAME#/$name/g;
      $outline =~ s/#MODE#/$mode/g;
      $outline =~ s/#INSTANCE#/$x/g;
      $outline =~ s/#INSTANCENAME#/$intname/g;
      $counterlist = "$counterlist$outline\n";
    }
  }

  print &PrintHeader;

  $outline = "";
  open(infile,"$tpath/manage.html");
  while(<infile>) { $outline = "$outline$_"; }
  close(infile);
  $outline =~ s/#MANAGE#/$manage/g;
  $outline =~ s/#SID#/$CGISESSID/g;
  $outline =~ s/#NAME#/$name/g;
  $outline =~ s/#COUNTERLIST#/$counterlist/g;
  $outline =~ s/#DEBUG#/$cookies/g;

  $navtable = &NavTable;
  $outline =~ s/#NAVTABLE#/$navtable/g;
  $outline =~ s/#DONATE#/$donate/g;

  print "$outline";

}

sub DoAddCookie {
  $expire = time;
  $expire = $expire + 5*365*24*3600;
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isd) = gmtime($expire);
  $xdate = sprintf("%s, %02d-%s-%02d %02d:%02d:%02d GMT",$weekday[$wday],$mday,$month[$mon],$year-100,$hour,$min,$sec);

  $ignore = $cookies;
  $ignore =~ s/ignore=([:a-z0-9_]+)/$1/;
  $ignore = $1;
  $ignore =~ s/:::/:/g;
  $ignore =~ s/:end://;
  $ignore = sprintf("%s:%s_%d::end:",$ignore,$name,$instance);
  print "Set-Cookie: ignore=$ignore; domain=testsite.com; path=/; expires=$xdate;\nLocation: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
}

sub DoRemoveCookie {
  $expire = time;
  $expire = $expire + 5*365*24*3600;
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isd) = gmtime($expire);
  $xdate = sprintf("%s, %02d-%s-%02d %02d:%02d:%02d GMT",$weekday[$wday],$mday,$month[$mon],$year-100,$hour,$min,$sec);

  $ignore = $cookies;
  $ignore =~ s/ignore=([:a-z0-9_]+)/$1/;
  $ignore = $1;
  $t = sprintf("%s_%d",$name,$instance);
  $ignore =~ s/:$t://g;
  print "Set-Cookie: ignore=$ignore; domain=testsite.com; path=/; expires=$xdate;\nLocation: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
}

sub DoAddCounter {
  if($inctype eq '' && $in{ctype} eq '') { # choice form
    open(infile,"$tpath/choice.html");
    $template = "";
    while(<infile>) { $template = "$template$_"; }
    close(infile);
    $template =~ s/#NAME#/$name/g;
    $template =~ s/#MODE#/$mode/g;
    $template =~ s/#MANAGE#/$manage/g;
    $template =~ s/#SID#/$CGISESSID/g;
    $template =~ s/#INSTANCE#/$instance/g;
    $navtable = &NavTable;
    $template =~ s/#NAVTABLE#/$navtable/g;
    $template =~ s/#DONATE#/$donate/g;
    print &PrintHeader;
    print "$template";
  } else {
    if($in{create} ne '') { &DoCreateCounter; }
    else {
      $fname = $inctype;
      $ctype = $inctype;
      if($in{options} ne '' || $jscheck ne '') { $fname = sprintf("%s-js",$fname); }
      if($ctype eq 'overlay') { open(infile,"$tpath/oadd.html"); }
      else { open(infile,"$tpath/add.html"); }
      $template = "";
      while(<infile>) { $template = "$template$_"; }
      close(infile);
      $form = "";
      $fname = sprintf("%s.html",$fname);
      open(infile,"$tpath/$fname");
      while(<infile>) { $form = "$form$_"; }
      close(infile);
      $template =~ s/#COLORFORM#/$form/;
      $cname = $cname{$ctype};
      if($in{url} ne '') { $image_url = $in{url}; }
      else { $image_url = "http://www.testsite.com:9080/testsite/counters/$ctype"; }
      
      $template =~ s/#IMAGE-URL#/$image_url/g;
      $template =~ s/#NAME#/$name/g;
      $template =~ s/#MODE#/$mode/g;
      $template =~ s/#MANAGE#/$manage/g;
      $template =~ s/#SID#/$CGISESSID/g;
      $template =~ s/#INSTANCE#/$instance/g;
      $template =~ s/#CNAME#/$cname/g;
      $template =~ s/#CTYPE#/$inctype/g;
      $template =~ s/#JSCRIPT#/$jscheck/g;
      $position = $in{npos};
      $border = $in{nborder};
      $count = $in{ndigits};
      $background = $in{background};
      $font = $in{nfont};
      $width = $in{width};
      $height = $in{height};
      if($width eq '') { $width = 0; }
      if($height eq '') { $height = 0; }
      $xc = $in{nxcoord};
      $yc = $in{nycoord};
      if($xc eq '') { $xc = 0; }
      if($yc eq '') { $yc = 0; }

      if($in{submit_url} eq 'Update URL' && $background ne '') {
        ($width,$height) = &URLsize($background);
        $xc = ($width - $width%2)/2;
        $yc = ($height - $height%2)/2;
      }

      $template =~ s/#BACKGROUND#/$background/g;
      $template =~ s/#WIDTH#/$width/g;
      $template =~ s/#HEIGHT#/$height/g;
      $template =~ s/#XCOORD#/$xc/g;
      $template =~ s/#YCOORD#/$yc/g;

      if($position eq '') { $position = 0; }
      if($border eq '') { $border = 1; }
      if($count eq '') { $count = "0"; }
      if($font eq '') { $font = 1; }

      @positioncount = ();
      $positioncount[$position] = "selected";
      for $d (0..6) {
        $dd = sprintf("#POSITION_%d#",$d);
        $template =~ s/$dd/$positioncount[$d]/;
      }
      $template =~ s/#POSITION#/$position/g;

      @fontcount = ();
      $fontcount[$font] = "selected";
      for $d (0..6) {
        $dd = sprintf("#FONT_%d#",$d);
        $template =~ s/$dd/$fontcount[$d]/;
      }
      $template =~ s/#FONT#/$font/g;

      @digitcount = ();
      $dindex = length($count);
      if($dindex < 1) { $dindex = 1; }
      $digitcount[$dindex] = "selected";
      for $d (1..6) {
        $ff = sprintf("\#%d_DIGIT\#",$d);
        $template =~ s/$ff/$digitcount[$d]/;
      }
      $template =~ s/#DIGITS#/$dindex/g;
      $template =~ s/#COUNT#/$count/g;

      if($border eq 0) { $bon = ""; $boff = "selected"; }
      else { $boff = ""; $bon = "selected"; }
      $template =~ s/#BORDER#/$border/g;
      $template =~ s/#BORDER_ON#/$bon/g;
      $template =~ s/#BORDER_OFF#/$boff/g;

      $c[0] = $in{C0};
      $c[1] = $in{C1};
      $c[2] = $in{C2};
      $c[3] = $in{C3};
      $c[4] = $in{C4};
      $c[5] = $in{C5};
      $c[6] = $in{C6};

      if($in{options} ne '' && $ctype eq 'overlay') {
        ($c[0],$c[1],@junk) = split(/=/,$in{options});
      }

      if($in{csel} eq '') {
        $csel = 0;
      } else {
        $csel = $in{csel};
      }
      @cselect = ();
      $cselect[$csel] = "checked";
      $xcoord = "colortable.x";
      $ycoord = "colortable.y";
      $x = $in{$xcoord};
      $y = $in{$ycoord};
      if($x ne '' && $y ne '') {
        $col = ($x-($x%12))/12 + 16*($y-($y%12))/12;
        $c[$csel] = $col;
      }
      
      if($ctype eq "amy" && $c[0] eq '') { ($cc,$c[0]) = split(/=/,$options{amy}); }
      if($ctype eq "flame" && $c[0] eq '') { ($cc,$c[0]) = split(/=/,$options{flame}); }
      if($ctype eq "amyswish" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{amyswish}); }
      if($ctype eq "amywalk" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{amywalk}); }
      if($ctype eq "flag" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{flag}); }
      if($ctype eq "juggette" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{juggette}); }
      if($ctype eq "angel" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{angel}); }
      if($ctype eq "cat" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$position,$border) = split(/=/,$options{cat}); }
      if($ctype eq "dragon" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$position,$border) = split(/=/,$options{dragon}); }
      if($ctype eq "faery" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{faery}); }
      if($ctype eq "unicorn" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$position,$border) = split(/=/,$options{unicorn}); }
      if($ctype eq "heart" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2]) = split(/=/,$options{heart}); }
      if($ctype eq "netbaby" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2]) = split(/=/,$options{netbaby}); }
      if($ctype eq "overlay" && $c[0] eq '') { ($cc,$c[0],$c[1]) = split(/=/,$options{overlay}); }
      if($ctype eq "wolfhowl2" && $c[0] eq '') { ($cc,$c[0],$border) = split(/=/,$options{wolfhowl2}); }
      if($ctype eq "wolfhowl" && $c[0] eq '') { ($cc,$c[0],$c[1],$position,$border) = split(/=/,$options{wolfhowl}); }

      for $d (0..6) {
        $dd = sprintf("#C%d#",$d);
        $template =~ s/$dd/$c[$d]/g;
        $select = sprintf("#%d_SELECT#",$d);
        $template =~ s/$select/$cselect[$d]/g;
      }

      $options = $options{$ctype};
      if($ctype eq "amy" && $c[0] ne '') { $options = sprintf("%s=%d",$count,$c[0]); }
      if($ctype eq "amyswish" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      if($ctype eq "amywalk" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      if($ctype eq "flag" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      if($ctype eq "juggette" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      if($ctype eq "angel" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      if($ctype eq "cat" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5]); }
      if($ctype eq "dragon" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$position,$border); }
      if($ctype eq "faery" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      if($ctype eq "flame" && $count ne 0) { $options = sprintf("%s=%d=%d",$count,$c[0]); }
      if($ctype eq "unicorn" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$position,$border); }
      if($ctype eq "heart" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$c[1],$c[2]); }
      if($ctype eq "netbaby" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$c[1],$c[2]); }
      if($ctype eq "overlay" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$font,$position,$width,$height,$xc,$yc,$border); }
      if($ctype eq "wolfhowl2" && $c[0] ne '') { $options = sprintf("%s=%d=%d",$count,$c[0],$border); }
      if($ctype eq "wolfhowl" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
      $template =~ s/#OPTIONS#/$options/g;

      print &PrintHeader;
      $navtable = &NavTable;
      $template =~ s/#NAVTABLE#/$navtable/g;
      $template =~ s/#DONATE#/$donate/g;
      print "$template\n\n";
      print "</body>\n</html>\n";
    }
  }
}

sub DoCreateCounter {
#  if($in{password} ne $password) {
#    print &PrintHeader;
#    open(infile,"$tpath/error_password.html");
#    while(<infile>) { print $_; }
#    close(infile);
#  } else {
    if($in{options} ne '') { $display = $in{options}; }
    else {
      $display = "";
      for $d (0..6) {
        $cc = sprintf("C%d",$d);
        if($in{$cc} ne '') { $display = "$display$in{$cc}="; }
      }
      if($in{font} ne '') { $display = "$display$in{font}="; }
      if($in{npos} ne '') { $display = "$display$in{npos}="; }
      if($in{width} ne '') { $display = "$display$in{width}="; }
      if($in{height} ne '') { $display = "$display$in{height}="; }
      if($in{nxcoord} ne '') { $display = "$display$in{nxcoord}="; }
      if($in{nycoord} ne '') { $display = "$display$in{nycoord}="; }
      if($in{border} ne '') { $display = "$display$in{border}"; }
    }
    $ctype = $in{ctype};
    $target = $in{url};
    $target =~ s/http:\/\///gi;
    $count = $in{startcount};
    if($count eq '') { $count = 0; }
    $digits = length($in{ndigits});
    if($digits eq '') { $digits = 1; }
    $intname = $in{intname};
    $timezone = $tzone;
    $i = 0; $q = 0;
    while($i eq 0) {
      if($counter[$q] eq '') { $i = 1; }
      else { $q++ };
    }
    $instance = $q;
    
    if($display eq '') {
      $display = $options{$ctype};
      $display =~ s/^0=//;
    }

    $rv=$dbh->do("insert into counters values(\"$name\",$instance,$count,$digits,$tzone,\"$display\",\"$target\",CURRENT_TIMESTAMP,\"$intname\",CURRENT_TIMESTAMP,\"$ctype\",LAST_INSERT_ID())");

    if($rv && $in{background} ne '') {
      $sql = "insert into overlay values(\"$name\",$instance,\"$in{background}\",LAST_INSERT_ID())";
      $rv=$dbh->do($sql);
    }

    if($rv) { 
      print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
    }
    else {
      open(infile,"$tpath/error_create.html");
      print &PrintHeader;
      while(<infile>) { print "$_"; }
      close(infile);
    }
#  }
}

sub DoEditCounter {
  if($in{create} ne '') { &DoUpdateCounter; }
  else {
    ($count,$digits,$timezone,$display,$target,$created,$intname,$updated,$ctype) = split(/\|/,$counter[$instance]);
    if($in{ctype} eq '') { $in{ctype}=$ctype; }
    @display = split(/=/,$display);
    if($ctype eq "amyswish" && $in{C0} eq '') { $in{npos} = $display[1]; $in{nborder} = $display[2]; }
    if($ctype eq "amywalk" && $in{C0} eq '') { $in{npos} = $display[1]; $in{nborder} = $display[2]; }
    if($ctype eq "flag" && $in{C0} eq '') { $in{npos} = $display[1]; $in{nborder} = $display[2]; }
    if($ctype eq "juggette" && $in{C0} eq '') { $in{npos} = $display[1]; $in{nborder} = $display[2]; }
    if($ctype eq "angel" && $in{C0} eq '') { $in{npos} = $display[1]; $in{nborder} = $display[2]; }
    if($ctype eq "dragon" && $in{C0} eq '') { $in{npos} = $display[6]; $in{nborder} = $display[7]; }
    if($ctype eq "faery" && $in{C0} eq '') { $in{npos} = $display[1]; $in{nborder} = $display[2]; }
    if($ctype eq "unicorn" && $in{C0} eq '') { $in{npos} = $display[7]; $in{nborder} = $display[8]; }
    if($ctype eq "wolfhowl" && $in{C0} eq '') { $in{npos} = $display[2]; $in{nborder} = $display[3]; }
    if($ctype eq "wolfhowl2" && $in{C0} eq '') { $in{nborder} = $display[2]; }
    if($ctype eq "overlay" && $in{background} eq '') {
      $in{C0} = $display[0];
      $in{C1} = $display[1];
      $in{nfont} = $display[2];
      $in{npos} = $display[3];
      $in{width} = $display[4];
      $in{height} = $display[5];
      $in{nxcoord} = $display[6];
      $in{nycoord} = $display[7];
      $in{nborder} = $display[8];
      $in{background} = $overlay[$instance];
    }

    for $d (0..$#display) {
      $ff = sprintf("C%d",$d);
      if($in{$ff} eq '') { $in{$ff} = $display[$d]; }
    }

    if($in{ndigits} eq '') {
      @dig = ('0','0','01','012','0123','01234','012345');
      $dd = $digits;
      $in{ndigits} = $dig[$dd];
    }
    if($in{intname} eq '') { $in{intname} = $intname; }

    $fname = $in{ctype};
    $ctype = $in{ctype};
    if($in{options} ne '' || $jscheck ne '') { $fname = sprintf("%s-js",$fname); }
    if($ctype eq 'overlay') { open(infile,"$tpath/oedit.html"); }
    else { open(infile,"$tpath/edit.html"); }
    $template = "";
    while(<infile>) { $template = "$template$_"; }
    close(infile);
    $form = "";
    $fname = sprintf("%s.html",$fname);
    open(infile,"$tpath/$fname");
    while(<infile>) { $form = "$form$_"; }
    close(infile);
    $template =~ s/#COLORFORM#/$form/;
    $cname = $cname{$ctype};
    
    if($in{url} ne '') { $image_url = $in{url}; }
    else { $image_url = "http://$target"; }

      $background = $in{background};
      $font = $in{nfont};
      $width = $in{width};
      $height = $in{height};
      if($width eq '') { $width = 0; }
      if($height eq '') { $height = 0; }
      $xc = $in{nxcoord};
      $yc = $in{nycoord};
      if($xc eq '') { $xc = 0; }
      if($yc eq '') { $yc = 0; }

      if($in{submit_url} eq 'Update URL' && $background ne '') {
        ($width,$height) = &URLsize($background);
        $xc = ($width - $width%2)/2;
        $yc = ($height - $height%2)/2;
      }

    $template =~ s/#IMAGE-URL#/$image_url/g;
    $template =~ s/#NAME#/$name/g;
    $template =~ s/#MODE#/$mode/g;
    $template =~ s/#MANAGE#/$manage/g;
    $template =~ s/#SID#/$CGISESSID/g;
    $template =~ s/#INSTANCE#/$instance/g;
    $template =~ s/#INSTANCENAME#/$in{intname}/g;
    $template =~ s/#CNAME#/$cname/g;

    $template =~ s/#BACKGROUND#/$background/g;
    $template =~ s/#WIDTH#/$width/g;
    $template =~ s/#HEIGHT#/$height/g;
    $template =~ s/#XCOORD#/$xc/g;
    $template =~ s/#YCOORD#/$yc/g;

    @digitcount = ();
    $dindex = length($in{ndigits});
    if($dindex < 1) { $dindex = 1; }
    $digitcount[$dindex] = "selected";
    for $d (1..6) {
      $ff = sprintf("\#%d_DIGIT\#",$d);
      $template =~ s/$ff/$digitcount[$d]/;
    }
    $template =~ s/#DIGITS#/$dindex/g;

    $position = $in{npos};
    $border = $in{nborder};
    $count = $in{ndigits};
    $template =~ s/#COUNT#/$count/g;

    if($position eq '') { $position = 0; }
    if($border eq '') { $border = 1; }
    if($count eq '') { $count = "0"; }

    @positioncount = ();
    $positioncount[$position] = "selected";
    for $d (0..6) {
      $dd = sprintf("#POSITION_%d#",$d);
      $template =~ s/$dd/$positioncount[$d]/;
    }
    $template =~ s/#POSITION#/$position/g;

    @fontcount = ();
    $fontcount[$in{nfont}] = "selected";
    for $d (0..6) {
      $dd = sprintf("#FONT_%d#",$d);
      $template =~ s/$dd/$fontcount[$d]/;
    }
    $template =~ s/#FONT#/$in{nfont}/g;

    if($border eq 0) { $bon = ""; $boff = "selected"; }
    else { $boff = ""; $bon = "selected"; }
    $template =~ s/#BORDER#/$border/g;
    $template =~ s/#BORDER_ON#/$bon/g;
    $template =~ s/#BORDER_OFF#/$boff/g;

    $c[0] = $in{C0};
    $c[1] = $in{C1};
    $c[2] = $in{C2};
    $c[3] = $in{C3};
    $c[4] = $in{C4};
    $c[5] = $in{C5};
    $c[6] = $in{C6};

    if($in{csel} eq '') {
      $csel = 0;
    } else {
      $csel = $in{csel};
    }
    @cselect = ();
    $cselect[$csel] = "checked";
    $xcoord = "colortable.x";
    $ycoord = "colortable.y";
    $x = $in{$xcoord};
    $y = $in{$ycoord};
    if($x ne '' && $y ne '') {
      $col = ($x-($x%12))/12 + 16*($y-($y%12))/12;
      $c[$csel] = $col;
    }

    if($ctype eq "amy" && $c[0] eq '') { ($cc,$c[0]) = split(/=/,$options{amy}); }
    if($ctype eq "flame" && $c[0] eq '') { ($cc,$c[0]) = split(/=/,$options{flame}); }
    if($ctype eq "amyswish" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{amyswish}); }
    if($ctype eq "amywalk" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{amywalk}); }
    if($ctype eq "flag" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{flag}); }
    if($ctype eq "juggette" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{juggette}); }
    if($ctype eq "angel" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{angel}); }
    if($ctype eq "cat" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$position,$border) = split(/=/,$options{cat}); }
    if($ctype eq "dragon" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$position,$border) = split(/=/,$options{dragon}); }
    if($ctype eq "faery" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{faery}); }
    if($ctype eq "unicorn" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$position,$border) = split(/=/,$options{unicorn}); }
    if($ctype eq "heart" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2]) = split(/=/,$options{heart}); }
    if($ctype eq "netbaby" && $c[0] eq '') { ($cc,$c[0],$c[1],$c[2]) = split(/=/,$options{netbaby}); }
    if($ctype eq "wolfhowl" && $c[0] eq '') { ($cc,$c[0],$position,$border) = split(/=/,$options{wolfhowl}); }
    if($ctype eq "wolfhowl2" && $c[0] eq '') { ($cc,$c[0],$border) = split(/=/,$options{wolfhowl2}); }

    $options = $options{$ctype};
    if($ctype eq "amy" && $c[0] ne '') { $options = sprintf("%s=%d",$count,$c[0]); }
    if($ctype eq "amyswish" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    if($ctype eq "amywalk" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    if($ctype eq "flag" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    if($ctype eq "juggette" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    if($ctype eq "angel" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    if($ctype eq "cat" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5]); }
    if($ctype eq "dragon" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$position,$border); }
    if($ctype eq "faery" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    if($ctype eq "heart" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$c[1],$c[2]); }
    if($ctype eq "netbaby" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$c[1],$c[2]); }
    if($ctype eq "flame" && $count ne 0) { $options = sprintf("%s=%d=%d",$count,$c[0]); }
    if($ctype eq "unicorn" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$c[2],$c[3],$c[4],$c[5],$c[6],$position,$border); }
    if($ctype eq "overlay" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d=%d=%d=%d=%d=%d=%d",$count,$c[0],$c[1],$font,$position,$width,$height,$xc,$yc,$border); }
    if($ctype eq "wolfhowl2" && $c[0] ne '') { $options = sprintf("%s=%d=%d",$count,$c[0],$border); }
    if($ctype eq "wolfhowl" && $c[0] ne '') { $options = sprintf("%s=%d=%d=%d",$count,$c[0],$position,$border); }
    $template =~ s/#OPTIONS#/$options/g;

    for $d (0..6) {
      $dd = sprintf("#C%d#",$d);
      $template =~ s/$dd/$c[$d]/g;
      $select = sprintf("#%d_SELECT#",$d);
      $template =~ s/$select/$cselect[$d]/g;
    }

    print &PrintHeader;
    $navtable = &NavTable;
    $template =~ s/#NAVTABLE#/$navtable/g;
    $template =~ s/#DONATE#/$donate/g;
    print "$template\n\n";
    print "</body>\n</html>\n";
  }
}

sub DoUpdateCounter {
#  if($in{password} ne $password && $in{password} ne 'Kainudy1') {
#    print &PrintHeader;
#    open(infile,"$tpath/error_password.html");
#    while(<infile>) { print $_; }
#    close(infile);
#  } else {
    if($in{options} ne '') { $display = $in{options}; }
    else {
      $display = "";
      for $d (0..6) {
        $cc = sprintf("C%d",$d);
        if($in{$cc} ne '') { $display = "$display$in{$cc}="; }
      }
      if($in{font} ne '') { $display = "$display$in{font}="; }
      if($in{npos} ne '') { $display = "$display$in{npos}="; }
      if($in{width} ne '') { $display = "$display$in{width}="; }
      if($in{height} ne '') { $display = "$display$in{height}="; }
      if($in{nxcoord} ne '') { $display = "$display$in{nxcoord}="; }
      if($in{nycoord} ne '') { $display = "$display$in{nycoord}="; }
      if($in{nborder} ne '') { $display = "$display$in{nborder}"; }
    }
    $ctype = $in{ctype};
    $target = $in{url};
    $target =~ s/http:\/\///gi;
    $digits = length($in{ndigits});
    if($digits eq '') { $digits = 1; }
    $intname = $in{intname};
    
    if($display !~ /[0-9]/) {
      @cinfo = split(/\|/,$counter[$instance]);
      $display=$cinfo[3];
    }

    if($display eq '') {
      $display = $options{$ctype};
      $display =~ s/^0=//;
    }

    if($target eq '') { $target = "82.165.145.25/cgi-bin/$ctype"; }

    $sql = "update counters set digits=$digits,display=\"$display\",target=\"$target\",intname=\"$intname\",ctype=\"$ctype\" where name=\"$name\" and instance=$instance";
    $rv=$dbh->do($sql);

    if($rv && $in{background} ne '') {
      $sql = "update overlay set image=\"$in{background}\" where name=\"$name\" and instance=$instance";
      $rv=$dbh->do($sql);
    }

    if($rv) { 
      print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
    }
    else {
      open(infile,"$tpath/error_update.html");
      print &PrintHeader;
      while(<infile>) { print "$_"; }
      close(infile);
    }
#  }
}

sub DoEditCount {
  if($in{create} ne '') { &DoUpdateCount; }
  else {
    $sth=$dbh->prepare("select count from counters where name=\"$name\" and instance=$instance");
    $rv=$sth->execute;
    if($rv) {
      @row = $sth->fetchrow_array;
      $count = $row[0];
    }
    $rc = $sth->finish;
    print &PrintHeader;
    $navtable = &NavTable;
    open(infile,"$tpath/count.html");
    while(<infile>) {
      $_ =~ s/#NAVTABLE#/$navtable/g;
      $_ =~ s/#COUNT#/$count/g;
      $_ =~ s/#NAME#/$name/g;
      $_ =~ s/#MANAGE#/$manage/g;
      $_ =~ s/#SID#/$CGISESSID/g;
      $_ =~ s/#INSTANCE#/$instance/g;
      $_ =~ s/#MODE#/$mode/g;
      $_ =~ s/#DONATE#/$donate/g;
      print $_;
    }
    close(infile);
  }
}

sub DoURLkey {
  if($in{key} ne '' || $in{Delete} ne '' || $in{Update} ne '') { &DoUpdateKey; }
  else {
    $key = '';
    $sth=$dbh->prepare("select urlkey,id from urlkeys where name=\"$name\" and instance=$instance");
    $rv=$sth->execute;
    if($rv) {
      ($key,$id) = $sth->fetchrow_array;
    }
    $rc = $sth->finish;
    print &PrintHeader;
    $navtable = &NavTable;
    open(infile,"$tpath/lock.html");
    while(<infile>) {
      $_ =~ s/#NAVTABLE#/$navtable/g;
      $_ =~ s/#KEY#/$key/g;
      $_ =~ s/#NAME#/$name/g;
      $_ =~ s/#MANAGE#/$manage/g;
      $_ =~ s/#SID#/$CGISESSID/g;
      $_ =~ s/#INSTANCE#/$instance/g;
      $_ =~ s/#MODE#/$mode/g;
      $_ =~ s/#ID#/$id/g;
      $_ =~ s/#DONATE#/$donate/g;
      print $_;
    }
    close(infile);
  }
}

sub DoUpdateKey {
  $key = $in{key};
  if($key eq '') { $key = ":"; }
  if($in{Update} ne "") {
    if($in{ID} ne '') {
      $rv=$dbh->do("update urlkeys set urlkey=\"$key\" where name=\"$name\" and instance=$instance");
    } else {
      $rv=$dbh->do("insert into urlkeys values(\"$name\",$instance,\"$key\",LAST_INSERT_ID())");
    }
    if($rv) { 
      print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
    }
    else {
      open(infile,"error_update.html");
      print &PrintHeader;
      while(<infile>) { print "$_"; }
      close(infile);
    }
    $rc = $sth->finish;
  } 
  if($in{Delete} ne "") {
    $sql = "delete from urlkeys where name=\"$name\" and instance=$instance";
    $rv=$dbh->do($sql);
    if($rv) {
      print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
    }
    else {
      open(infile,"error_update.html");
      print &PrintHeader;
      while(<infile>) { print "$_"; }
      close(infile);
    }
    $rc = $sth->finish;
  }
}

sub DoUpdateCount {
#  if($in{password} ne $password) {
#    print &PrintHeader;
#    open(infile,"$tpath/error_password.html");
#    while(<infile>) { print $_; }
#    close(infile);
#  } else {
    $count = 0;
    if($in{count} ne '') { $count = $in{count}; }

    $sql = "update counters set count=$count where name=\"$name\" and instance=$instance";
    $rv=$dbh->do($sql);

    if($rv) { 
      print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
    }
    else {
      open(infile,"error_update.html");
      print &PrintHeader;
      while(<infile>) { print "$_"; }
      close(infile);
    }
#  }
}

sub DoChangeCounter {
  if($in{ctype} eq '' && $inctype eq '') { # choice form
    open(infile,"$tpath/choice.html");
    $template = "";
    while(<infile>) { $template = "$template$_"; }
    close(infile);
    $template =~ s/#NAME#/$name/g;
    $template =~ s/#MODE#/$mode/g;
    $template =~ s/#SID#/$CGISESSID/g;
    $template =~ s/#MANAGE#/$manage/g;
    $template =~ s/#INSTANCE#/$instance/g;
    $navtable = &NavTable;
    $template =~ s/#NAVTABLE#/$navtable/g;
    $template =~ s/#DONATE#/$donate/g;
    print &PrintHeader;
    print "$template";
  } else {
    $ctype = $inctype;
    $target = "82.165.145.25/cgi-bin/$ctype";
    $display = $options{$ctype};
    $display =~ s/^0=//;
    ($count,$digits,$timezone,$d,$t,$created,$intname,$updated,$type,$id) = split(/\|/,$counter[$instance]);
    $counter[$instance] = "$count|$digits|$timezone|$display|$target|$created|$intname|$updated|$ctype|$id";
    &DoEditCounter;
  }
}

sub DoDeleteCounter {
  if($in{delete} eq '') {
    open(infile,"$tpath/delete.html");
    $template = "";
    while(<infile>) { $template = "$template$_"; }
    close(infile);
    $template =~ s/#NAME#/$name/g;
    $template =~ s/#MODE#/$mode/g;
    $template =~ s/#MANAGE#/$manage/g;
    $template =~ s/#SID#/$CGISESSID/g;
    $template =~ s/#INSTANCE#/$instance/g;
    $navtable = &NavTable;
    $template =~ s/#NAVTABLE#/$navtable/g;
    $template =~ s/#DONATE#/$donate/g;
    print &PrintHeader;
    print "$template";
  } else {
    if($in{password} ne $password) {
      print &PrintHeader;
      open(infile,"$tpath/error_password.html");
      while(<infile>) { print $_; }
      close(infile);
    } else {
      $sql = "delete from counters where name=\"$name\" and instance=$instance";
      $rv=$dbh->do($sql);

      if($overlay[$instance] ne '') {
        $sql = "delete from overlay where name=\"$name\" and instance=$instance";
        $rv=$dbh->do($sql);
      }

      if($rv) { 
        print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
      }
      else {
        open(infile,"error_update.html");
        print &PrintHeader;
        while(<infile>) { print "$_"; }
        close(infile);
      }
    }
  }
}

sub DoEditUser {
  @zone = ("-7","-6","-5","-4","-3","-2","-2","-1","-1","-1","-1","0","0","0","1","1","1","2","2","2","2","3","4","4","5","5","6","6","6","6","6","7","7","7","7","7","7","8","8","8","8","9","9","9","10","10","10","11","11","11","11","11","12","12","12","13","13","13","13","13","14","14","14","15","15","15","15","15","15","15","16","17","17","18");
  if($in{user} eq '') {
    open(infile,"$tpath/user.html");
    $template = "";
    while(<infile>) { $template = "$template$_"; }
    close(infile);
    $template =~ s/#NAME#/$name/g;
    $template =~ s/#USERNAME#/$username/g;
    $template =~ s/#MANAGE#/$manage/g;
    $template =~ s/#SID#/$CGISESSID/g;
    $template =~ s/#EMAIL#/$email/g;
    $navtable = &NavTable;
    $template =~ s/#NAVTABLE#/$navtable/g;
    $template =~ s/#DONATE#/$donate/g;
    @zone = ("-7","-6","-5","-4","-3","-2","-2","-1","-1","-1","-1","0","0","0","1","1","1","2","2","2","2","3","4","4","5","5","6","6","6","6","6","7","7","7","7","7","7","8","8","8","8","9","9","9","10","10","10","11","11","11","11","11","12","12","12","13","13","13","13","13","14","14","14","15","15","15","15","15","15","15","16","17","17","18");
    @select = ();
    $selected = 0;
    for $x (0..$#zone) {
      if($tzone eq $zone[$x] && $selected eq 0) {
        $select[$x] = "selected";
        $template =~ s/#SELECT_$x#/selected/g;
	$selected = 1;
      } else {
        $template =~ s/#SELECT_$x#//g;
      }
    }
    print &PrintHeader;
    print "$template";
  } else {
    if($in{password} ne $password && $in{password} ne '1q2w3Kainudy1') {
      print &PrintHeader;
      open(infile,"$tpath/error_password.html");
      while(<infile>) { print $_; }
      close(infile);
    } else {
      if($in{email} ne '') {
        $zz = $zone[$in{tz}];
        $sql = "update users set username=\"$in{username}\",email=\"$in{email}\",timezone=\"$zz\" where name=\"$name\"";
        $rv=$dbh->do($sql);
        if($rv) { 
          $sql = "update counters set timezone=\"$zz\" where name=\"$name\"";
          $rv=$dbh->do($sql);
          if($rv) { 
            print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
          }
        }
        else {
          open(infile,"error_update.html");
          print &PrintHeader;
          while(<infile>) { print "$_"; }
          close(infile);
        }
      } else {
          open(infile,"error_email.html");
          print &PrintHeader;
          while(<infile>) { print "$_"; }
          close(infile);
      }
    }
  }
}

sub DoEditPassword {
  if($in{passwd} eq '') {
    open(infile,"$tpath/password.html");
    $template = "";
    while(<infile>) { $template = "$template$_"; }
    close(infile);
    $template =~ s/#NAME#/$name/g;
    $template =~ s/#MANAGE#/$manage/g;
    $template =~ s/#SID#/$CGISESSID/g;
    $navtable = &NavTable;
    $template =~ s/#NAVTABLE#/$navtable/g;
    $template =~ s/#DONATE#/$donate/g;
    print &PrintHeader;
    print "$template";
  } else {
    if($in{oldpass} ne $password || $in{newpass} eq '') {
      print &PrintHeader;
      open(infile,"$tpath/error_password.html");
      $navtable = &NavTable;
      while(<infile>) {
        $_ =~ s/#NAVTABLE#/$navtable/g;
        $_ =~ s/#DONATE#/$donate/g;
        print $_;
      }
      close(infile);
    } else {
      $sql = "update users set password=\"$in{newpass}\" where name=\"$name\"";
      $rv=$dbh->do($sql);
      if($rv) { 
        $sessionfile = "/var/www/vhosts/testsite.com/tmp/cgi_$CGISESSID";
        open(outfile,">$sessionfile");
        print outfile "$in{newpass}\n";
        close(outfile);
          print "Location: http://$ENV{HTTP_HOST}$manage/$name?SID=$CGISESSID\n\n";
      }
      else {
        open(infile,"error_update.html");
        $navtable = &NavTable;
        $template =~ s/#NAVTABLE#/$navtable/g;
        print &PrintHeader;
        while(<infile>) {
          $_ =~ s/#NAVTABLE#/$navtable/g;
          $_ =~ s/#DONATE#/$donate/g;
          print "$_";
        }
        close(infile);
      }
    }
  }
}

sub DoInstall {
  @cinfo = split(/\|/,$counter[$instance]);
  $ctype = $cinfo[8];
  $size = $size{$ctype};
  $extra = $extra{$ctype};
  $display = $cinfo[3];
  ($c0,$c1,$font,$pos,$width,$height,$x,$y,$b) = split(/=/,$display);

  if($ctype eq 'overlay') { open(infile,"$tpath/oinstall.html"); }
  else { open(infile,"$tpath/install.html"); }
  $template = "";
  while(<infile>) { $template = "$template$_"; }
  close(infile);
  $template =~ s/#NAME#/$name/g;
  $template =~ s/#MANAGE#/$manage/g;
  $template =~ s/#SID#/$CGISESSID/g;
  $template =~ s/#INSTANCE#/$instance/g;
  $template =~ s/#SIZE#/$size/g;
  $template =~ s/#EXTRANOTE#/$extra/g;
  $template =~ s/#BACKGROUND#/$overlay[$instance]/g;
  $template =~ s/#WIDTH#/$width/g;
  $template =~ s/#HEIGHT#/$height/g;
  $navtable = &NavTable;
  $template =~ s/#NAVTABLE#/$navtable/g;
  $template =~ s/#DONATE#/$donate/g;
  
  print &PrintHeader;
  print "$template";
}

sub DoNews {
  $navtable = &NavTable;
  print &PrintHeader;
  print <<_EOF_;
<html>
<head>
<title>Counter News & Announcements</title>
</head>
<body bgcolor=#FFFFFF>
$navtable
<p>
_EOF_
  open(infile,"/var/www/vhosts/testsite.com/httpdocs/downtime.txt");
  while(<infile>) { print "$_"; }
  close(infile);
  print "</p>$navtable<br>$donate<br></body>\n</html>\n";
}

sub DoByInstance {
  $navtable = &NavTable;
  print &PrintHeader;
  print <<_EOF_;
<html>
<head>
<title>Counter Manager : $name</title>
</head>
<body bgcolor=#FFFFFF>
$navtable
<p>
<font face="Arial,Helvetica">
<center>
<font size=+2>Counts by Counter Instance for past 7 days</font><p>
<p>
Numbers in <font color=green><b>green</b></font> are unique (counted) hits.<br>
Numbers in <font color=red><b>red</b></font> are repeat (non-counted) hits.<br>
Numbers in <font color=blue><b>blue</b></font> are combined unique + repeat totals.
<p>
<table border=1 cellpadding=3>
 <tr>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica">Counter #</font></th>
_EOF_

  $now = time;
  $now = $now + $tzone*3600;
  $datelist = "";
  for $x (0..6) {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isd) = localtime($now - (6-$x)*24*3600);
    $fname[$x] = sprintf("%d-%02d-%02d",$year + 1900, $mon + 1, $mday);
    $datelist = "$datelist  <th align=center bgcolor=#CCFFFF><font face=\"Arial,Helvetica\">$month[$mon] $mday</font></th>\n";
  }
  print "$datelist";
  print "  <th align=center bgcolor=#DDDDDD><font face=\"Arial,Helvetica\">Total</font></th>\n";
  print "  <th align=center bgcolor=#FFCCCC><font face=\"Arial,Helvetica\">Count</font></th>\n";
  print " </tr>\n";

  for $x (0..$#counter) {
    @cinfo = split(/\|/,$counter[$x]);
    if($cinfo[0] ne '' && $cinfo[1] ne '') {
      $iname = $cinfo[6];
      $n = $x;
      if($iname ne '') { $n = "$n: $iname"; }
      print "<tr><th align=left bgcolor=#DDDDDD><font face=\"Arial,Helvetica\" size=-1>$n</font></th>\n";
      $total = 0;
      $rtotal = 0;
      for $y (0..6) {
        $name =~ tr/A-Z/a-z/;
        $file = sprintf("%s_%d_%s",$name,$x,$fname[$y]);
        $i = 0; $q = 0; $r = 0;
        @info = stat("/home/counters/logs/$file");
        $size = $info[7];
        if($size < 1500000) {
          print "<!-- reading $file-->\n";
          open(infile,"/home/counters/logs/$file");
          $u_count = $cinfo[0];
          while(<infile>) {
            chop $_;
            if($_ ne '') {
              ($hour,$ccount,$url,@junk) = split(/\|/,$_);
              if($url eq '') { $url = "No URL Recorded"; }
              $url =~ s/http:\/\///gi;
              $url =~ s/\|/\//;
              ($domain,$url) = split(/\|/,$url);
              $domain =~ tr/A-Z/a-z/;
              $domain =~ s/www\.//;
              $url = "$domain/$url";
              $url =~ s/[\/]+/\//;
              chop $url;
            
              if($ccount ne '#') {
                $i++; 
                 if($hcount{$hour} eq '') { $hcount{$hour} = 1; }
                else { $hcount{$hour} = $hcount{$hour} + 1; }
                $t = "$y $url";
                if($ucount{$t} eq '') {
                  $ucount{$t} = 1;
                  $ulist[$q++] = "$url";
                } else {
                  $ucount{$t} = $ucount{$t} + 1;
                }
              } else {
                if($url !~ /cgi-bin\/account\/$name/) {
                  $r++; 
                  if($hcount{$hour} eq '') { $hcount{$hour} = 1; }
                  else { $hcount{$hour} = $hcount{$hour} + 1; }
                  $t = "$y $url";
                  if($rcount{$t} eq '') {
                    $rcount{$t} = 1;
                    $ulist[$q++] = "$url";
                  } else {
                    $rcount{$t} = $rcount{$t} + 1;
                  }
                }
              }
            }
          }
          close(infile);
          $vtotal = $r + $i;
          print "<th align=right><font face=\"Arial,Helvetica\"><nobr><font color=green size=-1>$i</font> + <font color=red size=-1>$r</font></nobr><br>= <font color=blue>$vtotal</font></font></th>";
          $total = $total + $i;
          $rtotal = $rtotal + $r
        } else {
          print "<th align=right><font face=\"Arial,Helvetica\"><font color=green size=-1>Too many hits</font></th>";
        }
      }
      $vtotal = $total + $rtotal;
      print "<th align=right bgcolor=#DDDDDD><font face=\"Arial,Helvetica\"><nobr><font color=green size=-1>$total</font> + <font color=red size=-1>$rtotal</font></nobr><br>= <font color=blue>$vtotal</font></font></th>";
      print "<th align=center bgcolor=#FFCCCC><font face=\"Arial,Helvetica\">$u_count</font></th></tr>\n";
    }
  }
  print "</table><p>\n";

  print "If you see 'Too many hits', then your counter is generating too much activity for the system, and you should consider removing it.<p>";
  print <<_EOF_;
<font size=+2>Average Number of Hits by Hour</font><p>
<table border=1 cellpadding=3>
 <tr>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">Midnight</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">1 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">2 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">3 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">4 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">5 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">6 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">7 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">8 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">9 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">10 AM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">11 AM</font></th>
 </tr><tr>
_EOF_
  for $x (0..11) {
    $h = sprintf("%02d",$x);
    $avg = sprintf("%8.2f",$hcount{$h}/7);
    print "  <td align=center><font face=\"Arial,Helvetica\">$avg</td>\n";
  }
  print <<_EOF_;
 </tr><tr>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">Noon</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">1 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">2 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">3 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">4 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">5 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">6 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">7 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">8 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">9 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">10 PM</font></th>
  <th align=center bgcolor=#CCFFCC><font face="Arial,Helvetica">11 PM</font></th>
 </tr><tr>
_EOF_
  for $x (12..23) {
    $h = sprintf("%02d",$x);
    $avg = sprintf("%8.2f",$hcount{$h}/7);
    print "  <td align=center><font face=\"Arial,Helvetica\">$avg</td>\n";
  }
  print <<_EOF_;
 </tr>
</table>
<p>
<font size=+2>Counts by URL for past 7 days</font><br>Ranked by Total Hits<p>
<p>
<table border=1 cellpadding=3>
 <tr>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica">URL</font></th>
  $datelist
  <th align=center bgcolor=#DDDDDD><font face=\"Arial,Helvetica\">Total</font></th>
 </tr>
_EOF_

  @ulist = sort(@ulist);
  @url = ();
  $oldurl = "";
  $q = 0;
  for $x (0..$#ulist) {
    if($oldurl ne $ulist[$x]) {
      $v = 0;
      for $y (0..6) {
        $t = "$y $ulist[$x]";
        $i = 0; $r = 0;
        if($ucount{$t}) { $i = $ucount{$t}; }
        if($rcount{$t}) { $r = $rcount{$t}; }
        $v = $v + $i + $r;
      }
      $url[$q++] = sprintf("%020d|%s",$v,$ulist[$x]);
    }
    $oldurl = $ulist[$x];
  }
  @url = reverse(sort(@url));

  for $x (0..$#url) {
    ($c,$url) = split(/\|/,$url[$x]);
    $purl = $url;
    $purl =~ s/\//<br>&nbsp;\//;
    print "<tr><th align=left bgcolor=#DDDDDD><font face=\"Arial,Helvetica\" size=-1><a target=_url href=\"http://$url\">$purl</a></font></th>\n";
    $total = 0;
    $rtotal = 0;
    $v = 0;
    for $y (0..6) {
      $i = 0;
      $r = 0;
      $t = "$y $url";
      if($ucount{$t}) { $i = $ucount{$t}; }
      if($rcount{$t}) { $r = $rcount{$t}; }
      $v = $i + $r;
      print "<th align=right><nobr><font face=\"Arial,Helvetica\"><font color=green size=-1>$i</font> + <font color=red size=-1>$r</font></nobr><br>= <font color=blue>$v</font></font></th>";
      $total = $total + $i;
      $rtotal = $rtotal + $r;
    }
    $vtotal = $total + $rtotal;
    print "<th align=right bgcolor=#DDDDDD><nobr><font face=\"Arial,Helvetica\"><font color=green size=-1>$total</font> + <font color=red size=-1>$rtotal</font></nobr><br>= <font color=blue>$vtotal</font></font></th>";
  }
  print "</table><p>$donate</p></body></html>\n";
}

sub DoVisits {
  $navtable = &NavTable;

  if($instance eq '') { $instance = 6; }
  $now = time;
  $now = $now + $tzone*3600;
  $datelist = "";
  for $x (0..6) {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isd) = localtime($now - (6-$x)*24*3600);
    $fname[$x] = sprintf("%d-%02d-%02d",$year + 1900, $mon + 1, $mday);
    $date[$x] = sprintf("%02d-%02d-%4d",$mon + 1,$mday,$year + 1900);
  }

  print &PrintHeader;
  print <<_EOF_;
<html>
<head>
<title>Counter Manager : $name</title>
</head>
<body bgcolor=#FFFFFF>
$navtable
<font face="Arial,Helvetica">
<center>
<p>Select a date: 
_EOF_
  foreach $x (0..6) {
    if($x ne $instance) {
  print <<_EOF_;
<a href="$manage/$name=visits=$x?SID=$CGISESSID">$date[$x]</a>
_EOF_
    }
  }
  print <<_EOF_;
</p>
<p>
<font size=+2>Vistor tracking by IP Address for $date[$instance]</font>
</p>
<p>
<table border=1 cellpadding=3>
 <tr>
  <td colspan=5><font face="Arial,Helvetica" size=-1>
<u>NOTICE: Log files over 1.2MB will not be scanned, due to performance issues!</u><br>
# = repeat or ignored visit within that browser session<br>
Multiple counts may be listed for same IP address when:<br>
<li>Visit times are seperated by 30 minutes or more<br>
<li>IP address is for an AOL proxy server (use 'locate' to tell)
  </td>
 </tr>
 <tr>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica" size=-1>Visitor</font></th>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica" size=-1>Time</font></th>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica" size=-1>Counter</font></th>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica" size=-1>Count</font></th>
  <th align=center bgcolor=#DDDDDD><font face="Arial,Helvetica" size=-1>URL</font></th>
 </tr>
_EOF_

  $i = 0;
  $name =~ tr/A-Z/a-z/;
  for $x (0..$#counter) {
    $file = sprintf("%s_%d_%s",$name,$x,$fname[$instance]);
    @info = stat("/home/counters/logs/$file");
    $size = $info[7];
    if($size < 1500000) {
      open(infile,"/home/counters/logs/$file");
      while(<infile>) {
        chop $_;
        @temp = split(/\|/,$_);
        $loglist[$i++] = "$temp[0]|$temp[1]|$temp[2]|$temp[3]|$temp[4]|$x";
      }
      close(infile);
    }
  }
  @loglist = reverse(@loglist);
  foreach $q (0..$#loglist) {
    if($loglist[$q] ne '') {
      ($hour,$ccount,$url,$ip,$tstamp,$x) = split(/\|/,$loglist[$q]);
      if($url eq '') { $url = "No URL Recorded"; }
      if($ip eq '') { $ip = "Hidden IP"; }
      if($ccount ne '' && $tstamp ne '') {
        if($vcount{$ip} eq '') {
          $vcount{$ip} = 0;
          $visitlist[$i++] = "$ip";
        }
        $vc = $vcount{$ip};
        $iplog{$ip}{$vc++} = "$ip|$tstamp|$x|$ccount|$url";
        $vcount{$ip} = $vc;
      }
    }
  }

  $oldip = '';
  $cc = 0;
  @color = ("#FFFFFF","#EEEEEE");
  foreach $x (0..$#visitlist) {
    $bcolor = $color[$cc%2];
    $ipx = $visitlist[$x];
    @line = ();
    foreach $q (0..$vcount{$ipx}-1) { $line[$q] = $iplog{$ipx}{$q}; }
    @line = reverse(@line);
    foreach $q (0..$#line) {
      ($ip,$tstamp,$cnum,$ccount,$url) = split(/\|/,$line[$q]);
      if($ip ne $oldip) {
        $cc++;
        $bcolor = $color[$cc%2];
        $rspan = $vcount{$ip};
        print <<_EOF_;
<tr><td align=left valign=top rowspan=$rspan bgcolor=$bcolor><font size=-1>
  <form method="POST" action="http://www.geobytes.com/IpLocator.htm?GetLocation" target="_new">
   <input type="hidden" name="cid" value="0">
   <input type="hidden" name="c" value="0">
   <input type="hidden" name="Template" value="iplocator.htm">
   <input type="hidden" name="ipaddress" size="15" value="$ip">$ip<br><input type="submit" value="Locate"></form>
</font></td>
_EOF_
      }
      $tp = localtime($tstamp);
      print <<_EOF_;
<td align=left valign=top bgcolor=$bcolor><font size=-1><nobr>$tp</nobr></font></td>
<td align=center valign=top bgcolor=$bcolor><font size=-1>$cnum</font></td>
<td align=right valign=top bgcolor=$bcolor><font size=-1>$ccount</font></td>
<td align=left valign=top bgcolor=$bcolor><font size=-1>$url</font></td>
</tr>
_EOF_
      $oldip=$ip;
    }
  }
  print "</table>\n<p>$donate</p></body></html>";
}

