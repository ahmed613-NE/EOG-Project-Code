close all, clear, clc



% Step 1: Load the audio data
[audioData, fs] = audioread('wav file goes here');

% Step 2: Load the event data
eventData = readtable('txt file goes here', 'Delimiter', ',', 'ReadVariableNames', false);
eventTimes = eventData.Var2; % Extract event times
eventIDs = eventData.Var1;   % Extract event IDs


% Step 3: Plot the audio signal
timeAxis = (0:length(audioData)-1) / fs; % Time axis for the audio data
figure;
plot(timeAxis, audioData);
xlabel('Time (s)');
ylabel('Amplitude');
title('Audio Signal with Event Markers');
hold on;

% Step 4: Overlay event markers
for i = 1:length(eventTimes)
    % Plot each event with a different color or marker
    if eventIDs(i) == 1
        plot(eventTimes(i), 0, 'ro', 'MarkerSize', 8, 'DisplayName', 'Event 1');
    elseif eventIDs(i) == 2
        plot(eventTimes(i), 0, 'bo', 'MarkerSize', 8, 'DisplayName', 'Event 2');
    end
end

legend('show');
hold off;



%% Event-Centered Analysis 


% Parameters
window = 0.5; % Time window around each event in seconds
numEvents = length(eventTimes);

% Define the number of rows and columns for the grid
rows = 4; % Number of rows per figure
cols = 3; % Number of columns per figure
segmentsPerFigure = rows * cols;

% Create figures based on the number of events
numFigures = ceil(numEvents / segmentsPerFigure);
for figIdx = 1:numFigures
    figure;
    sgtitle(['Audio Segments around Events - Figure ' num2str(figIdx)]);
    
    % Determine the range of events to plot in this figure
    startIdx = (figIdx - 1) * segmentsPerFigure + 1;
    endIdx = min(figIdx * segmentsPerFigure, numEvents);
    
    for i = startIdx:endIdx
        subplot(rows, cols, i - startIdx + 1);
        
        % Determine start and end times for each segment
        startTime = max(eventTimes(i) - window, 0);
        endTime = min(eventTimes(i) + window, timeAxis(end));
        segmentIdx = round([startTime, endTime] * fs);
        audioSegment = audioData(segmentIdx(1):segmentIdx(2));
        segmentTimeAxis = (segmentIdx(1):segmentIdx(2)) / fs;

        % Plot the segment
        plot(segmentTimeAxis, audioSegment);
        xlabel('Time (s)');
        ylabel('Amplitude');
        title(['Event ' num2str(eventIDs(i))]);
    end
    

end









%% Calculate the power of the audio signal
% windowLength = 1024; % Example window length
% audioPower = movmean(audioData.^2, windowLength);
% 
% figure;
% plot(timeAxis, audioPower);
% xlabel('Time (s)');
% ylabel('Power');
% title('Audio Signal Power with Event Markers');
% hold on;
% 
% % Overlay events again for context
% for i = 1:length(eventTimes)
%     plot(eventTimes(i), max(audioPower), 'ro', 'MarkerSize', 8);
% end
% hold off;

  


