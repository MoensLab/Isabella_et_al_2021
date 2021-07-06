T = cell2table(cell(0,3), 'VariableName', {'File', 'Green Midpoint', 'Red Midpoint'})


n = size(AllData)
n = n(1)
for i=1:n
    x = AllData{i,1}

    for k=1:height(x)
        if x{k,2} < 0.5
            ;
        else
            green_midpoint = x{k,1}
            break
        end
    end

    for k=1:height(x)
        if x{k,3} <0.5
            ;
        else
            red_midpoint = x{k,1}
            break
        end
               
    end
    
    filename = lsmfile(n).name
    C1 = {lsmfile(i).name, green_midpoint, red_midpoint} %%just have to figure out how to put the file name here.
    T1 = cell2table(C1,'VariableName', {'File', 'Green Midpoint', 'Red Midpoint'})
    T = vertcat(T, T1)
end

writetable(T, 'midpoint_summary.xlsx')
        