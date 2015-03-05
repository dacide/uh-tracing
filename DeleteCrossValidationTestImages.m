function [] = DeleteCrossValidationTestImages( SystemFolder )
    crossValTestFolder = SystemFolder.GetCrossValFolderPath();
    subFolderNumber = GetFolderNumber(crossValTestFolder);
    for i = 1 : subFolderNumber
        subFolderPath = SystemFolder.GetCrossValNthFolderPath(i);
        rmdir(subFolderPath,'s');
    end
end

function subFolderNumber = GetFolderNumber(folderPath)
    d = dir(folderPath);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];
    subFolderNumber = length(nameFolds);
end
