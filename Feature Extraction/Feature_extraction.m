clear, clc

% Load the audio signal (EOG data)
[signal, fs] = audioread('BYB_Recording_2024-10-09_10.14.36.wav');

% Define marker data from your provided file
marker_ids = [1, 2, 3, 2, 3, 2, 3, 1, 3, 2, 3, 2, 3, 1, 3, 2, 3, 2, 3, 2, 3, 2, 3];
times = [1.5847, 5.5459, 8.3192, 10.4982, 12.4788, 14.2610, 16.0441, 18.2222, 21.1931, ...
         24.1649, 25.9471, 27.9277, 29.3139, 31.8889, 41.0000, 42.7830, 44.3677, ...
         45.7539, 47.3386, 48.7248, 50.3095, 51.4973, 52.8844, 54.0723];
angles = [0, -10, 10, -20, 20, -30, 30, -40, 40, -50, 50, -70, 70, 0, 10, -10, 20, -20, 30, -30, 40, -40, 50, -50];

% Extract features using the updated function
features_table = f_feature_extraction(marker_ids, times, angles, signal, fs);

% Save the extracted features to a file (optional)
writetable(features_table, 'extracted_EOG_features.csv');

% Create a figure to display the table
figure('Name', 'Extracted Features', 'NumberTitle', 'off');
uitable('Data', table2cell(features_table), ...
        'ColumnName', features_table.Properties.VariableNames, ...
        'Position', [20 20 1000 400], ...
        'ColumnWidth', {100, 100, 100, 150, 150});

% Save the extracted features to a MAT file
save('extracted_features.mat', 'features_table')
