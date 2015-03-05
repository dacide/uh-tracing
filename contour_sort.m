function [newXs, newYs] = contour_sort(Xs, Ys, origin_x, origin_y)
% convert tongue contour, resample it
% written by Tamas Gabor CSAPO <csapot@tmit.bme.hu>
% first version March 18, 2014

% shift to new origin
Xs_neworigin = Xs - origin_x;
Ys_neworigin = Ys - origin_y;

% convert to polar coordinates
[Alphas, Rs] = cart2pol(Xs_neworigin, Ys_neworigin);

% sort on polar coordinates    
[~, indices] = sort([Alphas; Rs], 2, 'ascend');
Alphas = Alphas(indices(1,:));
Rs = Rs(indices(1,:));

% convert back to cartesian coordinates
[newXs, newYs] = pol2cart(Alphas, Rs);

% convert back to original origin
newXs = newXs + origin_x;
newYs = newYs + origin_y;