% fine adjustment for each case
function state=adjustState(state,step)
%connect if gap is shorter than 10sec
state=fillGap(state,10/step,0);

%deal with NREMS------------------
%remove NREM sleep period if shorter than 30sec
blocks = getBlocks(state,1);
if ~isempty(blocks)
    for i=1:length(blocks(:,1))
        if blocks(i,4)<30/step
            state(blocks(i,2):blocks(i,3)) = 0;
        end
    end
end
%return;
%deal with REMS------------------
state2=state==2;
state2=fillGap(state2,30/step,0);
state(state==2)=0;
state(state2==1)=2;
pre = floor(60/step);
blocks = getBlocks(state,2);
if isempty(blocks)
	return;
end
for i=1:length(blocks(:,1))
	if blocks(i,2) > step
        if blocks(i,4)<20/step && blocks(i,2)>1
            state(blocks(i,2):blocks(i,3)) = state(blocks(i,2)-1);
        end
        n1 = max(blocks(i,2)-pre, 1);
        %remove rem-period if no nrem in the pre-min
        if sum(state(n1:(blocks(i,2)-step))) == 0
            state(blocks(i,2):blocks(i,3)) = 0;
        end
    else
        state(blocks(i,2):blocks(i,3)) = 0;
    end
end

