function SaliencyMap = SaliencyDetection(ImagePath)
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

SMap = SGPDetection(Img, [Hei Wid], 5);
SaliencyMap = SMap/max(SMap(:));

end

