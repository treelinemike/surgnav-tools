% shortcut to develop (and copy to clipboard) code to size a figure as it
% is currently displayed; figure in question must be the currently active figure
function gp
    thisPos = get(gcf,'Position');
    thisLine = sprintf('set(gcf,''Position'',[%04d %04d %04d %04d]);',thisPos);
    clipboard('copy',thisLine);
    disp(['Copied to clipboard: ' thisLine]);
end