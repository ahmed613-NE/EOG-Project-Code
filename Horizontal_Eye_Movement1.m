% Load the WAV file
[audioData, sampleRate] = audioread('C:\Users\74147\OneDrive\Documents\BYB\BYB_Recording_2024-10-01_13.44.37.wav');

% Play the audio (optional)
sound(audioData, sampleRate);

% Plot the waveform (optional)
time = (0:length(audioData)-1)/sampleRate;
plot(time, audioData);
xlabel('Time (s)');
ylabel('Amplitude');
title('Waveform of the WAV file');

