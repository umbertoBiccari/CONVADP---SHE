function [data,IdxMod,nangles] = format2mat_revised(path)

fileID = fopen(path);
%%
text = fscanf(fileID,'%s');

cell = strsplit(text,'(F_32)');

minIM = strsplit(cell{2},'//');
minIM = strsplit(minIM{2},'*_r3');
minIM = str2double(minIM{1});
maxIM = strsplit(cell{3},'//');
maxIM = strsplit(maxIM{2},'*_r3');
maxIM = str2double(maxIM{1});

%%
text = strsplit(text,'}*/\\{');
text = text{end};
text = strsplit(text,'},/**/\\{');
%%
textend = strsplit(text{end},'}/**/\\}');
textend = textend{1};
text{end} = textend;
%%
ndata = length(text);

nangles = length(str2num(text{1}));
data = zeros(ndata,nangles);
for it = 1:ndata
    data(it,:) = str2num(text{it});
end

IdxMod = linspace(minIM,maxIM,ndata);
end