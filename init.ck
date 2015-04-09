// INIT CLASS FOR MARKOV CHAIN
// November 19, 2014 
// Bruce Dawson, CalArts MTIID


//add classes
me.dir() + "/BPM.ck" => string BPMPath; 
Machine.add(BPMPath);

me.dir() + "/osc_recv_markov.ck" => string oscRecvPath;
Machine.add(oscRecvPath);

