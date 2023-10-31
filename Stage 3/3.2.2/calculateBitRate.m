function bitRate = calculateBitRate(quantizedBlocks)
    numBlocks = numel(quantizedBlocks);
    totalBits = 0;
    
    % Calculate the number of bits required to represent the quantized coefficients
    for i = 1:numBlocks
        quantizedBlock = quantizedBlocks{i};
        totalBits = totalBits + numel(quantizedBlock) * log2(max(abs(quantizedBlock(:))) + 1);
    end
    
    % Calculate the average bit-rate
    bitRate = totalBits;
end