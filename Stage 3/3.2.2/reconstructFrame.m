function reconstructedFrame = reconstructFrame(macroblocks, macroblockSize)
    [numBlocksH, numBlocksW] = size(macroblocks);
    frameHeight = numBlocksH * macroblockSize;
    frameWidth = numBlocksW * macroblockSize;
    reconstructedFrame = zeros(frameHeight, frameWidth);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            % Calculate the position of the current macroblock in the frame
            startX = (i - 1) * macroblockSize + 1;
            startY = (j - 1) * macroblockSize + 1;
            endX = startX + macroblockSize - 1;
            endY = startY + macroblockSize - 1;
            
            % Retrieve the macroblock
            macroblock = macroblocks{i, j};
            
            % Place the macroblock in the frame
            reconstructedFrame(startX:endX, startY:endY) = macroblock;
        end
    end
end