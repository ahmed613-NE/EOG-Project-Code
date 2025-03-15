%
close all, clear, clc
mainpath = 'C:\Users\74147\OneDrive\Documents\MATLAB\EOG-Project-Code-main\Data\EOG_Recording\';
addpath(mainpath);
addpath('C:\Users\74147\OneDrive\Documents\MATLAB\EOG-Project-Code-main\THIRDEYE\Code');
% 
NumFile = 10;
LinedupResultSum = [];

%
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
Angles = [];

    case 3 
EOGFilename= [mainpath 'BYB_Recording_2024-10-09_10.40.23.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-09_10.40.23-events.txt'];
Angles = [];

    case 4 
EOGFilename= [mainpath 'BYB_Recording_2024-10-09_10.44.30.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-09_10.44.30-events.txt'];
Angles = [];

    case 5 
EOGFilename= [mainpath 'BYB_Recording_2024-10-18_15.32.36.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-18_15.32.36-events_S30.txt'];
Angles = '';
    
    case 6 
EOGFilename= [mainpath 'BYB_Recording_2024-10-18_15.30.54.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-18_15.30.54-events_S20.txt'];
Angles = '';
    
    case 7 
EOGFilename= [mainpath 'BYB_Recording_2024-10-18_15.29.24.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-18_15.29.24-events_S10.txt'];

Angles = '';
    case 8
EOGFilename= [mainpath 'BYB_Recording_2024-10-18_15.21.50.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-18_15.21.50-events_S30.txt'];

Angles = '';
    case 9
EOGFilename= [mainpath 'BYB_Recording_2024-10-18_15.19.26.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-18_15.19.26-events_S20.txt'];
Angles = '';
    case 10 
EOGFilename= [mainpath 'BYB_Recording_2024-10-18_15.17.44.wav'];
LabelFilename = [mainpath 'BYB_Recording_2024-10-18_15.17.44-events_S10.txt'];
Angle = '';

end

close all;

Events = AngleLiner(LabelFilename,Angles);

% keyboard
[EOGsignal, fs]= audioread(EOGFilename);
if 5< Document< 8
    EOGsignal = -EOGsignal;
end
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
linkaxes([s1,s2],'x')
disp('Downsampling to 100 Hz looks fine,(Filtered from 9 to 22 so twice the Nyquist Frequency)')
% keyboard
%%

eventTimes = Events(:,2);
eventIDs = Events(:,1);

if Document == 1 
    Events(12:19,3) = -Events(12:19,3);
end

EyeAngle = Events(:,3);
timeAxis = DSTime;

% Create figure
figure;
set(gcf, 'Units', 'inches');
set(gcf, 'Position', [1, 1, 15,3]); % 4:1 aspect ratio

% --- Left axis: EOG Signal
yyaxis left
h1 = plot(timeAxis, DSEOGsignal, 'b'); hold on;
ylabel('EMG Amplitude (N/A)');
xlabel('Time (s)');
title('EMG Signal with Event Markers');

% --- Overlay event markers on left axis
h2 = plot(eventTimes(eventIDs==1), 2*ones(sum(eventIDs==1),1), 'k.', 'MarkerSize', 12);  % Center
h3 = plot(eventTimes(eventIDs==3), 2*ones(sum(eventIDs==3),1), 'r.', 'MarkerSize', 12);  % Right
h4 = plot(eventTimes(eventIDs==2), 2*ones(sum(eventIDs==2),1), 'g.', 'MarkerSize', 12);  % Left

% --- Right axis: Eye Event Angles
yyaxis right
h5 = plot(eventTimes, EyeAngle, 'mo', 'MarkerSize', 6);
ylabel('Eye Event Angle (deg)');
ylim([-60 60]);

% --- Legend (only once!)
legend([h1 h2 h3 h4 h5], {'EOG Signal','Center','Looking Right','Looking Left','Eye Angle'}, 'Location', 'best');

% keyboard

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
% if Document <5
PeakEOGValue = zeros(1, length(eventIDs));
PeakEOGTime = zeros(1, length(eventIDs));
% else
% PeakEOGValue = zeros(1, length(eventIDs));
% PeakEOGTime = zeros(1, length(eventIDs));
% end


for figIdx = 1:numFigures
    figure;
    sgtitle(['EMG Segments around Events - Figure ' num2str(figIdx)]);
    
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
        if Document < 5
        Eventing = [{'Baseline'},{'Left Saccade'},{'Right Saccade'}];
        else
            Eventing = [{'Left Saccade'},{'Right Saccade'}];
        end

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
        %     % Find minimum peak value and its time
        %     [minPeakValue, locsmin] = min(EOGSegment);
        %     [maxPeakValue, locsmax] = max(EOGSegment);
        %     % Store the two values and their times
        %         idx = 2 * (i - 1) + 1; % Calculate the starting index for storing two values
        %         PeakEOGValue(idx:idx+1) = [minPeakValue, maxPeakValue];
        %         PeakEOGTime(idx:idx+1) = segmentTimeAxis([locsmin, locsmax]);
        %          hold on;
        % plot(PeakEOGTime(idx), PeakEOGValue(idx), 'ro', 'MarkerSize', 8);
        % plot(PeakEOGTime(idx+1), PeakEOGValue(idx+1), 'bo', 'MarkerSize', 8);
            [maxPeakValue, locs] = max(EOGSegment);
            PeakEOGValue(i) = maxPeakValue;
            PeakEOGTime(i) = segmentTimeAxis(locs);
             hold on;
            plot(PeakEOGTime(i), PeakEOGValue(i), 'ro', 'MarkerSize', 8);
            
            end

        elseif eventIDs(i) == 2
            if Document < 5
            % Find maximum peak value and its time
            [maxPeakValue, locs] = max(EOGSegment);
            PeakEOGValue(i) = maxPeakValue;
            PeakEOGTime(i) = segmentTimeAxis(locs);
             hold on;
        plot(PeakEOGTime(i), PeakEOGValue(i), 'ro', 'MarkerSize', 8);
            else 
             [minPeakValue, locs] = min(EOGSegment);
            PeakEOGValue(i) = minPeakValue;
            PeakEOGTime(i) = segmentTimeAxis(locs);
             hold on;
            plot(PeakEOGTime(i), PeakEOGValue(i), 'ro', 'MarkerSize', 8);
            end
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
    % keyboard
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
% if Document >4
% Events = repmat(Events,2,1);
% end
% keyboard
LinedupResult = [Events PeakEOGTime' PeakEOGValue'];
LinedupResultSum = [LinedupResultSum;LinedupResult];
% keyboard
end
%%

degreeofpolyfit = 7;
x = LinedupResultSum(:,5);
y = LinedupResultSum(:,3);

% Fit model
Model = polyfit(x, y, degreeofpolyfit)
y_pred = polyval(Model, x);        % predicted values at original x
x_fit = linspace(min(x), max(x), 1000);
y_fit = polyval(Model, x_fit);     % smooth curve for plotting

% --- Statistics
SS_res = sum((y - y_pred).^2);
SS_tot = sum((y - mean(y)).^2);
R_squared = 1 - SS_res/SS_tot;
RMSE = sqrt(mean((y - y_pred).^2));
n = length(x);
k = degreeofpolyfit + 1;
Adj_R_squared = 1 - (1 - R_squared)*(n - 1)/(n - k);

fprintf('R-squared: %.4f\n', R_squared);
fprintf('Adjusted R-squared: %.4f\n', Adj_R_squared);
fprintf('RMSE: %.4f\n', RMSE);

% --- Plot
figure('Units', 'inches', 'Position', [1, 1, 10, 6]);

% Subplot 1: Data + Fit
subplot(2,2,1);
plot(x, y, 'bo', 'DisplayName', 'Original Data'); hold on;
plot(x_fit, y_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Fitted Curve');
xlabel('EOG Signal');
ylabel('Eye Angle');
title('Polynomial Fit');
legend;

% Subplot 2: Residual Plot
subplot(2,2,2);
residuals = y - y_pred;
plot(x, residuals, 'ko');
yline(0, '--');
xlabel('EOG Signal');
ylabel('Residuals');
title('Residual Plot');

% Subplot 3: Histogram of Residuals
subplot(2,2,3);
histogram(residuals, 20);
xlabel('Residual');
ylabel('Frequency');
title('Residual Histogram');

% Subplot 4: Stats Summary
subplot(2,2,4);
axis off;
text(0, 0.8, sprintf('Degree of Fit: %d', degreeofpolyfit), 'FontSize', 12);
text(0, 0.6, sprintf('R-squared: %.4f', R_squared), 'FontSize', 12);
text(0, 0.5, sprintf('Adjusted R-squared: %.4f', Adj_R_squared), 'FontSize', 12);
text(0, 0.4, sprintf('RMSE: %.4f', RMSE), 'FontSize', 12);
text(0, 0.2, sprintf('Coefficients:'), 'FontSize', 12);
for i = 1:length(Model)
    text(0.05, 0.2 - i*0.1, sprintf('p%d = %.4f', length(Model)-i, Model(i)), 'FontSize', 12);
end






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

  


