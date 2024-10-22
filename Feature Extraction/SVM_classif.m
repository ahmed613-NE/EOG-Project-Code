close all, clear, clc

% Step 0: Load the extracted features table
load('extracted_features.mat', 'features_table');

% Step 1: Add movement labels based on the Angle column
movement_labels = strings(size(features_table, 1), 1); % Initialize labels
for i = 1:size(features_table, 1)
    if features_table.Angle(i) < 0
        movement_labels(i) = "Left";
    elseif features_table.Angle(i) > 0
        movement_labels(i) = "Right";
    else
        movement_labels(i) = "Center";
    end
end
features_table.Movement = movement_labels; % Add the Movement labels to the table

% Step 2: Prepare the data for LDA
X = features_table{:, {'Duration_s', 'Velocity_deg_per_s', 'PeakAmplitude', 'Energy', ...
                       'RMS', 'ZeroCrossings', 'DominantFreq', 'LowBandPower', 'HighBandPower', ...
                       'Skewness', 'Kurtosis', 'Variance', 'Entropy'}};
Y = features_table.Movement; % Labels

% Step 3: Normalize features manually
X = normalize(X);

% Step 4: Apply LDA
lda = fitcdiscr(X, Y);  % Train LDA model

% Project data into LDA space (using the scores from predict)
[~, X_lda] = predict(lda, X);

% Step 5: Split the data for training and testing
rng(123); % Set random seed for reproducibility
cv = cvpartition(height(features_table), 'HoldOut', 0.3); 
X_train = X_lda(training(cv), :);
Y_train = Y(training(cv), :);
X_test = X_lda(test(cv), :);
Y_test = Y(test(cv), :);

% Step 6: Train an SVM classifier using fitcecoc for multi-class (no Standardize parameter)
svmModel = fitcecoc(X_train, Y_train, 'Learners', 'linear', 'Coding', 'onevsall');

% Step 7: Test the SVM classifier
Y_pred_svm = predict(svmModel, X_test);

% Step 8: Evaluate the classifier
confusion_matrix = confusionmat(Y_test, Y_pred_svm);
disp('Confusion Matrix:');
disp(confusion_matrix);

accuracy = sum(Y_pred_svm == Y_test) / length(Y_test) * 100;
disp(['Classification Accuracy: ', num2str(accuracy), '%']);



% Ensure both are of the same type (categorical)
Y_test = categorical(Y_test);
Y_pred_svm = categorical(Y_pred_svm);

% Plot Confusion Matrix
figure;
confusionchart(Y_test, Y_pred_svm);
title('Confusion Matrix of SVM Classifier');

% Normalize LDA scores for better visualization (if needed)
X_lda_norm = normalize(X_lda);

% Plot normalized LDA Projection (for 2D visualization)
figure;
gscatter(X_lda_norm(:,1), X_lda_norm(:,2), features_table.Movement, 'rgb', 'osd');
xlabel('Normalized LDA 1');
ylabel('Normalized LDA 2');
title('LDA Projection of the Data (Normalized)');
legend('Left', 'Right', 'Center');

