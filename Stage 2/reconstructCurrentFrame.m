function reconstructedCurrentFrame = reconstructCurrentFrame(predictedMacroblocks, residualMacroblocks, macroblockSize)
    [numBlocksH, numBlocksW] = size(predictedMacroblocks);
    frameHeight = numBlocksH * macroblockSize;
    frameWidth = numBlocksW * macroblockSize;
    reconstructedCurrentFrame = zeros(frameHeight, frameWidth);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            % Calculate the position of the current macroblock in the frame
            startX = (i - 1) * macroblockSize + 1;
            startY = (j - 1) * macroblockSize + 1;
            endX = startX + macroblockSize - 1;
            endY = startY + macroblockSize - 1;
            
            % Retrieve the predicted macroblock
            predictedMacroblock = predictedMacroblocks{i, j};
            
            % Retrieve the residual macroblock
            residualMacroblock = residualMacroblocks{i, j};
            
            % Reconstruct the current macroblock by adding the predicted and residual macroblocks
            currentMacroblock = predictedMacroblock + residualMacroblock;
            
            % Assign the current macroblock to the corresponding position in the frame
            reconstructedCurrentFrame(startX:endX, startY:endY) = currentMacroblock;
        end
    end
end