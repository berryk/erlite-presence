#!/usr/bin/perl -w
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON; 
use Data::Dumper;
# Need to add a hash of everyones MAC addresses, names and homeseer references
 
 my $ua = LWP::UserAgent->new();
 
 # Get all the Presence switches from Homeseer
 my $request = GET 'http://homeseer.lan/json?request=getstatus&ref=all&location1=Presence&location2=Presence';
 $request->authorization_basic('default', 'default');
    
    my $response = $ua->request($request);
    
    # Get the response
    my $hs_response = $response->content();
    
    my $status_js = decode_json $hs_response;                                                                    
    print Dumper($status_js);        
    
    my $arp = `ssh router -q /usr/sbin/arp`;
	    
    foreach my $device (@{$status_js->{Devices}}){

#     print Dumper($device); 
      
      my $name = $device->{name};
      my $value = $device->{value};
      my $mac = $device->{device_type_string};
      my $ref = $device->{ref};
      my $new_value; 
                
      if ($arp =~ /$mac/){
         print "$name is at home\n";
         $new_value = 100; 
      } else {
         print "$name is away\n";
         $new_value = 0; 
      }
                                        
      if ($new_value == $value){
         print "No change to Homeseer\n";
      } else {
         print "Updating Homeseer"; 
         my $req_string = "http://homeseer.lan/json?request=controldevicebyvalue&ref=$ref"."&value=$new_value";
         my $request = GET $req_string;
         $request->authorization_basic('default', 'default');
         
         my $response = $ua->request($request);
         print "Response:".$response->content()."\n"; 
      }
                                             
}
