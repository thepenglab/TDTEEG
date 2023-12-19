

%to see if index is at least 3-continuous
function tag=IndexCont(x)
tag=0;
if length(x)>2
    idx=x(2:end)-x(1:end-1);
    idx2=find(idx==1); 
    if length(idx2)>3
        tag=1;
    end
end
