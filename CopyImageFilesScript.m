source = 'C:\ubuntueswin\NEWDATA\4\FonetikaUS_CSTG\';
dest = 'C:\ubuntueswin\FolderSystem2\basicImages\';
blabla = 'FonetikaUS_CSTG_';

for i= 1:30
    szam = sprintf('%04d', i);
    folder = strcat(blabla, szam, '_jpg');
    SOURCE = strcat(source, folder, '\*.jpg');
    
    DEST = strcat(dest, 'Subject', num2str(i+27));
    copyfile(SOURCE, DEST);
    
    
end