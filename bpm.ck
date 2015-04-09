//bpm class

public class BPM 
{
 
 //global variables
 dur myDuration[4];
 
 //
 static dur quarterNote, eighthNote, sixteenthNote, thirtySecondNote;
 
 
 fun void tempo( float beat )
 {
  //beat is BPM
  
  //Seconds Per Beat
  60.0/ (beat) => float SPB;
  SPB::second => quarterNote;
  quarterNote*0.5 => eighthNote;
  eighthNote*0.5 => sixteenthNote;
  sixteenthNote*0.5 => thirtySecondNote;
  
  [quarterNote, eighthNote, sixteenthNote, thirtySecondNote] @=> myDuration;
     
 }
}
