clear all
close all
clc

% Specify the path to your video file
videoFilePath = 'E:\Foreman.mp4';

% Create a VideoReader object
video = VideoReader(videoFilePath);

% Define the number of frames to extract
numFrames = 10;

% Specify the output directory
outputFolder = 'E:\Frames2';

% Extract and save the frames as grayscale images
for frameNumber = 1:numFrames
    frame = readFrame(video);
    
    % Convert the frame to grayscale
    grayFrame = rgb2gray(frame);
    
    % Create the full output file path
    imageName = sprintf('frame%d.jpg', frameNumber);
    outputPath = fullfile(outputFolder, imageName);
    
    % Save the grayscale frame as a JPEG image
    imwrite(grayFrame, outputPath, 'jpg');
end

% Specify the directory where the frames are saved
frameDirectory = 'E:\Frames2';

% Define the size of the macroblock for motion vector calculation
macroblockSize = 8;

% Initialize variables for motion vectors and predicted frames
motionVectors = cell(numFrames, 1);
predictedFrames = cell(numFrames, 1);
macroblocksPerFrame = cell(numFrames, 1);

% Access each frame
for frameNumber = 1:numFrames
    % Create the full file path for the gray frame
    imageName = sprintf('frame%d.jpg', frameNumber);
    imagePath = fullfile(frameDirectory, imageName);
    
    % Read the gray frame image
    grayFrame = imread(imagePath);
    
    % Perform operations on the gray frame (e.g., display, process, etc.)
    % imshow(grayFrame); % Example: Display the gray frame
    
    macroblocks = extractMacroBlocks(grayFrame, macroblockSize);
    % Store the macroblocks for the current frame
    macroblocksPerFrame{frameNumber} = macroblocks;
end

% Keep the first frame as the I-frame
predictedFrames{1} = macroblocksPerFrame{1};
residualFrames{1} = zeros(size(macroblocksPerFrame{1}));

% Predict the remaining frames using motion vectors and create residuals
for frameNumber = 2:numFrames
    prevMacroblocks = macroblocksPerFrame{frameNumber-1};
    motionVector = calculateMotionVector(prevMacroblocks, macroblocksPerFrame{frameNumber});
    
    % Perform motion compensation to predict the current frame
    predictedMacroblocks = motionCompensation(prevMacroblocks, motionVector);
    
    % Store the predicted macroblocks for the current frame
    predictedFrames{frameNumber} = predictedMacroblocks;
    
    % Calculate the residual frame by taking the difference between the macroblocks and predicted macroblocks
    residualFrame = cellfun(@(mb, pred) mb - pred, macroblocksPerFrame{frameNumber}, predictedMacroblocks, 'UniformOutput', false);
    
    % Store the residual frame for the current frame
    residualFrames{frameNumber} = residualFrame;
end

% Display the predicted frames with residuals
for frameNumber = 2:numFrames
    predictedMacroblocks = predictedFrames{frameNumber};
    residualMacroblocks = residualFrames{frameNumber};
    
    % Reconstruct the frame from predicted macroblocks
    predictedFrame = reconstructFrame(predictedMacroblocks, macroblockSize);
    
    % Convert grayscale pixel values to the appropriate range for display
    predictedFrame = mat2gray(predictedFrame);
    
    % Display the predicted frame
    subplot(2, numFrames, frameNumber);
    imshow(predictedFrame);
    title(sprintf('Frame %d (Predicted)', frameNumber));
    
    % Reconstruct the frame from residual macroblocks
    residualFrame = reconstructFrame(residualMacroblocks, macroblockSize);
    
    % Convert grayscale pixel values to the appropriate range for display
    residualFrame = mat2gray(residualFrame);
    
    % Display the residual frame
    subplot(2, numFrames, frameNumber+numFrames);
    imshow(residualFrame);
    title(sprintf('Frame %d (Residual)', frameNumber));
    
    % Create the full output file path
    imageName = sprintf('Predicted%d.jpg', frameNumber);
    outputPath = fullfile(outputFolder, imageName);
  
    % Save the grayscale frame as a JPEG image
    imwrite(predictedFrame, outputPath, 'jpg');
    
    % Create the full output file path
    imageName = sprintf('Residual%d.jpg', frameNumber);
    outputPath = fullfile(outputFolder, imageName);
    
    % Save the grayscale frame as a JPEG image
    imwrite(residualFrame, outputPath, 'jpg');
end

icdtFrames = cell(numFrames, 1);
icdtFrames{1} = macroblocksPerFrame{1};

for frameNumber = 2:numFrames
    predictedMacroblocks = predictedFrames{frameNumber};
    residualMacroblocks = residualFrames{frameNumber};
    
    dctBlocks = performDCT(residualMacroblocks);

    qualityLevel = "high"; % Choose "low", "medium", or "high"
    
    % Set the target bit-rate
    targetBitRate = 414000/30; % Example target bit-rate in bits per block

    % Call the performQuantization function
    quantizedBlocks = performQuantization(dctBlocks, targetBitRate);
    %quantizedBlocks = performQuantization(dctBlocks, qualityLevel);

    fileName = sprintf('encodeddata%d.txt', frameNumber);
    outputPath = fullfile(outputFolder, fileName);
    encodedData = performEntropyCoding(quantizedBlocks, outputPath, frameNumber);

    % Load the necessary data
    fileName = sprintf('code_dictionary_%d.mat', frameNumber);
    outputPath = fullfile(outputFolder, fileName);
    load(outputPath, 'codeDictionaryData'); % Load the code dictionary data
    fileName = sprintf('encodeddata%d.txt', frameNumber); % File name of the encoded data
    outputPath = fullfile(outputFolder, fileName);
    % Call the performEntropyDecoding function
    decodedBlocks = performEntropyDecoding(encodedData, codeDictionaryData, outputPath, qualityLevel);

    % Call the performIDCT function
    idctBlocks = performIDCT(decodedBlocks);
    icdtFrames{frameNumber} = idctBlocks;
end

% Reconstruct the current frames using predicted frames and residuals
for frameNumber = 2:numFrames
    predictedMacroblocks = predictedFrames{frameNumber};
    residualMacroblocks = residualFrames{frameNumber};
    
    % Reconstruct the current frame from the predicted and residual macroblocks
    currentFrame = reconstructCurrentFrame(predictedMacroblocks, residualMacroblocks, macroblockSize);
    
    % Convert grayscale pixel values to the appropriate range for display
    currentFrame = mat2gray(currentFrame);
    
    % Display the current frame
    figure;
    imshow(currentFrame);
    title(sprintf('Frame %d (Current)', frameNumber));
    
    % Create the full output file path
    imageName = sprintf('CurrentFrame%d.jpg', frameNumber);
    outputPath = fullfile(outputFolder, imageName);
  
    % Save the grayscale frame as a JPEG image
    imwrite(currentFrame, outputPath, 'jpg');
end