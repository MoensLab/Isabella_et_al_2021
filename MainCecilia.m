function T=MainCecilia(lsmfile)

fname=lsmfile(1:end-4); %removing the last 4 characters
[~,~,ext]=fileparts(lsmfile); %get file extension

pname=strcat(fname,"_graph");

%% Create green and red stacks

if strcmp(ext,'.lsm') %Case lsm file
    IS=bfopen(lsmfile); %load images from BioFormat
    
    s=IS{1,1}{1,2};
    c=str2double(s(end)); %determine how many channels
    

    if c==3
        Gstack=cat(3,IS{1,1}{1:3:end,1});
        Rstack=cat(3,IS{1,1}{3:3:end,1});
    else
        Gstack=cat(3,IS{1,1}{1:2:end,1});
        Rstack=cat(3,IS{1,1}{2:2:end,1});
    end
    
elseif strcmp(ext,'.tif') %case tif hyperstack
    nIm=numel(imfinfo(lsmfile)); %get total number of images
    nChannels=2; %assuming 2 channels
    nZ=nIm/nChannels; %determine number of z-stacks
    I=imread(lsmfile,1); %grab first image to get size;
    Gstack=uint8(zeros([size(I) nZ])); %Preallocate Gstack assuming 8bit
    Rstack=uint8(zeros([size(I) nZ])); %Preallocate Rstack assuminng 8bit
    count=1;
    for j=1:2:nIm %loop thru all the images and distribute them (order of images is z1/C1, z1/C2, z2/C1, z2/C2 etc...)
        Gstack(:,:,count)=imread(lsmfile,j);
        Rstack(:,:,count)=imread(lsmfile,j+1);
        count=count+1;
    end
end

%% flip orientation of some images
% if contains(fname,'deadend')
%     Gstack=fliplr(Gstack);
%     Rstack=fliplr(Rstack);
% end

%% ma projection
Gp=max(Gstack,[],3);
Rp=max(Rstack,[],3);

%% Measure relative length of green Kaede domain
Tg=graythresh(Gp); %find global threshold
GW=imbinarize(Gp,Tg*0.5); %binarize Green - May need adjustment
h=fspecial('average',4); % smoothing
GWf=imfilter(GW,h);      %smoothing
GWfa=bwareaopen(GWf,50); %remove small objects less than 50 pixels
sumGW=sum(GWfa,1); %sum columns to find start and finish of Green signal
%figure, imshow(GWfa)
idx=find(sumGW);
X0=idx(1);XL=idx(end); %Get X0 and Xend

%% Segment the red Kaede signal for each Z-stack

RWstack=false(size(Rstack)); %Preallocation of segmented z-stack

nZ=size(Rstack,3); %get the number of z-stacks
% loop thru the z-stack
for i=1:nZ
    G=Gstack(:,:,i);
    R=Rstack(:,:,i);
    RWstack(:,:,i)=CeciliaSegment(G,R,1); %segment the red channel
end

RWs=sum(RWstack,3); %create a sum projection thru z-stacks
%figure, imshow(RWs,[]);
RWdist=sum(RWs,1); %count number of positive pixels per column

Xmax=XL-X0; %measure length of the green domain in pixels
Xref=(0:Xmax)/Xmax; %relative length of the domain

YR=cumsum(RWdist(X0:XL)); %get the cumulative sum of red pixels
YRrel=YR./YR(end); %normalize to 1- cumulative density of red kaede
YG=cumsum(sumGW(X0:XL)); %same with green channel- beware it's done only on max projection- may need to process green the same way as red
YGrel=YG./YG(end); %cumulative density of green kaede

%% gathering the data and plotting

T=[Xref',YGrel',YRrel',YG',YR',(YRrel-YGrel)']; %concatenating data
T=array2table(T,'VariableName',{'Xap','CumDens_Green','CumDens_Red','CumInt_Green','CumInt_Red','Diff'}); %create table
%
figure;set(gcf,'Color','w');
pos1=[0.15 0.7 0.3 0.3];
pos2=[0.5 0.7 0.3 0.3];
pos3=[0.15 0.4 0.3 0.3];
pos4=[0.5 0.4 0.3 0.3];
pos5=[0.15 0.08 0.65 0.3];

ax1=subplot('Position',pos1);imagesc(Gp);colormap(ax1,gray);axis off;
ax2=subplot('Position',pos2);imagesc(Rp);colormap(ax2,gray);axis off;
ax3=subplot('Position',pos3);imagesc(GWfa);colormap(ax3,parula);axis off;
ax4=subplot('Position',pos4);imagesc(RWs);colormap(ax4,parula);axis off;

ax5=subplot('Position',pos5); plot(Xref,YGrel,'-','Color',[0.4667 0.6745 0.1882],'Linewidth',2);hold on;
plot(gca,Xref,YRrel,'-','Color',[0.8510 0.3255 0.0980],'Linewidth',2);
%blue color: 0    0.4471    0.7412;
xlabel('AP axis');
ylabel('Kaede density')
%axis square
set(gcf,'Position',[500 500 1000 500]);
text(0.5,0.2,fname,'Interpreter','none','FontSize',16,'Fontweight','bold');
print(pname,'-dpdf','-bestfit'); %save the graph in pdf


%%THIS SECTION WRITTEN BY ADAM
tname=strcat(fname, "_table.xlsx");
writetable(T,tname); %saves the table of concatenated data as excel file.
