function state=detectGTCS(specDat,STDth)
delta=specDat.delta;
theta=specDat.theta;
dat1=specDat.fseiz;
dat2=dat1./delta;
dat1b=dat1(dat1<mean(dat1)+3*std(dat1));
dat2b=dat2(dat2<mean(dat2)+3*std(dat2));
%threshold - GTCS
high_fseiz=mean(dat1b)+2*STDth*std(dat1b);
high_theta=mean(theta)+1*std(theta);
mid_r=prctile(dat2,50);
state=dat1>high_fseiz & theta>high_theta & dat2>mid_r;
%add TS 
high_r=mean(dat2b)+STDth*std(dat2b);
low_delta=prctile(delta,10);
mid_fseiz=prctile(dat1,50);
state2=dat2>high_r & dat1>mid_fseiz & delta<low_delta;

state=state | state2;
%merge if interval<n-sec
state=smallsegRemove(state,10/specDat.step,0);
%remove events if shorter <1-sec
state=smallsegRemove(state,5/specDat.step,1);

%remove false positive 
egraw=abs(specDat.fEEG(2,:));
tm=specDat.fEEG(1,:);
egrawth=mean(egraw)+STDth*std(egraw);
preStep=20/specDat.step;
blk=getBlocks(state,1);
if ~isempty(blk)
    n=0;
    for i=1:size(blk,1)
        delFlag=0;
        idx=find(tm>specDat.t(blk(i,2)) & tm<specDat.t(blk(i,3)));
        maxraw=prctile(egraw(idx),99);
        if maxraw<egrawth
            delFlag=1;
        end
        if blk(i,2)>preStep
            s=dat1(blk(i,2):blk(i,3));
            c=dat1(blk(i,2)-preStep:blk(i,2)-2);
            [h,p]=ttest2(s,c);
            sm0=mean(s);
            cm0=mean(c);
            if p>0.01 && sm0<cm0*1.1
                delFlag=1;
            end
        end
        if delFlag
            state(blk(i,2):blk(i,3))=0;
            n=n+1;
        end
    end
    fprintf('Remove %d false positive events\n',n);
end