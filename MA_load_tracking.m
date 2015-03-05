function [us] = MA_load_tracking(filename, tracker, subject, session)
% script to load tongue contours extracted from MySQL database
% created by Tamas Gabor CSAPO <csapot@tmit.bme.hu>
% 1st version Mar 13, 2014
% last edited Oct 6, 2014

% works with GNU sed v4.0.7 (from UnxUtils on Windows)

tic;

% AVI video: 800 x 600
if (nargin < 1)
    filename = 'MA_test_all.csv';
    tracker = 'dking';
    subject = 'speaker0001';
end


us.filename = filename;
us.tracking_method = 'Manual';  % contour tracking method
us.width = 800;                             % JPG width
us.height = 600;                            % JPG height
us.tracker = tracker;
us.subject = subject;
us.session = session;


% read extracted CSV file
% rearrange first

if (exist([filename '_' tracker '_' subject '_' session '.tmp'], 'file') == 0)
    cmd = ['tail ' filename ' -n +2 | ' ...
           'grep -v NULL | ' ...
           'grep -v -E "(speaker.+\,$)" | ' ...       
           'tr ''[\n]'' ''[@]'' | ' ...
           'sed "s/@@/ /g" | ' ...
           'tr ''[@]'' ''[\n]'' | ' ...
           'sed "s/\" /\"\n/g" | ' ...
           'tr ''[:upper:]'' ''[:lower:]'' | ' ...
           'grep ' tracker ' | ' ...           
           'grep ' subject ' | ' ...
           'grep ' session ' > ' filename '_' tracker '_' subject '_' session '.tmp'];
    system(cmd);
end

res = dir([filename '_' tracker '_' subject '_' session '.tmp']);

if (res.bytes > 0)

    fid = fopen([filename '_' tracker '_' subject '_' session '.tmp']);
    % CSV: c_id,user_name,spk_id,sess_id,img_id,coors
    data = textscan(fid,'%d%s%s%s%d%s', 'Delimiter', ',', 'BufSize', 8191);
    fclose(fid);
    % delete([filename '.tmp']);

    us.num_frames = size(data{1,1}, 1);    

    max_j = 0;

    for i = 1 : us.num_frames
        j = data{1,5}(i); % image number
        if (j > max_j)
            max_j = j;
        end
        xy = str2num(data{1,6}{i}(2:end-1));
        us.frames(j).x = xy(1:2:end);
        us.frames(j).y = xy(2:2:end);
    %     plot(us.frames(i).x, us.frames(i).y, '*');
    %     disp(['#' num2str(i, '%.4d')]);
    end

    us.num_frames = max_j;

    % empty data?
    for i = 1 : max_j
        if (isempty(us.frames(i).x))
            disp(['WARNING: ' tracker '/' subject '/#' num2str(i, '%.4d') ' missing']);
    %         us.frames(i).x = 0;
        else % only if not empty
            % sorting the data + resample
            origin_x = 400;
            origin_y = -5;
%             num_angles = 40;
            us.frames(i).y = us.height - us.frames(i).y;
            [us.frames(i).x, us.frames(i).y] = contour_sort(us.frames(i).x, us.frames(i).y, origin_x, origin_y);
%             [us.frames(i).x, us.frames(i).y] = contour_resample(us.frames(i).x, us.frames(i).y, origin_x, origin_y, num_angles);
            us.frames(i).y = us.height - us.frames(i).y;
        end

    %     
    %     % sort data by X    
    %     [~, indices] = sort([us.frames(i).x; us.frames(i).y], 2, 'ascend');
    %     us.frames(i).x = us.frames(i).x(indices(1,:));
    %     us.frames(i).y = us.frames(i).y(indices(1,:));
    %     

    end

    time = toc;

    disp(['MA_load done for ' tracker '/' subject '/' session ', loaded ' num2str(us.num_frames) ' frames in ' num2str(time) ' sec']);
    
else
    disp(['MA_load NOT DONE for ' tracker '/' subject '/' session]);
    us.frames = [];
    us.num_frames = 0;
end


