function blocks=getBlocks(state,tag)
sLen = length(state);
d1 = state*0;
idx = (state==tag);
d1(2:end) = idx(2:end) - idx(1:end-1);
idx1 = find(d1==1);
idx2 = find(d1 == -1);
idx0 = find(d1 ~= 0);

%one block for the whole
if length(find(idx))==length(state)
    blocks=[1,1,length(state),length(state)];
    return;
end

%no blocks
if isempty(idx0) || isempty(idx1) || isempty(idx2)
    blocks = [];
	return;
end

if idx0(1) == idx2(1)
	idx1 = [1;idx1];
end

if idx0(end) == idx1(end)
	idx2 = [idx2;sLen];
end

elen = max(length(idx1), length(idx2));
blocks = zeros(elen, 4);
blocks(:,1) = (1:elen)';
blocks(:,2) = idx1';
blocks(:,3) = idx2';
blocks(:,4) = blocks(:,3) - blocks(:,2);