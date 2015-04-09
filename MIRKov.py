'''
Created on May 12, 2009
@author: Justin Bozonier

Modified on November 18, 2014
Bruce Dawson

syntax:
    >  python3 mirkov.py 'SOUND.FILETYPE' TEMPO:
    >
    >> python3 mirkov.py 'sounds/example.wav' 120.0

this program works in conjunction with chucK to analyze a soundfile (.MP3, .WAV)
with the MIR library librosa and output a midi melody to ableton live.

'''


# import pysynth
from MarkovBuilder import MarkovBuilder
from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import dispatcher
from pythonosc import osc_server
import matplotlib.pyplot as plt
import sys
import numpy as np
import librosa
import argparse
import time
import threading
import os


def init_chuck():
    # initialize chuck-side of code
    os.system("chuck init.ck")
    time.sleep(1)

init_thread = threading.Thread(target=init_chuck)
init_thread.start()

# SET UP OSC CLIENT
parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="127.0.0.1",
                    help="The ip of the OSC server")
parser.add_argument("--ClientPort", type=int, default=6449,
                    help="The port the OSC client is listening on")
parser.add_argument("--ServerPort", type=int, default=6450,
                    help="The port the OSC server is listening on")

# args = parser.parse_args()
args, unknown = parser.parse_known_args()
client = udp_client.UDPClient(args.ip, args.ClientPort)

# OSC Server
dispatcher = dispatcher.Dispatcher()
dispatcher.map("/done", print)
server = osc_server.ForkingOSCUDPServer((args.ip, args.ServerPort), dispatcher)
server_thread = threading.Thread(target=server.serve_forever)
server_thread.start()
print("Serving on {}".format(server.server_address))


# 64 is the default hop size for librosa's native 22k sampling rate.
print(str(sys.argv[0]))
print(str(sys.argv[1]))

if(sys.argv[1] is not None):
    audio_path = (str(sys.argv[1]))
else:
    print('please choose audio file to analyze')

# audio_path = (audio_string)
y, sr = librosa.load(audio_path, sr=22050)

# MIR HAPPENS HERE
S = librosa.feature.melspectrogram(y, sr=sr, n_fft=2048,
                                   hop_length=64, n_mels=128)

# Convert to log scale (dB). We'll use the peak power as reference.
log_S = librosa.logamplitude(S, ref_power=np.max)

# Make a new figure
plt.figure(figsize=(12, 4))

# Display the spectrogram on a mel scale
# sample rate and hop length parameters are used to render the time axis
librosa.display.specshow(log_S, sr=sr, hop_length=64,
                         x_axis='time', y_axis='mel')

# Put a descriptive title on the plot
plt.title('mel power spectrogram')

# draw a color bar
plt.colorbar(format='%+02.0f dB')

# Make the figure layout compact
plt.tight_layout()
# plt.show()

# HARMONIC - PERCUSSIVE SOURCE SEPERATE
# pull apart haromnic and purcussive components using effects module
y_harmonic, y_percussive = librosa.effects.hpss(y)
# What do the spectrograms look like?
# Let's make and display a mel-scaled power (energy-squared) spectrogram
# We use a small hop length of 64 here so that the frames
# line up with the beat tracker example below.
S_harmonic = librosa.feature.melspectrogram(
    y_harmonic, sr=sr, n_fft=2048, hop_length=64, n_mels=128)
S_percussive = librosa.feature.melspectrogram(
    y_percussive, sr=sr, n_fft=2048, hop_length=64, n_mels=128)

# Convert to log scale (dB). We'll use the peak power as reference.
log_Sh = librosa.logamplitude(S_harmonic, ref_power=np.max)
log_Sp = librosa.logamplitude(S_percussive, ref_power=np.max)

# Make a new figure
plt.figure(figsize=(12, 6))

plt.subplot(2, 1, 1)
# Display the spectrogram on a mel scale
librosa.display.specshow(log_Sh, y_axis='mel')

# Put a descriptive title on the plot
plt.title('mel power spectrogram (Harmonic)')

# draw a color bar
plt.colorbar(format='%+02.0f dB')

plt.subplot(2, 1, 2)
librosa.display.specshow(log_Sp, sr=sr, hop_length=64,
                         x_axis='time', y_axis='mel')

# Put a descriptive title on the plot
plt.title('mel power spectrogram (Percussive)')

# draw a color bar
plt.colorbar(format='%+02.0f dB')

# Make the figure layout compact
plt.tight_layout()

# BEAT TRACKING
# Now, let's run the beat tracker
# We'll use the percussive component for this part
tempo, beats = librosa.beat.beat_track(y=y_percussive, sr=sr, hop_length=64)
notes = librosa.frames_to_time(beats[:], sr=sr, hop_length=64)

# turn off chucK loading message via OSC
loadingMsg = osc_message_builder.OscMessageBuilder(address=("/loading"))

# TIMING WILL BE OSC VALUE SENT
loadingMsg.add_arg(1)
loadingMsg = loadingMsg.build()
client.send(loadingMsg)

# estimate tuning -- how far off from middle C
tuning = librosa.feature.estimate_tuning(y=y_harmonic, sr=sr)
print("A440 Tuning Offset: ", '{:+0.2f} cents'.format(100 * tuning))

# print('time marker of all beats: ', notes)
# print('length of all beats: ', np.shape(beats))

# Let's re-draw the spectrogram, but this time, overlay the detected beats
plt.figure(figsize=(12, 4))
librosa.display.specshow(log_Sp, sr=sr, hop_length=64,
                         x_axis='time', y_axis='mel')

# Let's draw lines with a drop shadow on the beat events
plt.vlines(beats, 0, log_Sp.shape[0], colors='k', linestyles='-', linewidth=2.5)
plt.vlines(beats, 0, log_Sp.shape[0], colors='w', linestyles='-', linewidth=1.5)
plt.axis('tight')
plt.title("tempo %.2f" % tempo)
plt.tight_layout()

# ONSET DETECTION
onset_frames = librosa.onset.onset_detect(y=y, sr=sr, hop_length=64)
onset_times = librosa.frames_to_time(onset_frames[:],
                                     sr=sr, hop_length=64, n_fft=2048)
num_of_onsets = (onset_frames.shape[0])
print("Found {:d} onsets.".format(onset_frames.shape[0]))

difference_list = []
for i in range(onset_frames.shape[0]):
    difference_list.append((onset_frames[i] - onset_frames[i-1]))
difference_list.remove(min(difference_list))

whole_note = (beats[5]-beats[1])
half_note = (whole_note/2)
quarter_note = (whole_note/4)
eighth_note = (whole_note/8)
sixteenth_note = (whole_note/16)

# compare distance between notes and send estimate to MarkovMachine
note_list = [1, 2, 4, 8, 16]
note_length = []
for i in range(len(difference_list)):
    compare = []
    whole = (whole_note - difference_list[i])
    compare.append(whole)

    half = (half_note - difference_list[i])
    compare.append(half)

    quarter = (quarter_note - difference_list[i])
    compare.append(quarter)

    eighth = (eighth_note - difference_list[i])
    compare.append(eighth)

    sixteenth = (sixteenth_note - difference_list[i])
    compare.append(sixteenth)

    # print(difference_list[i], " - COMPARE: ", compare[:])
    # print("value closest,", min(compare[:], key=abs))
    lowest = min(compare[:], key=abs)
    # print("index, ", compare.index(lowest))
    note_length.append(compare.index(lowest))

plt.figure(figsize=(12, 4))
librosa.display.specshow(log_Sp, sr=sr, hop_length=64,
                         x_axis='time', y_axis='mel')
plt.vlines(onset_frames, 0, log_Sp.shape[0], colors='k',
           linestyles='-', linewidth=2.5)
plt.vlines(onset_frames, 0, log_Sp.shape[0],
           colors='w', linestyles='-', linewidth=1.5)
plt.axis('tight')
plt.title('ONSET DETECT')
plt.tight_layout()


class MusicMatrix:
    def __init__(self):
        self._previous_note = None
        self._markov = MarkovBuilder(["a", "a#", "b", "c", "c#",
                                      "d", "d#", "e", "f", "f#", "g", "g#"])
        self._timings = MarkovBuilder([1, 2, 4, 8, 16])

    def add(self, to_note):
        """Add a path from a note to
        another note. Re-adding a path between notes
        will increase the associated weight."""
        if(self._previous_note is None):
            self._previous_note = to_note
            return
        from_note = self._previous_note
        self._markov.add(from_note[0], to_note[0])
        self._timings.add(from_note[1], to_note[1])
        self._previous_note = to_note

    def next_note(self, from_note):
        return [self._markov.next_value(from_note[0]),
                self._timings.next_value(from_note[1])]

musicLearner = MusicMatrix()

# CHROMA ANALYSIS

# transpose chroma bin output to note input for MarkovMachine
note_name = ["a", "a#", "b", "c", "c#", "d", "d#", "e", "f", "f#", "g", "g#"]
note_index = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

# We'll use a longer FFT window here to better resolve low frequencies
# We'll use the harmonic component to avoid pollution from transients
# librosa.filters.
# CHROMA IS PITCH BINS (Y), BY HOP LENGTH (X) FOR LENGTH OF Y
C = librosa.feature.chromagram(y=y_harmonic, sr=sr, n_fft=4096, hop_length=64)
# pitches, magnitudes, D = librosa.feature.ifptrack(y=y, sr=sr)
# for i in range(len(C)):
#    print("chroma, ", np.mean(C[i]))
# print("dat shape, ", np.shape(C))
# print("len ", len(y))
# print(64*4135)

# chroma strong_beats divided by onsets
last_value = 0
new_note_counter = 0

for i in range(C.shape[1]):
    for x in range(C.shape[0]):
        if(C[x, i] == 1.0):
            if(x != last_value):
                note_index[x] = note_index[x]+1
                musicLearner.add([note_name[x], note_list[note_length[x]]])
                last_value = x
                new_note_counter = new_note_counter+1

# note weight normalization
index_max = max(note_index)
for x in range(len(note_index)):
    note_index[x] = note_index[x]/index_max
    # print("Scaled! ", note_index[x])
    if (note_index[x] == 1.0):
        print("Key of file analyzed: ", note_name[int(note_index[x])])

note_divide = ((len(y)/64)/num_of_onsets)
# print(note_divide)

# Make a new figure
plt.figure(figsize=(12, 4))

# Display the chromagram: the energy in
# each chromatic pitch class as a function of time
# To make sure that the colors span the
# full range of chroma values, set vmin and vmax
librosa.display.specshow(C, sr=sr,
                         hop_length=64, x_axis='time', y_axis='chroma')

plt.title('Chromagram')
plt.colorbar()

plt.tight_layout()
# plt.show()

"""
if row row row your boat was being plugged in
directly into the musicLearner, instead we're
analyzing input from librosa and feeding that
to the learner instead:

musicLearner.add(["c", 4])
musicLearner.add(["c", 4])
musicLearner.add(["c", 4])
musicLearner.add(["d", 8])
musicLearner.add(["e", 4])
musicLearner.add(["e", 4])
musicLearner.add(["d", 8])
musicLearner.add(["e", 4])
musicLearner.add(["f", 8])
note_namemusicLearner.add(["g", 2])

musicLearner.add(["c", 8])
musicLearner.add(["c", 8])
musicLearner.add(["c", 8])

musicLearner.add(["g", 8])
musicLearner.add(["g", 8])
musicLearner.add(["g", 8])

and so forth..
"""

random_score = []
current_note = ["c", 4]

# initialize tempo and send tempo to chucK via OSC
if(tempo != 0):
    print("tempo sent (via OSC): ", int(tempo))
    msg = osc_message_builder.OscMessageBuilder(address=("/tempo"))

    # TIMING WILL BE OSC VALUE SENT
    msg.add_arg(int(tempo))
    msg = msg.build()
    client.send(msg)

    SPB = 60.0 / tempo
    whole_note = (SPB*4)
else:
    SPB = 60.0 / 125
    whole_note = (SPB*4)

plt.show()

if(tempo != 0):
    for i in range(2, 100):
        print("iteration: " + str(i) + " - " +
              current_note[0] + ", " + str(current_note[1]))

        # NOTE WILL BE OSC MESSAGE SENT
        msg = osc_message_builder.OscMessageBuilder(
            address=("/"+current_note[0]))

        # TIMING WILL BE OSC VALUE SENT
        msg.add_arg(float(current_note[1]))
        msg = msg.build()
        client.send(msg)

        current_note = musicLearner.next_note(current_note)
        random_score.append(current_note)

        time.sleep(whole_note/current_note[1])
    # time.sleep(0.5)
else:
    time.sleep(whole_note/current_note[1])

msg = osc_message_builder.OscMessageBuilder(address=("/done"))

# TIMING WILL BE OSC VALUE SENT
msg.add_arg(1)
msg = msg.build()
client.send(msg)
sys.exit()
