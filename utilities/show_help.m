function show_help(hfile)
%Shows a txt file in a nice window, where:
%hfile is path/to/file/file.txt
fid=fopen(hfile,'rt');
text_ara=fscanf(fid,'%c',inf);
fclose(fid);
helpwin(text_ara,hfile)
end %fn