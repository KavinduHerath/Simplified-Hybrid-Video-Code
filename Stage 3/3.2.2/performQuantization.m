function quantizedBlocks = performQuantization(dctBlocks, targetBitRate)
    [numBlocksH, numBlocksW] = size(dctBlocks);
    quantizedBlocks = cell(numBlocksH, numBlocksW);
    
    % Define the range of QP values to explore
    minQP = 1;
    maxQP = 50;
    
    bestBitRate = Inf;
    bestQP = 1;
    
    % Binary search to find the best QP value
    while minQP <= maxQP
        midQP = floor((minQP + maxQP) / 2);
        
        % Calculate the quantization matrix based on the current QP
        quantizationMatrix = calculateQuantizationMatrix(midQP);
        
        % Perform quantization for all blocks
        for i = 1:numBlocksH
            for j = 1:numBlocksW
                dctBlock = dctBlocks{i, j};
                quantizedBlock = round(dctBlock ./ quantizationMatrix);
                quantizedBlocks{i, j} = quantizedBlock;
            end
        end
        
        % Calculate the bit-rate for the quantized blocks
        bitRate = calculateBitRate(quantizedBlocks);
        
        % Check if the achieved bit-rate is closer to the target
        if abs(bitRate - targetBitRate) < abs(bestBitRate - targetBitRate)
            bestBitRate = bitRate;
            bestQP = midQP;
        end
        
        % Narrow down the search range based on the bit-rate comparison
        if bitRate > targetBitRate
            % If the achieved bit-rate is higher, search in the lower half
            maxQP = midQP - 1;
        else
            % If the achieved bit-rate is lower, search in the upper half
            minQP = midQP + 1;
        end
    end
    
    fprintf('Best QP: %d\n', bestQP);
    fprintf('Achieved Bit-rate: %.2f\n', bestBitRate);
end