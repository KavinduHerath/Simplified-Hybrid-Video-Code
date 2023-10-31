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