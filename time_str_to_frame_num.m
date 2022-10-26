% CONVERT HH:MM:SS to frame number (dropcode)
function frame_num = time_str_to_frame_num(time_str,fps)
sec = time_str_to_sec(time_str);
whole_mins = floor(sec/60);
whole_10_mins = floor(sec/(60*10));

if(abs(fps-(30/1.001)) < 0.01)
    frame_num = uint32(30*sec -2*(whole_mins-whole_10_mins));
elseif(abs(fps-(60/1.001)) < 0.01)
    frame_num = uint32(60*sec -4*(whole_mins-whole_10_mins));
else
    error('Invlaid framerate!');
end