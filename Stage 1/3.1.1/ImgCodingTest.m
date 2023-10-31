clear all
close all
clc

%Read the original image
originalImage = imread('Lenna_(test_image).png');
figure(1);
imshow(originalImage);
title('Original Image');

%Convert the original image to grayscale
grayImage = rgb2gray(originalImage);
figure(2);
imshow(grayImage);
title('Gray Image');

%Extract 8x8 macroblocks
macroBlocks = extractMacroBlocks(grayImage);

%Perform DCT on macro blocks
dctBlocks = performDCT(macroBlocks);

%Select quantization level
qualityLevel = "high"; % Choose "low", "medium", or "high"
quantizedBlocks = performQuantization(dctBlocks, qualityLevel);

%Save the encoded data
fileName = 'E:\encodeddata.txt';
encodedData = performEntropyCoding(quantizedBlocks, fileName);

% Load the necessary data
load('E:\code_dictionary.mat', 'codeDictionaryData'); % Load the code dictionary data
fileName = 'E:\encodeddata.txt'; % File name of the encoded data
% Call the performEntropyDecoding function
decodedBlocks = performEntropyDecoding(encodedData, codeDictionaryData, fileName, qualityLevel);

% Call the performIDCT function
idctBlocks = performIDCT(decodedBlocks);

% Reconstruct the image
reconstructedImage = reconstructImage(idctBlocks);

% Display the reconstructed image
figure(3);
imshow(reconstructedImage);
title('Reconstructed Image');
PSNRValue = psnr(reconstructedImage, grayImage)

%Function to extract 8x8 macroblocks
function macroBlocks = extractMacroBlocks(imageName)
    [h, w] = size(imageName);
    numBlocksH = floor(h/8);
    numBlocksW = floor(w/8);
    macroBlocks = cell(numBlocksH, numBlocksW);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            block = imageName((i-1)*8+1 : i*8, (j-1)*8+1 : j*8);
            macroBlocks{i, j} = block;
        end
    end
end

%Function to perform DCT
function dctBlocks = performDCT(macroBlocks)
    [numBlocksH, numBlocksW] = size(macroBlocks);
    dctBlocks = cell(numBlocksH, numBlocksW);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            macroBlock = macroBlocks{i, j};
            dctBlock = dct2(macroBlock);
            dctBlocks{i, j} = dctBlock;
        end
    end
end

%Function to perform quantization based on the quality level selected
function quantizedBlocks = performQuantization(dctBlocks, qualityLevel)
    [numBlocksH, numBlocksW] = size(dctBlocks);
    quantizedBlocks = cell(numBlocksH, numBlocksW);
    
    if qualityLevel == "low"
        quantizationMatrix = [16 11 10 16 24 40 51 61;
                              12 12 14 19 26 58 60 55;
                              14 13 16 24 40 57 69 56;
                              14 17 22 29 51 87 80 62;
                              18 22 37 56 68 109 103 77;
                              24 35 55 64 81 104 113 92;
                              49 64 78 87 103 121 120 101;
                              72 92 95 98 112 100 103 99];
    elseif qualityLevel == "medium"
        quantizationMatrix = [8 5 5 8 12 20 26 31;
                              6 6 7 10 13 29 30 27;
                              7 7 8 12 20 29 35 28;
                              7 9 11 15 26 44 41 32;
                              9 11 19 29 35 55 52 39;
                              12 17 26 30 38 49 56 46;
                              24 32 39 43 50 58 58 50;
                              36 46 48 50 57 50 52 50];
    elseif qualityLevel == "high"
        quantizationMatrix = [3 2 2 3 5 8 10 12;
                              2 2 3 4 5 12 12 11;
                              3 3 3 5 8 11 14 11;
                              3 3 4 6 10 17 16 12;
                              4 4 7 11 14 22 21 15;
                              5 7 11 13 16 12 23 18;
                              10 13 16 17 21 24 24 21;
                              14 18 19 20 22 20 20 20];
    elseif qualityLevel == "chrominance"
        quantizationMatrix = [17 18 24 47 99 99 99 99;
                              18 21 26 66 99 99 99 99;
                              24 26 56 99 99 99 99 99;
                              47 66 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99];
    else
        error("Invalid quality level. Please choose 'low', 'medium', 'high', or 'chrominance'.");
    end
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            dctBlock = dctBlocks{i, j};
            quantizedBlock = round(dctBlock ./ quantizationMatrix);
            quantizedBlocks{i, j} = quantizedBlock;
        end
    end
end

%Function to encode the quantized data
function encodedData = performEntropyCoding(quantizedBlocks, fileName)
    [numBlocksH, numBlocksW] = size(quantizedBlocks);
    encodedData = cell(numBlocksH, numBlocksW);
    codeDictionaryData = cell(numBlocksH, numBlocksW); % Store code dictionary corresponding to each block
    
    fid = fopen(fileName, 'w'); % Open the text file for writing
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            quantizedBlock = quantizedBlocks{i, j};
            
            % Reshape the quantized block into a vector
            quantizedVector = quantizedBlock(:);
            
            % Generate Huffman code dictionary
            uniqueSymbols = unique(quantizedVector);
            numUniqueSymbols = numel(uniqueSymbols);
            probabilities = histcounts(quantizedVector, numUniqueSymbols) / numel(quantizedVector);
            codeDictionary = huffmandict(uniqueSymbols, probabilities);
            
            % Encode the quantized vector using Huffman coding
            encodedVector = huffmanenco(quantizedVector, codeDictionary);
            
            % Store the encoded vector and code dictionary
            encodedData{i, j} = encodedVector;
            codeDictionaryData{i, j} = codeDictionary;
            
            % Convert the encoded vector to a string format
            encodedString = num2str(encodedVector');
            
            % Write the encoded string to the text file
            fprintf(fid, '%s\n', encodedString);
        end
    end
    
    fclose(fid); % Close the text file
    
    % Save the code dictionary data to a MAT file
    save('E:\code_dictionary.mat', 'codeDictionaryData');
end

%Function to decode the encoded data
function decodedBlocks = performEntropyDecoding(encodedData, codeDictionaryData, fileName, qualityLevel)
    [numBlocksH, numBlocksW] = size(encodedData);
    decodedBlocks = cell(numBlocksH, numBlocksW);
    
    fid = fopen(fileName, 'r'); % Open the text file for reading
    
    if qualityLevel == "low"
        quantizationMatrix = [16 11 10 16 24 40 51 61;
                              12 12 14 19 26 58 60 55;
                              14 13 16 24 40 57 69 56;
                              14 17 22 29 51 87 80 62;
                              18 22 37 56 68 109 103 77;
                              24 35 55 64 81 104 113 92;
                              49 64 78 87 103 121 120 101;
                              72 92 95 98 112 100 103 99];
    elseif qualityLevel == "medium"
        quantizationMatrix = [8 5 5 8 12 20 26 31;
                              6 6 7 10 13 29 30 27;
                              7 7 8 12 20 29 35 28;
                              7 9 11 15 26 44 41 32;
                              9 11 19 29 35 55 52 39;
                              12 17 26 30 38 49 56 46;
                              24 32 39 43 50 58 58 50;
                              36 46 48 50 57 50 52 50];
    elseif qualityLevel == "high"
        quantizationMatrix = [3 2 2 3 5 8 10 12;
                              2 2 3 4 5 12 12 11;
                              3 3 3 5 8 11 14 11;
                              3 3 4 6 10 17 16 12;
                              4 4 7 11 14 22 21 15;
                              5 7 11 13 16 12 23 18;
                              10 13 16 17 21 24 24 21;
                              14 18 19 20 22 20 20 20];
    elseif qualityLevel == "chrominance"
        quantizationMatrix = [17 18 24 47 99 99 99 99;
                              18 21 26 66 99 99 99 99;
                              24 26 56 99 99 99 99 99;
                              47 66 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99];
    else
        error("Invalid quality level. Please choose 'low', 'medium', 'high', or 'chrominance'.");
    end
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            % Read the encoded string from the text file
            encodedString = fgetl(fid);
            
            % Convert the encoded string back to a numeric vector
            encodedVector = str2num(encodedString');
            
            % Retrieve the code dictionary for decoding
            codeDictionary = codeDictionaryData{i, j};
            
            % Decode the encoded vector using Huffman decoding
            quantizedVector = huffmandeco(encodedVector, codeDictionary);
            
            % Reshape the quantized vector back to the original block shape
            quantizedBlock = reshape(quantizedVector, 8, 8);
            
            % Dequantize the quantized block using the provided quantization matrix
            dctBlock = quantizedBlock .* quantizationMatrix;
            
            % Store the decoded quantized block
            decodedBlocks{i, j} = dctBlock;
        end
    end
    
    fclose(fid); % Close the text file
end

%Function to perform Inverse DCT
function idctBlocks = performIDCT(decodedBlocks)
    [numBlocksH, numBlocksW] = size(decodedBlocks);
    idctBlocks = cell(numBlocksH, numBlocksW);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            quantizedBlock = decodedBlocks{i, j};
            idctBlock = idct2(quantizedBlock);
            idctBlocks{i, j} = idctBlock;
        end
    end
end

%Function to reconstruct the image
function reconstructedImage = reconstructImage(idctBlocks)
    [numBlocksH, numBlocksW] = size(idctBlocks);
    blockSize = size(idctBlocks{1, 1}, 1);
    imageHeight = numBlocksH * blockSize;
    imageWidth = numBlocksW * blockSize;
    
    reconstructedImage = uint8(zeros(imageHeight, imageWidth));
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            idctBlock = idctBlocks{i, j};
            rowIndices = (i - 1) * blockSize + 1 : i * blockSize;
            colIndices = (j - 1) * blockSize + 1 : j * blockSize;
            reconstructedImage(rowIndices, colIndices) = idctBlock;
        end
    end
end