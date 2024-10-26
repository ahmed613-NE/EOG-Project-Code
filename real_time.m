
clear, clc

% Set the correct COM port and baud rate for your SpikerBox
comPort = 'COM3';  % Replace with your actual COM port
baudRate = 222222;  % SpikerBox baud rate

% Set up serial communication for SpikerBox
sp = serialport(comPort, baudRate);
sp.Timeout = 5;  % Set a timeout for 5 seconds

% Predefine parameters for chunk-based reading
numSamplesPerChunk = 128;  % Number of samples per chunk
maxChunks = 1000;  % Maximum number of chunks to store in the buffer
totalSamples = numSamplesPerChunk * maxChunks;  % Total buffer size

% Preallocate a buffer to store data continuously
dataBuffer = nan(totalSamples, 1);  % Preallocate buffer with NaNs

% Initialize a counter to keep track of chunks recorded
chunkCounter = 0;

% Create a figure for real-time plotting (optional)
figure;
hPlot = plot(dataBuffer);  % Initialize plot with NaNs

% Set axis labels and title
xlabel('Sample Number');
ylabel('Voltage (V)');
title('Continuous Real-Time SpikerBox Eye Movement Signal (Centered)');

% Define a bandpass filter to capture eye movement frequencies (1 Hz to 10 Hz)
Fs = 10000;  % Sampling rate (adjust as needed)
lowCutoff = 1;  % Lower cutoff frequency for the bandpass filter
highCutoff = 10;  % Upper cutoff frequency for the bandpass filter
[b, a] = butter(4, [lowCutoff, highCutoff] / (Fs / 2), 'bandpass');  % 4th-order bandpass filter

% Start continuous recording and processing
while true
    % Read a chunk of data from SpikerBox
    rawData = read(sp, numSamplesPerChunk, 'uint8');
    
    % Convert raw data to voltage (adjust if necessary for 10-bit resolution)
    V_ref = 3.3;  % Adjust based on your reference voltage
    voltageData = (rawData / 1023) * V_ref;  % Scale raw data to voltage
    
    % Remove DC offset (re-center the signal)
    voltageDataCentered = voltageData - mean(voltageData);  % Subtract the mean

    % Apply the bandpass filter (1 Hz to 10 Hz)
    voltageDataFiltered = filtfilt(b, a, voltageDataCentered);
    
    % Apply a moving average filter to smooth the data
    windowSize = 10;  % Adjust the window size based on the signal characteristics
    voltageDataSmoothed = movmean(voltageDataFiltered, windowSize);
    
    % Update the data buffer in a rolling manner
    if chunkCounter < maxChunks
        % If buffer is not full, keep adding data
        dataBuffer((chunkCounter*numSamplesPerChunk + 1):(chunkCounter+1)*numSamplesPerChunk) = voltageDataSmoothed;
    else
        % If buffer is full, start shifting and overwriting old data
        dataBuffer(1:end-numSamplesPerChunk) = dataBuffer(numSamplesPerChunk+1:end);  % Shift old data
        dataBuffer(end-numSamplesPerChunk+1:end) = voltageDataSmoothed;  % Add new chunk at the end
    end
    
    % Update chunk counter
    chunkCounter = chunkCounter + 1;

    % Update the plot for real-time display
    set(hPlot, 'YData', dataBuffer);  % Update plot with new filtered data
    drawnow;  % Force MATLAB to update the plot immediately
    
    % Optional: Add a small pause to simulate real-time data acquisition
    pause(0.01);  % Adjust this delay based on system performance
end

% Close the serial connection when done (use if you break the loop manually)
clear sp;
