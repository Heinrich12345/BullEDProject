function middleIndices = findMiddleIndices(indices)
%Finds and returns middle indicies of continuous sets of indicies.
start = 0;
middle = 0;
c=1;
if(length(indices)==1)
    middleIndices=indices;
else
    for i = 1:length(indices)-1
        if(indices(i)+1 ~= indices(i+1))
            middle=ceil((i+start)/2);
            middleIndices(c)=indices(middle);
            c=c+1;
            start=i;
            if(indices(i+1)==indices(length(indices)))
                middleIndices(c)=indices(i+1);
                c=c+1;
            end
        elseif(indices(i+1)==indices(length(indices)))
            middle=ceil((i+1+start)/2);
            middleIndices(c)=indices(middle);
            c=c+1;
        end
    end
end

