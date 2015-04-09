/*
Created November 18, 2014
author: Bruce Dawson

MarkovMusic OSC Receiver

receive notes and timing from python
playback sounds in real-time

co-req: MarkovMusic.py

*/

// the patch
SinOsc s => blackhole;
0.0 => s.gain;

//MIDI OUT
// MIDI OUTPUT
MidiOut mout;
MidiMsg midiMsg;

// loading variables
int loadingCounter;
"Analyzing Audio." => string loadingString;
"." => string loadingPeriodString;

int note;
1 => int port;

if( !mout.open(port) )
{
    <<< "ERROR: MIDI Port did not open on port: ", port >>>;
    me.exit();
};

//BPM CLASS -- USE SCIKIT-LEARN TO FIND TEMPO AND SET AUTOMATICALLY
125 => int tempo_rate;
BPM temp;
temp.tempo(tempo_rate);

//SEND OUT BPM AS WHOLE NOTE SO YOU CAN DIVIDE BY OSC MESSAGE
(temp.quarterNote*4) => dur wholeNote;
// iteration counter
0 => int iter;
// create our OSC receiver
OscRecv oin;
// create our OSC message
OscMsg msg;
// use port 6449
6449 => oin.port;
oin.listen();
// create an address in the receiver
// oin.addAddress( "/tempo, i" );

// create an address in the receiver
oin.event( "/a, f" ) @=> OscEvent a_note;
oin.event( "/a#, f" ) @=> OscEvent aS_note;
oin.event( "/b, f" ) @=> OscEvent b_note;
oin.event( "/c, f" ) @=> OscEvent c_note;
oin.event( "/c#, f" ) @=> OscEvent cS_note;
oin.event( "/d, f" ) @=> OscEvent d_note;
oin.event( "/d#, f" ) @=> OscEvent dS_note;
oin.event( "/e, f" ) @=> OscEvent e_note;
oin.event( "/f, f" ) @=> OscEvent f_note;
oin.event( "/f#, f" ) @=> OscEvent fS_note;
oin.event( "/g, f" ) @=> OscEvent g_note;
oin.event( "/g#, f" ) @=> OscEvent gS_note;
oin.event( "/tempo, i" ) @=> OscEvent tempo_osc_in;
oin.event( "/loading, i" ) @=> OscEvent loadingOSC;

// SEND OSC OUT TO MARKOV-MUSIC-PY
// host name and port
// "localhost" => string hostname;
// 6449 => int port;

// get command line
// if( me.args() ) me.arg(0) => hostname;
// if( me.args() > 1 ) me.arg(1) => Std.atoi => port;

// send object
OscOut xmit;

// aim the transmitter
xmit.dest( "localhost", 6450 );


// infinite event loop
fun void a_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	a_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( a_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    a_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter, " (A) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    440 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(440) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(440) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);

	}
    }
}

fun void aS_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	aS_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( aS_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    aS_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter, " (A#) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    466.16 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(466.16) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(466.16) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);

	}
    }
}

fun void b_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	b_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( b_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    b_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<<"iteration #", iter, " (B) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    493.88 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(493.88) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(493.88) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	}
    }
}

fun void c_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	c_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( c_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    c_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter,  " (C) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    523.25 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(523.25) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(523.25) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	}
    }
}

fun void cS_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	cS_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( cS_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    cS_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter,  " (C#) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    523.25 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(554.37) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(554.37) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	}
    }
}

fun void d_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	d_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( d_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    d_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter, " (D) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    587.33 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(587.33) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(587.33) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	}
    }
}

fun void dS_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	dS_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( dS_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    dS_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter, " (D#) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    587.33 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(622.25) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(622.25) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	}
    }
}


fun void e_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	e_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( e_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    e_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter,  " (E) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    659.25 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(659.25) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(659.25) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	    }
    }
}

fun void f_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	f_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( f_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    f_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter,  " (F) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    698.46 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(698.46) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(698.46) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	    }
    }
}

fun void fS_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	fS_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;

	 // grab the next message from the queue. 
	 while ( fS_note.nextMsg() != 0 )
    	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    fS_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter,  " (F#) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    698.46 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(739.99) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(739.99) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	    }
    }
}

fun void g_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	g_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;


	 // grab the next message from the queue. 
	 while ( g_note.nextMsg() != 0 )
    	{ 
	     // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    g_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter, " (G) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    783.99 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(783.99) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(783.99) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	    }
    }
}

fun void gS_note_spork()
{
    while ( true )
    {
	 // wait for event to arrive
	gS_note => now;
	iter++;
	
	// end loading
	1 => loadingCounter;


	 // grab the next message from the queue. 
	 while ( gS_note.nextMsg() != 0 )
    	{ 
	     // getFloat fetches the expected float (as indicated by "f")
	    // a_note.getFloat() => buf.play;
	    gS_note.getFloat() => float timing;
	    //buf.play( timing );
	    // buf.play;
	    // print
	    <<< "iteration #", iter, " (G#) got (via OSC):", timing >>>;
	    // set play pointer to beginning
	    //0 => buf.pos;
	    
	    0.5 => s.gain;
	    783.99 => s.freq;
	    144 => midiMsg.data1; //note on
	    Math.ftom(830.61) $ int => note => midiMsg.data2;
	    Math.random2(64,127) => midiMsg.data3;
	    mout.send(midiMsg);
	    (wholeNote/timing) => now;

	    0.0 => s.gain;
	    128 => midiMsg.data1; //note on
	    Math.ftom(830.61) $ int => note => midiMsg.data2;
	    0 => midiMsg.data3;
	    mout.send(midiMsg);
	    }
    }
}

fun void tempo_in()
{
    while ( true )
    {
	// wait for event to arrive
	tempo_osc_in => now;
	// send object
	OscOut xmitLive;

	//	grab the next message from the queue. 
	while ( tempo_osc_in.nextMsg() != 0 )
	{ 
	    // getFloat fetches the expected float (as indicated by "f")
	    tempo_osc_in.getInt() => tempo_rate;
	    //print
	    temp.tempo(tempo_rate);
	    <<< "Tempo set: ", tempo_rate >>>;

	    // aim the transmitter
	    xmitLive.dest( "localhost", 9000 );

	    //send tempo as OSC message to Ableton Live
	    xmitLive.start( "/live/tempo" );
	    tempo_rate $ float => xmitLive.add;
	    xmitLive.send();
	}
    }
}

fun void loading()
{
    loadingOSC => now;
    1 => loadingCounter;
}

spork ~ a_note_spork();
spork ~ aS_note_spork();
spork ~ b_note_spork();
spork ~ c_note_spork();
spork ~ cS_note_spork();
spork ~ d_note_spork();
spork ~ dS_note_spork();
spork ~ e_note_spork();
spork ~ f_note_spork();
spork ~ fS_note_spork();
spork ~ g_note_spork();
spork ~ gS_note_spork();
spork ~ tempo_in();
spork ~ loading();

while( true ){
    while( loadingCounter != 1 ){
	for(0=>int i; i < 99; i++) <<< "\n","" >>>;
	<<< "---------- MIRKov v1.0 -----------","" >>>;
        <<< "---- Written By: Bruce Dawson ----","" >>>;
        <<< "-------- February 2015 -----------","" >>>; 
        <<< "----------------------------------","" >>>;
        <<< "---- github.com/synchronometry ---","" >>>;
        <<< "---- www.synchronometry.com ------","" >>>;
        <<< "----------------------------------","" >>>;

	<<< loadingPeriodString +=> loadingString, "" >>>;
	1::second => now;
    }
    1::day => now;
}
