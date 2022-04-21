% convert time string (HH:MM:SS) to integer number of seconds
function sec = time_str_to_sec(time_str)
    sec = (datenum(time_str,'HH:MM:SS')-datenum('00:00:00','HH:MM:SS'))*(24*60*60);
end