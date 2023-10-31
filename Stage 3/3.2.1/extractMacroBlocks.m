function macroblocks = extractMacroBlocks(imageName, macroblockSize)
    [h, w] = size(imageName);
    numBlocksH = floor(h / macroblockSize);
    numBlocksW = floor(w / macroblockSize);
    macroblocks = cell(numBlocksH, numBlocksW);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            block = imageName((i - 1) * macroblockSize + 1 : i * macroblockSize, ...
                (j - 1) * macroblockSize + 1 : j * macroblockSize);
            macroblocks{i, j} = block;
        end
    end
end