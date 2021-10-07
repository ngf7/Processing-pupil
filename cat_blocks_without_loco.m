%   This code concatenates individual blocks within an imaging session and 
%   behavioral condition, then stretches pupil signal to be temporally
%   aligned with 2P imaging frames. 

%   Also aligns running signal with 2P frames (optional)

%   Once both pass and spont files from a given date exist, all variables
%   across files will be concatenated as total file (ordered pass,spont)

mouse = input('Whats the mouse ID?');
year = input('Year?');
day = input('Day?');
cont = input('Spont or pass?');

cd(strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\',mouse,'\',num2str(year),num2str(day),'\',cont))
%cd(strcat('\\runyan-fs-01\Runyan\Noelle\PUPIL DATA\',mouse,'\',num2str(year),num2str(day),'\',cont))
%   Horizontally concatenates blocks
d = dir(strcat(mouse,'_smoothed_*_.mat'));
pupil_full = []; %concatenated pupil trace (all blocks), raw
pupil_smoothed_30 = []; %concatenated pupil trace, smoothed by median over 30 timeframes
pupil_smoothed_10 = []; %concatenated pupil trace, smoothed by median over 10 timeframes
position = [];
for i=1:length(d)
    load(d(i).name)
    pupil_full = [pupil_full corrected_areas_mm]; %change made from pupil_cat_stretched to pupil_cat_raw_smoothed_cut NF 5/3)
    pupil_smoothed_30 = [pupil_smoothed_30 pupil_smoothed30];
    pupil_smoothed_10 = [pupil_smoothed_10 pupil_smoothed10];
    position = [position the_centers_cut];
end


save_loc=strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\processed\',cont,'\',mouse);
%save_loc=strcat('\\runyan-fs-01\Runyan\Noelle\reprocessed data\',cont,'\',mouse);

presence = exist(save_loc, 'dir');

if presence==7
    save(strcat(save_loc,'\',mouse,'_', num2str(day),'.mat'),'pupil_full');
elseif presence==0
    cd(strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\processed\',cont,'\'));
    mkdir save_loc;
    movefile save_loc bt41r %%NEED TO CHANGE NAME OF MOUSE HERE BEFORE RUNNING TO MAKE SURE ITS SAVING TO RIGHT PLACE
    save(strcat(save_loc,'\',mouse,'_', num2str(day),'.mat'),'pupil_full');
end

sizedir = size(d);
blocks = (1:sizedir(1));




%%CALL FUNCTION TO ALIGN PUPIL WITH GALVO 
[pupil_no_smooth_stretched,framesperblock] = make_pupil_aligned_tseries(mouse,year,day,cont,pupil_full);%uses t-series as opposed to wavesurfer to get 2p frames - since not synching signal this is easier than going through wavesurfer
pupil_smoothed10_stretched=imresize(pupil_smoothed_10,[1,length(pupil_no_smooth_stretched)]);
pupil_smoothed30_stretched=imresize(pupil_smoothed_30,[1,length(pupil_no_smooth_stretched)]);
position_stretched = imresize(position,[1,length(pupil_no_smooth_stretched)]);



 
    if length(find(isnan(pupil_smoothed30_stretched)))>0
        nanx = isnan(pupil_smoothed30_stretched);
        t    = 1:numel(pupil_smoothed30_stretched);
        pupil_smoothed30_stretched(nanx) = interp1(t(~nanx), pupil_smoothed30_stretched(~nanx), t(nanx));
    end
    

%NORMALIZE PUPIL TO COMPARE ACROSS MICE AND DAYS 
m = mean(pupil_smoothed30_stretched);
pup_norm =(pupil_smoothed30_stretched-m)/m;






% get index of block transitions 
blockTransitions = [];
     frames=0;
    for i=1:length(framesperblock)
        frames = frames+framesperblock(1,i);
     blockTransitions(i) = frames;
    end
    


save(strcat(save_loc,'\',mouse,'_', num2str(day),'.mat'),'pupil_no_smooth_stretched','pup_norm','pupil_smoothed30_stretched','pupil_smoothed10_stretched','position_stretched','blockTransitions','-append');
%save(strcat(save_loc,'\',mouse,'_',num2str(day),'.mat'),'position','-append')
pause;

tot_file_save_loc = strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\processed\total',mouse);
%tot_file_save_loc = strcat('\\runyan-fs-01\Runyan\Noelle\reprocessed data\total',mouse);
passcd = strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\processed\pass\',mouse);
%passcd = strcat('\\runyan-fs-01\Runyan\Noelle\reprocessed data\pass\',mouse);
cd(passcd);
passTF = isfile(strcat(mouse,'_',num2str(day),'.mat'));
spontcd = strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\processed\spont\',mouse);
%spontcd = strcat('\\runyan-fs-01\Runyan\Noelle\reprocessed data\spont\',mouse);
cd(spontcd);
spontTF = isfile(strcat(mouse,'_',num2str(day),'.mat'));
if passTF==1 && spontTF==1
    load(strcat(passcd,'\',mouse,'_',num2str(day)));
    pup_pass = pupil_smoothed30_stretched;
    pup_not_smoothed_pass = pupil_no_smooth_stretched;
    position_pass = position_stretched;
    blockTransitions_pass = blockTransitions;
    
    load(strcat(spontcd,'\',mouse,'_',num2str(day)));
    pup_spont = pupil_smoothed30_stretched;
    pup_not_smoothed_spont = pupil_no_smooth_stretched;
    position_spont = position_stretched;
    blockTransitions_spont = blockTransitions;
    
    totPup=horzcat(pup_pass,pup_spont);
    totPos = horzcat(position_pass,position_spont);
    blockTransitions_spont = blockTransitions_spont+blockTransitions_pass(end);
    totBlockTransitions = horzcat(blockTransitions_pass, blockTransitions_spont);
    
    if length(find(isnan(totPup)))>0
        nanx = isnan(totPup);
        t    = 1:numel(totPup);
        totPup(nanx) = interp1(t(~nanx), totPup(~nanx), t(nanx));
    end
    
    m=mean(totPup);
    totnorm=(totPup-m)/m; 
    
    save(strcat('\\runyan-fs-01\Runyan3\Noelle\Pupil\Christine Pupil\processed\total\',mouse,'\',mouse,'_',num2str(day),'.mat'),'totPup','totnorm','totPos','totBlockTransitions')  
    %save(strcat('\\runyan-fs-01\Runyan\Noelle\reprocessed data\total\',mouse,'\',mouse,'_',num2str(day),'.mat'),'totPup','totnorm','totXvel','totYvel','totLocosummedSmooth','totLocosummed','totPos','totBlockTransitions')  
end


