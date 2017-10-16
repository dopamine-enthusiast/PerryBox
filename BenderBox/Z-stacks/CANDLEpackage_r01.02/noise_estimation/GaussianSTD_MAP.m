function [HHH,Sig, NsigMAP]=GaussianSTD_MAP(ima,ps)

% Pierrick Coupe - pierrick.coupe@gmail.com
% Brain Imaging Center, Montreal Neurological Institute.
% Mc Gill University
%
% Copyright (C) 2010 Pierrick Coupe

double(ima);
s=size(ima);

if(min(ima(:))<0)
    ima = ima - min(ima(:));
end

% Estimation of the zeros pading size
p(1) = 2^(ceil(log2(s(1))));
p(2) = 2^(ceil(log2(s(2))));
p(3) = 2^(ceil(log2(s(3))));

% Zeros Pading
pad1 = zeros(p(1),p(2),p(3));
pad1(1:s(1),1:s(2),1:s(3)) = ima(:,:,:);

% Wavelet Transform
[af, sf] = farras;
w1 = dwt3D(pad1,1,af);

% Removing region corresponding to zeros pading
tmp = w1{1}{7};
tmp = tmp(1:round((s(1))/2),1:round((s(2))/2),1:round((s(3))/2));
Sig = median(abs(tmp(:)))/0.6745;

sm = size(tmp);


for k = 1:sm(3)
    img2d(:,:) =  tmp(:,:,k);
    img2dp = padarray(img2d,[ps ps],'circular');
    LocalSTD(:,:) = medfilt2(abs(img2dp)/0.6745, [(2*ps+1) (2*ps+1)]);
    NsigMAP(:,:,k) = LocalSTD(ps+1:sm(1)+ps,ps+1:sm(2)+ps);
end



% [x,y,z] = meshgrid(1:sm(2),1:sm(1),1:sm(3));
% [xi,yi,zi] = meshgrid(1:0.5:sm(2)+0.5,1:0.5:sm(1)+0.5,1:0.5:sm(3)+0.5);
% HHH = interp3(x,y,z,NsigMAP,xi,yi,zi);


% Expand input image
for ii=1:s(1)
    for jj=1:s(2)
        for kk=1:s(3)
            
            i = round(ii/2);
            j = round(jj/2);
            k = round(kk/2);
            
            if (i > sm(1)) i=sm(1);
            end
            if (j > sm(2)) j=sm(2);
            end
            if (k > sm(3)) k=sm(3);
            end
            
            HHH(ii,jj,kk)=NsigMAP(i,j,k);
            HHH(ii,jj,kk)=NsigMAP(i,j,k);
        end
    end
end


HHH = HHH(1:s(1),1:s(2),1:s(3));
maph = find(HHH<Sig);
HHH(maph) = Sig;

% k=3;
% N=k^3;
% HHH =(convn(HHH,ones(k,k,k),'same')/N);