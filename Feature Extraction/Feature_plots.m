close all, clear, clc

% Load the extracted features
load('extracted_features.mat');

% Plot histograms for selected features
figure;
subplot(3,2,1);
histogram(features_table.Duration_s, 20);
title('Duration (s)');
xlabel('Duration (s)');
ylabel('Frequency');

subplot(3,2,2);
histogram(features_table.Velocity_deg_per_s,20);
title('Velocity (deg/s)');
xlabel('Velocity (deg/s)');
ylabel('Frequency');

subplot(3,2,3);
histogram(features_table.PeakAmplitude,20);
title('Peak Amplitude');
xlabel('Peak Amplitude');
ylabel('Frequency');

subplot(3,2,4);
histogram(features_table.Energy,20);
title('Energy');
xlabel('Energy');
ylabel('Frequency');

subplot(3,2,5);
histogram(features_table.Entropy,20);
title('Entropy');
xlabel('Entropy');
ylabel('Frequency');

subplot(3,2,6);
histogram(features_table.DominantFreq,20);
title('Dominant Frequency');
xlabel('Dominant Frequency (Hz)');
ylabel('Frequency');

% Scatter plot of Velocity vs Peak Amplitude
figure;
scatter(features_table.Velocity_deg_per_s, features_table.PeakAmplitude);
title('Velocity vs Peak Amplitude');
xlabel('Velocity (deg/s)');
ylabel('Peak Amplitude');

% Scatter plot of Duration vs Energy
figure;
scatter(features_table.Duration_s, features_table.Energy);
title('Duration vs Energy');
xlabel('Duration (s)');
ylabel('Energy');

% Scatter plot of Entropy vs Skewness
figure;
scatter(features_table.Entropy, features_table.Skewness);
title('Entropy vs Skewness');
xlabel('Entropy');
ylabel('Skewness');
