function side = stim_sequence(n_trials, length_ILD,bias_thres)
% % create a list of randomly generated with permutation (maximally 8 same-side trials) sound sides (left/right) with the index matching
% trial number
% :param n_trials: number of trials in a session/block
% :param length_ILD: this integer decides the sound side to be right
% :param bias_thres: if 8 (half of 6), the p(left) ~ 0.5

rng('shuffle')
side = [];
for i =1:n_trials
side=[side randperm(16,8)];
end

side(side<=bias_thres)=1;
side(side>bias_thres)=length_ILD;


side = side';
sign = side;
sign(sign==1) = -1;
sign(sign==length_ILD) = 1;

left_side = find(side==1);
right_side = find(side==length_ILD);
t_num = length(side);
t_bin = 1:10:t_num;

trans = diff(sign);
trans(trans == 2) = -2;

t_left_count = histcounts(left_side, t_bin);
t_right_count = histcounts(right_side, t_bin);

lgt_left = counts_m(sign,-1);
lgt_right = counts_m(sign,1);

r_l_trans = counts_m(trans,-2);

p = length(find(side==1))/length(side);


figure
subplot(3,2,1)
histogram(t_left_count)
ylim([0 25])
title('Number of left trials for every 10 trials')
box off
subplot(3,2,3)
histogram(lgt_left)
ylim([0 100])
title('Number of repeating left trials')
box off
subplot(3,2,5)
histogram(r_l_trans)
ylim([0 100])
title('Number of alternating trials')
box off
subplot(3,2,[2 4 6])
mymap = (1/255)*[
    204 204 204
    255 255 255];
cmap=colormap(mymap)
imagesc(side)
title('Generated trials')
L = line(ones(2),ones(2), 'LineWidth',2);               % generate line
set(L,{'color'},mat2cell(cmap,ones(1,2),3));
legend({'Left trials', 'Right trials'}, 'box','off')                 
set(gca,'XTick',[]);
box off
caption = sprintf('Stim side check (n = %d - p(L) = %d)',  length(side), p)
suptitle(caption)
end