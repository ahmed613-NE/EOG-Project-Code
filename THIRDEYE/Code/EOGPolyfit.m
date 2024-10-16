close all, clear, clc
mainpath = 'C:\Users\74147\OneDrive\Documents\MATLAB\EOG-Project-Code-main\Data\EOG_Recording\';
addpath(mainpath);
addpath('C:\Users\74147\OneDrive\Documents\MATLAB\EOG-Project-Code-main\THIRDEYE\Code');
% addpath('C:\Users\74147\OneDrive\Documents\BYB\')
NumFile = 7;
LinedupResultSum = [];
%%
for i = 1:NumFile
 Document = i;% 3 is the best data we have for now
switch Document
    
    case 1 
EOGFilename= [mainpath 'BYB_Recording_2024-10-09_10.22.55.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-09_10.22.55-events.txt'];
Angles = [0 -10 10 -20 20 -30 30 -40 40 -50 50 10 -10 20 -20 30 -30 40 -40 50 -50];

    case 2
EOGFilename= [mainpath 'BYB_Recording_2024-10-09_10.14.36.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-09_10.14.36-events.txt'];
Angles = [0 -10 10 -20 20 -30 30 -40 40 -50 50 10 -10 20 -20 30 -30 40 -40 50 -50];

    case 3 
EOGFilename= [mainpath 'BYB_Recording_2024-10-09_10.40.23.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-09_10.40.23-events.txt'];
Angles = [0 -10 10 -20 20 -30 30 -40 40 -50 50 10 -10 20 -20 30 -30 40 -40 50 -50];

    case 4 
EOGFilename= [mainpath 'BYB_Recording_2024-10-09_10.44.30.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-09_10.44.30-events.txt'];
Angles = [0 -10 10 -20 20 -30 30 -40 40 -50 50 10 -10 20 -20 30 -30 40 -40 50 -50];
    case 5 
        EOGFilename= [mainpath 'BYB_Recording_2024-10-12_16.06.22_S10.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-12_16.06.22-events_S10.txt'];
Angles = '';
    case 6 
        EOGFilename= [mainpath 'BYB_Recording_2024-10-12_16.16.08_S20.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-12_16.16.08-events_S20.txt'];
Angles = '';
    case 7 
        EOGFilename= [mainpath 'BYB_Recording_2024-10-12_16.18.52_S30.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-12_16.18.52-events_S30.txt'];
Angles = '';
end
close all;
Events = AngleLiner(LabelFilename,Angles);

[EOGsignal, fs]= audioread(EOGFilename);
%% Downsample
Downsamplefactor = 130;
DSEOGsignal = downsample(EOGsignal,Downsamplefactor); % fs = 10000 Hz downsample by 100 time so 
% Normalization
DSEOGsignal = normalize(DSEOGsignal);
DSTime = [0+Downsamplefactor/fs:Downsamplefactor/fs:Downsamplefactor/fs*length(DSEOGsignal)];
Time = [0+1/fs:1/fs:1/fs*length(EOGsignal)];
figure;
s1= subplot(2,1,1);
plot(DSTime,DSEOGsignal);
xlabel('Time (s)')
ylabel('EOG signal (Unit tmd)')
title('Down Sampled Version (100 Hz)')
s2 = subplot(2,1,2);
plot(Time,EOGsignal);
xlabel('Time (s)')
ylabel('EOG signal (Unit tmd)')
title('Original Signal (10000 Hz)')
linkaxes([s1,s2])
disp('Downsampling to 100 Hz looks fine,(Filtered from 9 to 22 so twice the Nyquist Frequency)')
%%
% Step 3: Plot the audio signal
eventTimes = Events(:,2);
eventIDs = Events(:,1);
EyeAngle = Events(:,3);
timeAxis = DSTime; % Time axis for the audio data
figure;
plot(timeAxis, DSEOGsignal);
xlabel('Time (s)');
ylabel('Amplitude');
title('Audio Signal with Event Markers');
hold on;

% Step 4: Overlay event markers
for i = 1:length(eventTimes)
    % Plot each event with a different color or marker
    if eventIDs(i) == 1
        plot(eventTimes(i), 0.1/2, 'k*', 'MarkerSize', 12, 'DisplayName', 'Event 1','MarkerFaceColor','k');
    elseif eventIDs(i) == 3
        plot(eventTimes(i), 0.1/2, 'ro', 'MarkerSize', 12, 'DisplayName', 'Event 3','MarkerFaceColor','r');
    elseif eventIDs(i) == 2
        plot(eventTimes(i), 0.1/2, 'go', 'MarkerSize', 12, 'DisplayName', 'Event 2','MarkerFaceColor','g');
    end
end

legend('EOGsignal','Center','Looking Right','Looking Left');
hold off;



%% Event-Centered Analysis 
fs = 10000;
% Parameters
window = 0.5; % Time window around each event in seconds
numEvents = length(eventTimes);
fs = fs / Downsamplefactor;

% Define the number of rows and columns for the grid
rows = 4; % Number of rows per figure
cols = 3; % Number of columns per figure
segmentsPerFigure = rows * cols;

% Create figures based on the number of events
numFigures = ceil(numEvents / segmentsPerFigure);
if Document <5
PeakEOGValue = zeros(1, length(eventIDs));
PeakEOGTime = zeros(1, length(eventIDs));
else
PeakEOGValue = zeros(1, length(eventIDs)*2);
PeakEOGTime = zeros(1, length(eventIDs)*2);
end


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
             % Convert start and end times to indices
        segmentIdx = round([startTime, endTime] * fs);
        
        % Ensure segmentIdx is within valid bounds
        segmentIdx(1) = max(1, segmentIdx(1));  % Ensure index is at least 1
        segmentIdx(2) = min(length(DSEOGsignal), segmentIdx(2));  % Ensure index does not exceed the signal length
        
        % Extract the EOG segment
        EOGSegment = DSEOGsignal(segmentIdx(1):segmentIdx(2));
        segmentTimeAxis = (segmentIdx(1):segmentIdx(2)) / fs;
        
        % Plot the segment
        plot(segmentTimeAxis, EOGSegment);
        xlabel('Time (s)');
        ylabel('Amplitude');
        num = eventIDs(i);
        Eventing = [{'Baseline'},{'Left Saccade'},{'Right Saccade'}];
        title([Eventing(num)]);
        
        % Find peaks based on eventID
        if eventIDs(i) == 1

            if Document<5 
            % Find median peak value and its time
            sortedSegment = sort(EOGSegment);
            medianPeakValue = median(sortedSegment);
            locs = find(EOGSegment == medianPeakValue, 1); % Find the location of the median value
            PeakEOGValue(i) = 0;
            % keyboard
            PeakEOGTime(i) = startTime;
             hold on;
        plot(PeakEOGTime(i), PeakEOGValue(i), 'ro', 'MarkerSize', 8);
            else
            % Find minimum peak value and its time
            [minPeakValue, locsmin] = min(EOGSegment);
            [maxPeakValue, locsmax] = max(EOGSegment);
            % Store the two values and their times
                idx = 2 * (i - 1) + 1; % Calculate the starting index for storing two values
                PeakEOGValue(idx:idx+1) = [minPeakValue, maxPeakValue];
                PeakEOGTime(idx:idx+1) = segmentTimeAxis([locsmin, locsmax]);
                 hold on;
        plot(PeakEOGTime(idx), PeakEOGValue(idx), 'ro', 'MarkerSize', 8);
        plot(PeakEOGTime(idx+1), PeakEOGValue(idx+1), 'bo', 'MarkerSize', 8);
            end

        elseif eventIDs(i) == 2
            % Find maximum peak value and its time
            [maxPeakValue, locs] = max(EOGSegment);
            PeakEOGValue(i) = maxPeakValue;
            PeakEOGTime(i) = segmentTimeAxis(locs);
             hold on;
        plot(PeakEOGTime(i), PeakEOGValue(i), 'ro', 'MarkerSize', 8);
       
        elseif eventIDs(i) == 3
            % Find minimum peak value and its time
            [minPeakValue, locs] = min(EOGSegment);
            PeakEOGValue(i) = minPeakValue;
            PeakEOGTime(i) = segmentTimeAxis(locs);
             hold on;
        plot(PeakEOGTime(i), PeakEOGValue(i), 'ro', 'MarkerSize', 8);
        
        end
        
        % Mark the selected peak on the plot
       
        
        hold off;
    end
end

% fs = 10000;
% Parameters
% window = 0.5; % Time window around each event in seconds
% numEvents = length(eventTimes);
% fs = fs / Downsamplefactor;
% 
% Define the number of rows and columns for the grid
% rows = 4; % Number of rows per figure
% cols = 3; % Number of columns per figure
% segmentsPerFigure = rows * cols;
% 
% Create figures based on the number of events
% numFigures = ceil(numEvents / segmentsPerFigure);
% PeakEOGValue = zeros(1, length(eventIDs));
% PeakEOGTime = zeros(1, length(eventIDs));
% 
% for figIdx = 1:numFigures
%     figure;
%     sgtitle(['Audio Segments around Events - Figure ' num2str(figIdx)]);
% 
%     Determine the range of events to plot in this figure
%     startIdx = (figIdx - 1) * segmentsPerFigure + 1;
%     endIdx = min(figIdx * segmentsPerFigure, numEvents);
% 
%     for i = startIdx:endIdx
%         subplot(rows, cols, i - startIdx + 1);
% 
%         Determine start and end times for each segment
%         startTime = max(eventTimes(i) - window, 0);
%         endTime = min(eventTimes(i) + window, timeAxis(end));
%         segmentIdx = round([startTime, endTime] * fs);
%         EOGSegment = DSEOGsignal(segmentIdx(1):segmentIdx(2));
%         segmentTimeAxis = (segmentIdx(1):segmentIdx(2)) / fs;
% 
%         Plot the segment
%         plot(segmentTimeAxis, EOGSegment);
%         xlabel('Time (s)');
%         ylabel('Amplitude');
%         title(['Event ' num2str(eventIDs(i))]);
% 
%         % Loop for manual selection with a go-back option
%         confirmed = false;
%         while ~confirmed
%             disp(['Click on the peak for Event ' num2str(eventIDs(i))]);
%             [x, y] = ginput(1);  % Let the user select the point
% 
%             % Find the closest time and amplitude to the clicked point
%             [~, closestIdx] = min(abs(segmentTimeAxis - x));
%             selectedTime = segmentTimeAxis(closestIdx);
%             selectedAmplitude = EOGSegment(closestIdx);
% 
%             % Mark the selected peak on the plot
%             hold on;
%             plot(selectedTime, selectedAmplitude, 'ro', 'MarkerSize', 8);
%             hold off;
% 
%             % Ask for confirmation
%             choice = questdlg('Are you satisfied with this selection?', ...
%                               'Confirmation', ...
%                               'Yes', 'No', 'Yes');
% 
%             if strcmp(choice, 'Yes')
%                 PeakEOGTime(i) = selectedTime;
%                 PeakEOGValue(i) = selectedAmplitude;
%                 confirmed = true;
%             else
%                 % Clear the red circle and allow the user to select again
%                 hold on;
%                 plot(selectedTime, selectedAmplitude, 'w+', 'MarkerSize', 8); % Overwrite the marker
%                 hold off;
%             end
%         end
%     end
% end

%%
% Labelandpeakdifference = Events(:,2)-PeakEOGTime';
if Document >4
Events = repmat(Events,2,1);
end
LinedupResult = [Events PeakEOGTime' PeakEOGValue'];
LinedupResultSum = [LinedupResultSum;LinedupResult];
% keyboard
end
%%
degreeofpolyfit = 3;
% keyboard
Model = polyfit(LinedupResultSum(:,5),LinedupResultSum(:,3),degreeofpolyfit)

x_fit = linspace(-10,10,10000);
y_fit = polyval(Model,x_fit);

figure;
hold on;

% Plot original data points
plot(LinedupResultSum(:,5),LinedupResultSum(:,3), 'bo', 'MarkerSize', 8, 'DisplayName', 'Original Data');

% Plot fitted polynomial curve
plot(x_fit, y_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Fitted Polynomial');

%

% Add labels and title
xlabel('EOG Signal');
ylabel('Eye Angle');
title('Polynomial Fit');
xlim([min(LinedupResult(:,5)) max(LinedupResult(:,5))])
% ylim([min(LinedupResult(:,3)) max(LinedupResult(:,3))])

% Add legend
legend('show');

hold off;






%% Calculate the power of the audio signal
% windowLength = 1024; % Example window length
% audioPower = movmean(DSEOGsignal.^2, windowLength);
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

  


