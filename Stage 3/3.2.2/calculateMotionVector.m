function motionVector = calculateMotionVector(prevMacroblocks, currMacroblocks)
    numBlocksH = size(currMacroblocks, 1);
    numBlocksW = size(currMacroblocks, 2);
    motionVector = zeros(numBlocksH, numBlocksW, 2);
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            % Extract the macroblock from the current frame
            currMacroblock = currMacroblocks{i, j};
            
            % Initialize variables for motion vector search
            minMSE = Inf;
            motionX = 0;
            motionY = 0;
            
            % Search for the best match in the previous frame
            for m = -1:1
                for n = -1:1
                    % Calculate the motion candidate position in the previous frame
                    candidateI = i + motionX + m;
                    candidateJ = j + motionY + n;
                    
                    % Ensure the candidate position is within the macroblock grid
                    if candidateI >= 1 && candidateI <= numBlocksH && ...
                            candidateJ >= 1 && candidateJ <= numBlocksW
                        % Extract the macroblock from the previous frame
                        prevMacroblock = prevMacroblocks{candidateI, candidateJ};
                        
                        % Calculate the mean squared error (MSE) between the macroblocks
                        mse = mean((currMacroblock(:) - prevMacroblock(:)).^2);
                        
                        % Update the motion vector if the MSE is smaller
                        if mse < minMSE
                            minMSE = mse;
                            motionX = motionX + m;
                            motionY = motionY + n;
                        end
                    end
                end
            end
        end
    end
    motionVector(i, j, 1) = motionX;
    motionVector(i, j, 2) = motionY;
end