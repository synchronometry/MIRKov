# MIRKov version 1.0
automated melody prediction using Markov Chains and the librosa MIR library.

MIRKov uses MIR features to analyze an audio source (.MP3, .WAV (16-bit), .AIFF),
and generate a MIDI melody based on the content analyzed, output over the user's local IAC Bus.
Shorter audio files yield faster results.

Note: If no IAC Drivers are initialized on the machine running MIRKov, please do so beforehand.

Example Syntax:
  $ python3 MIRKov.py 'sounds/monk.wav' 120.0
  
The above terminal command will initalize the program, and look for an audio file known as 'MONK.WAV' located in the 
/sounds/ folder contained within.
