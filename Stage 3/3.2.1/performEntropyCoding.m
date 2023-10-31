function encodedData = performEntropyCoding(quantizedBlocks, fileName, frameNumber)
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
            if numUniqueSymbols == 1
                uniqueSymbols = [uniqueSymbols 1]; % Add a new element to uniqueSymbols
                numUniqueSymbols = numel(uniqueSymbols);
            end
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
    fileName = sprintf('code_dictionary_%d.mat', frameNumber);
    outputFolder = 'E:\Frames2';
    outputPath = fullfile(outputFolder, fileName);
    save(outputPath, 'codeDictionaryData');
end