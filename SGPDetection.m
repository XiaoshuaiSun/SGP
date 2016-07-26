function SaliencyMap = SGPDetection(OriImg, RSize, Bsize)
%% Load image and parameters
[Hei Wid Dim] = size(OriImg);
% Bsize = 5;        % size of the patch
RStep = 1;        % sampling step length, 1 means dense sampling.
numSaccades = 500; % number of eye-movements
Rsize = floor(Bsize/2);
FilterDim = Bsize*Bsize*Dim;
bins = 255;       % bin number for non-parametric probability estimation.
DHei = RSize(1);        % resized height
DWid = RSize(2);        % resized width

Image = imresize(OriImg, [DHei DWid],'bilinear');
% for grey image
if Dim == 1 
    Img(:,:,1) = OriImg;
    Img(:,:,2) = OriImg;
    Img(:,:,3) = OriImg;
    OriImg = Img;
end
SaliencyMap = zeros(DHei,DWid);
%% Patch based representation
PatchNum = 0;
for m= Rsize+1:RStep: DHei-Rsize
    for n= Rsize+1:RStep: DWid-Rsize
         PatchNum = PatchNum+1;
         patch=Image(m-Rsize: m+Rsize, n-Rsize: n+Rsize,:);  
         mixedsig(:,PatchNum)=reshape(patch,FilterDim,1);   
    end
end
%% Super Gaussian Component Analysis
[ppsig, A, W] = SGCA(mixedsig, numSaccades);
[FeaDim,SampleNum] = size(ppsig);
PatchNum = 0;
%% Obtain all Response Maps
RM = zeros(DHei,DWid,FeaDim);
for k= Rsize+1:RStep: DHei-Rsize
    for l= Rsize+1:RStep: DWid-Rsize
         PatchNum = PatchNum+1;
         patch=Image(k-Rsize: k+Rsize, l-Rsize: l+Rsize,:);  
         RM(k,l,:) = abs(ppsig(:,PatchNum));  
    end
end

for m = 1:FeaDim
    %% Saliency Map
    ppsig(m,:)=ppsig(m,:)-min(min(ppsig(m,:)));
    ppsig(m,:)=ppsig(m,:)/(max(max(ppsig(m,:))));
    histo = hist(ppsig(m,:),bins);   
    ppsig(m,:)= -log(histo(round(ppsig(m,:).*(bins-1)+1))./sum(histo)+0.000001);
    PatchNum = 0;
    for k= Rsize+1:RStep: DHei-Rsize
        for l= Rsize+1:RStep: DWid-Rsize
            PatchNum = PatchNum+1;
            SaliencyMap(k,l) = SaliencyMap(k,l) + ppsig(m,PatchNum);
        end
    end   

end
% SaliencyMap = filter2(fspecial('gaussian',8,4),SaliencyMap);
% SMap = SaliencyMap - min(min(SaliencyMap(Rsize+1:DHei-Rsize,Rsize+2:DWid-Rsize)));
SMap = SaliencyMap - mean(SaliencyMap(:));
SMap(SMap<0) = 0;
SMap = filter2(fspecial('gaussian',5,2),SMap);

SaliencyMap = SMap/max(SMap(:));
% SaliencyMap = SMap; %for better visualization

end

