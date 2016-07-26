
ImagePath = '3.jpg';
Img = im2double(imread(ImagePath));
[Hei Wid Dim] = size(Img);
maxSize = 80;
if Hei<=Wid
    Hei = floor(Hei*maxSize/Wid);
    Wid = maxSize;
else
    Wid = floor(Wid*maxSize/Hei);
    Hei = maxSize;
end
Img = imresize(Img,[Hei Wid], 'bilinear');
SMap = zeros(Hei,Wid);

%% Compute all single scale saliency maps
for ScaleID = 0:3
    TMap = SGPDetection(Img, [Hei Wid], 1+2*ScaleID);
    TMap = imresize(TMap, [Hei Wid], 'bilinear');
    imwrite(TMap,['TMAP_' int2str(ScaleID*2+1) '.jpg']);
    Kur(ScaleID+1) = kurtosis(TMap(:));
    TTMap(:,:,ScaleID+1) = TMap/max(TMap(:));
end
Kur = abs(Kur)/sum(sum(abs(Kur)));

%% Get the fused Multiscale Saliency Map - SMap
for ScaleID = 0:3
    SMap = SMap + TTMap(:,:,ScaleID+1); 
end

%% Here we show all singel scale and the fused multiscale saliency maps
ShowMap = [];
for ScaleID = 0:3
    ShowMap =  [ ShowMap TTMap(:,:,ScaleID+1)];   
end
ShowMap =  [ ShowMap SMap / max(SMap(:))];
figure(1),subplot(2,1,1),imshow(Img);
figure(1),subplot(2,1,2),imshow(ShowMap),colormap('jet');
pause(0.0001);


%% Here we use 4 colors to show the dominant scale 
ShowMap = zeros([Hei Wid 3]);
for m = 1:Hei
    for n = 1:Wid 
        MaxID = 1;
        MaxT = 0;
        for ID = 1:4
            if MaxT< TTMap(m,n,ID)
                MaxT = TTMap(m,n,ID);
                MaxID = ID;
            end
        end
        if MaxT>0.6
            switch MaxID
                case 1
                    ShowMap(m,n,:) = [1 0 0];
                case 2
                    ShowMap(m,n,:) = [0 1 0];
                case 3
                    ShowMap(m,n,:) = [0 0 1];
                case 4
                    ShowMap(m,n,:) = [1 1 0];  
            end
        end
    end
end
figure(2),subplot(2,1,1),imshow(Img);
figure(2),subplot(2,1,2),imshow(ShowMap); colormap('jet');
pause(0.0001);
