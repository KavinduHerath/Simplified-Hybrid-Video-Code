function quantizedBlocks = performQuantization(dctBlocks, targetBitRate)
    [numBlocksH, numBlocksW] = size(dctBlocks);
    quantizedBlocks = cell(numBlocksH, numBlocksW);
    
    % Define the range of QP values to explore
    qpRange = 1:50;
    
    bestBitRate = Inf;
    bestQP = 1;
    
    for qp = qpRange
        % Calculate the quantization matrix based on the current QP
        quantizationMatrix = calculateQuantizationMatrix(qp);
        
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
            bestQP = qp;
        end
    end
    
    fprintf('Best QP: %d\n', bestQP);
    fprintf('Achieved Bit-rate: %.2f\n', bestBitRate);
end