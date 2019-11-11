function TASH_opening(side,D)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% things to change before running the script
subjectsID = TASH_DefineSubjects;
suff = '_Complete'; %'_Complete';% %suff = ''; for first half
erosion_order_total=2;
dilatation_order_total=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
erosion_dilatation_order=num2str(erosion_order_total);

for isub = 1:length(subjectsID)
    
   D_load = fullfile(D,subjectsID{isub},'RestrictedFlatPatches');

   try
        
     %% load masked curvature file
     %%fname = fullfile(D_load,[side, '_masked', suff, '_LT_CI.curv']); %CI?
     fname = fullfile(D_load,[side, '_masked', suff, '_LT.curv']); %CI?
     disp(['loading ', fname])
     [curv, fnum] = read_curv(fname);
     
     %% load surface
     fname = fullfile(D,subjectsID{isub}, 'surf', [side, '.inflated']);
     disp(['loading ', fname])
     [vertexSurface, facesSurface] = read_surf(fname);    
     facesSurface = facesSurface+1;
     
         
     %% find the vertices that are included in the curvature map
     vtxIdx = find(curv>0);
     curv(vtxIdx) = 0;
     vtxIdx = find(curv<0);
         
     %% find the faces which contains the selected vertices
     facesSurface_new = facesSurface;
     for ii = 1:3
         temp = ismember(facesSurface(:,ii),vtxIdx);
         facesSurface_new(~temp,ii) = 0;
         clear temp
     end      
     facesSurface_final = facesSurface_new;
     facesSurface_final(sum(facesSurface_new,2)==0,:) = [];      
     idxFaces = find(~(sum(facesSurface_new,2)==0));
 
     facesSurface_erosion=zeros(size(facesSurface_final,1),size(facesSurface_final,2),erosion_order_total+1);
     facesSurface_erosion(:,:,1)=facesSurface_final;  
     for erosion_order=1:erosion_order_total
         facesSurface_erosion(:,:,erosion_order+1)=facesSurface_erosion(:,:,erosion_order);
         for ii = 1:size(facesSurface_final,1)       
            thisFace = facesSurface_erosion(ii,:,erosion_order);        
            if ~isempty(find(thisFace==0)) %%%%%%%%%%%% modification by josue on 22/11/2016 %%%% length(find(thisFace==0))==2
                temp = find(thisFace~=0);
                for jj = 1:size(temp,2)
                    exclude=thisFace(temp(jj));
                    for iii= 1:size(facesSurface_final,1)
                        for jjj= 1:size(facesSurface_final,2)
                            if facesSurface_erosion(iii,jjj,erosion_order+1) == exclude
                                facesSurface_erosion(iii,jjj,erosion_order+1) = 0;
                            end
                        end
                    end
                end
            else
                continue
            end
         end            
     end
     
     facesSurface_dilatation=zeros(size(facesSurface_final,1),size(facesSurface_final,2),dilatation_order_total+1);
     facesSurface_dilatation(:,:,1)=facesSurface_erosion(:,:,erosion_order+1);
     for dilatation_order=1:dilatation_order_total
         facesSurface_dilatation(:,:,dilatation_order+1)=facesSurface_dilatation(:,:,dilatation_order);
         for ii = 1:size(facesSurface_final,1)       
            thisFace = facesSurface_dilatation(ii,:,dilatation_order);        
            if ~isempty(find(thisFace~=0))
                temp = find(thisFace==0);
                for jj = 1:size(temp,2)
                    include=facesSurface_erosion(ii,temp(jj),1);
                    for iii= 1:size(facesSurface_final,1)
                        for jjj= 1:size(facesSurface_final,2)
                            if facesSurface_erosion(iii,jjj,1) == include
                                facesSurface_dilatation(iii,jjj,dilatation_order+1) = include;
                            end
                        end
                    end
                end
            end
         end
     end

     
     curv_erosion_dilatation=zeros(size(curv,1),size(curv,2));
     for ii = 1:size(facesSurface_erosion,1)
         thisFace=facesSurface_dilatation(ii,:,dilatation_order_total+1);
         if isempty(find(thisFace==0)) 
             for jj=1:3
                 curv_erosion_dilatation(facesSurface_dilatation(ii,jj,dilatation_order_total+1))=curv(facesSurface_dilatation(ii,jj,dilatation_order_total+1));
             end
         end
     end
     
     curv=curv_erosion_dilatation;
     
     %fname = fullfile(D_load,[side, '_maskedLTCI', suff, '_erosion_dilatation_', erosion_dilatation_order,'.curv']);
     fname = fullfile(D_load,[side, '_maskedLT', suff, '_erosion_dilatation_', erosion_dilatation_order,'.curv']);
     disp(['saving ', fname]);
     write_curv(fname, curv,fnum);
     
     Curv_w = curv(curv~=0);
     vcurv_index = find(curv~=0)-1;
     
     %fname = fullfile(D_load,[side, '_maskedLTCI', suff, '_erosion_dilatation_', erosion_dilatation_order,'.w']);
     fname = fullfile(D_load,[side, '_maskedLT', suff, '_erosion_dilatation_', erosion_dilatation_order,'.w']);
     disp(['saving ', fname]);
     write_wfile(fname, Curv_w, vcurv_index); 
    
  catch     
  end
end

end
 