function features_table = f_feature_extraction(marker_ids, times, angles, signal, fs)
    % Function to extract enhanced features from EOG data based on marker information
    %
    % INPUT:
    % marker_ids - Marker IDs (arbitrary)
    % times - Time (in seconds) corresponding to each marker
    % angles - Angle values (in degrees)
    % signal - The EOG signal to extract features from
    % fs - Sampling frequency of the signal
    %
    % OUTPUT:
    % features_table - A table containing extracted features for each marker
    
    % Ensure that times, angles, and marker_ids have the same length
    num_markers = min([length(marker_ids), length(times), length(angles)]);
    
    % Adjust the length of the marker data
    marker_ids = marker_ids(1:num_markers);
    times = times(1:num_markers);
    angles = angles(1:num_markers);
    
    % Initialize arrays to store features
    durations = zeros(num_markers - 1, 1);
    velocities = zeros(num_markers - 1, 1);
    peak_amplitudes = zeros(num_markers - 1, 1);
    energy = zeros(num_markers - 1, 1);
    rms_values = zeros(num_markers - 1, 1);
    zero_crossings = zeros(num_markers - 1, 1);
    dominant_freqs = zeros(num_markers - 1, 1);
    low_band_power = zeros(num_markers - 1, 1);
    high_band_power = zeros(num_markers - 1, 1);
    skewness_values = zeros(num_markers - 1, 1);
    kurtosis_values = zeros(num_markers - 1, 1);
    variance_values = zeros(num_markers - 1, 1);
    entropy_values = zeros(num_markers - 1, 1);
    
    % Extract features for each segment between markers
    for i = 1:num_markers-1
        % Duration: time difference between consecutive markers
        durations(i) = times(i+1) - times(i);
        
        % Velocity: angle change per second (degree/sec)
        velocities(i) = abs(angles(i+1) - angles(i)) / durations(i);
        
        % Peak Amplitude: max amplitude of the signal between markers
        start_idx = floor(times(i) * fs);
        end_idx = floor(times(i+1) * fs);
        
        % Check for valid index ranges
        if end_idx > length(signal)
            end_idx = length(signal);
        end
        
        segment = signal(start_idx:end_idx);
        
        % Extract Time-Domain Features
        peak_amplitudes(i) = max(abs(segment));
        energy(i) = sum(segment.^2);
        rms_values(i) = rms(segment);
        zero_crossings(i) = sum(diff(sign(segment)) ~= 0);
        
        % Extract Frequency-Domain Features
        [pxx, f] = pwelch(segment, [], [], [], fs);
        [~, max_idx] = max(pxx);
        dominant_freqs(i) = f(max_idx);
        
        % Calculate Band Power Directly
        % Low Band Power (0-4 Hz)
        low_band_idx = f >= 0 & f <= 4; 
        low_band_power(i) = sum(pxx(low_band_idx));
        
        % High Band Power (30-50 Hz)
        high_band_idx = f >= 30 & f <= 50;
        high_band_power(i) = sum(pxx(high_band_idx));
        
        % Extract Statistical Features
        skewness_values(i) = skewness(segment);
        kurtosis_values(i) = kurtosis(segment);
        variance_values(i) = var(segment);
        entropy_values(i) = wentropy(segment, 'shannon');
    end
    
    % Create a table with the extracted features
    features_table = table(marker_ids(1:end-1)', angles(1:end-1)', durations, velocities, peak_amplitudes, ...
                           energy, rms_values, zero_crossings, dominant_freqs, low_band_power, high_band_power, ...
                           skewness_values, kurtosis_values, variance_values, entropy_values, ...
                           'VariableNames', {'Marker_ID', 'Angle', 'Duration_s', 'Velocity_deg_per_s', 'PeakAmplitude', ...
                                             'Energy', 'RMS', 'ZeroCrossings', 'DominantFreq', 'LowBandPower', ...
                                             'HighBandPower', 'Skewness', 'Kurtosis', 'Variance', 'Entropy'});
    
    % Display the extracted features
    disp('Extracted Enhanced Features:');
    disp(features_table);
end
