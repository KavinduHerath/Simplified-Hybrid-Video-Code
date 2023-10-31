function predictedMacroblocks = motionCompensation(prevMacroblocks, motionVector)
    numBlocksH = size(motionVector, 1);
    numBlocksW = size(motionVector, 2);
    predictedMacroblocks = cell(numBlocksH, numBlocksW);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            % Retrieve the motion vector for the current macroblock
            motionX = motionVector(i, j, 1);
            motionY = motionVector(i, j, 2);
            
            % Calculate the position of the referenced macroblock in the previous frame
            refI = i + motionX;
            refJ = j + motionY;
            
            % Ensure the referenced macroblock is within the frame boundary
            if refI >= 1 && refI <= numBlocksH && refJ >= 1 && refJ <= numBlocksW
                % Retrieve the referenced macroblock from the previous frame
                refMacroblock = prevMacroblocks{refI, refJ};
                
                % Store the referenced macroblock as the predicted macroblock
                predictedMacroblocks{i, j} = refMacroblock;
            else
                % If the referenced macroblock is outside the frame boundary, set the predicted macroblock as zero
                predictedMacroblocks{i, j} = zeros(size(prevMacroblocks{1, 1}));
            end
        end
    end
end