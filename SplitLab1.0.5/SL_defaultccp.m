global config 
if ispc   
    user = getenv('USERNAME');
    home =  getenv('USERPROFILE');
else
    user= getenv('USER');
    home= getenv('HOME');
end



%% path
ccp.RFdatapath=config.RFdatapath;



%% para
ccp.long1=0;
ccp.long2=0;
ccp.lat1=0;
ccp.lat2=0;
ccp.sampling=config.sampling;
ccp.shift=10;
ccp.makedatout= home;
ccp.depthfrom=0;
ccp.depthto=800;
ccp.depthby=0.5;

ccp.piercing=1;
ccp.piercingmoho=40;
ccp.piercing410=410;
ccp.piercing660=660;


ccp.filter=0;
ccp.order=3;
ccp.f1=0.03;
ccp.f2=2;


 


