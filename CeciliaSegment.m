function RWfa=CeciliaSegment(G,R,s)

% this function is used to detect and segment red positive pixels from a
% single z-stack
%Input argument: G- Green channel image
%                R- Red channel image
%                s- adjustor for the global threshold value

%Output argument RWfa- binarized image of R



thresh=minminT(R); %find background value using the mins of maxs approach
Rb=R-thresh; %subtracting background
Rbm=medfilt2(Rb,[5 5]); %denoising using median filtering
Rbmt=imtophat(Rbm,strel('diamond',8)); %background subtraction (equivalent to rolling ball)
Rref=double(Rbmt)./double(G); %normalize to the green signal - may need to remove background in the green channel- beware zero values-
thresh=graythresh(Rref); %find global threshold value
RW=imbinarize(Rref,s*thresh); %binarize the ref image with threshold adjustment (s)
% h=fspecial('average',10);
% RWf=imfilter(RW,h);
RWfa=bwareaopen(RW,5); %remove objects less than a 100 pixels in size
% figure, imshow(R,[])
% figure, imshow(RWfa)

end

function thresvalue=minminT(I)

thresvalue = max([min(max(I,[],1)) min(max(I,[],2))])	 ;

end