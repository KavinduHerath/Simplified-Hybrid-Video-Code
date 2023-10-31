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