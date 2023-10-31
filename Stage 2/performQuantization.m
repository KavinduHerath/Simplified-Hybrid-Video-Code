function quantizedBlocks = performQuantization(dctBlocks, qualityLevel)
    [numBlocksH, numBlocksW] = size(dctBlocks);
    quantizedBlocks = cell(numBlocksH, numBlocksW);
    
    if qualityLevel == "low"
        quantizationMatrix = [16 11 10 16 24 40 51 61;
                              12 12 14 19 26 58 60 55;
                              14 13 16 24 40 57 69 56;
                              14 17 22 29 51 87 80 62;
                              18 22 37 56 68 109 103 77;
                              24 35 55 64 81 104 113 92;
                              49 64 78 87 103 121 120 101;
                              72 92 95 98 112 100 103 99];
    elseif qualityLevel == "medium"
        quantizationMatrix = [8 5 5 8 12 20 26 31;
                              6 6 7 10 13 29 30 27;
                              7 7 8 12 20 29 35 28;
                              7 9 11 15 26 44 41 32;
                              9 11 19 29 35 55 52 39;
                              12 17 26 30 38 49 56 46;
                              24 32 39 43 50 58 58 50;
                              36 46 48 50 57 50 52 50];
    elseif qualityLevel == "high"
        quantizationMatrix = [3 2 2 3 5 8 10 12;
                              2 2 3 4 5 12 12 11;
                              3 3 3 5 8 11 14 11;
                              3 3 4 6 10 17 16 12;
                              4 4 7 11 14 22 21 15;
                              5 7 11 13 16 12 23 18;
                              10 13 16 17 21 24 24 21;
                              14 18 19 20 22 20 20 20];
    elseif qualityLevel == "chrominance"
        quantizationMatrix = [17 18 24 47 99 99 99 99;
                              18 21 26 66 99 99 99 99;
                              24 26 56 99 99 99 99 99;
                              47 66 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99;
                              99 99 99 99 99 99 99 99];
    else
        error("Invalid quality level. Please choose 'low', 'medium', 'high', or 'chrominance'.");
    end
    
    for i = 1:numBlocksH
        for j = 1:numBlocksW
            dctBlock = dctBlocks{i, j};
            quantizedBlock = round(dctBlock ./ quantizationMatrix);
            quantizedBlocks{i, j} = quantizedBlock;
        end
    end
end