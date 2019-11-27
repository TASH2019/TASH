function TASH_grow(side,D)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% things to change before running the script
subjectsID = TASH_DefineSubjects;
suff1 = '_Complete'; %suff = ''; for first half
suff2 = '_Complete'; %suff = ''; for first half
expanded = 'LT'; %%LTCI
th_val = 0.1;
erosion_order_total=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
erosion_dilatation_order=num2str(erosion_order_total);
th_string = num2str(th_val);

for isub = 1:length(subjectsID)     
    D_load = fullfile(D,subjectsID{isub},'RestrictedFlatPatches'); 
    D_label = fullfile(D,subjectsID{isub},'label/labelsAtlas2009');

    try

     %% load thresholded curvature file
     fname = fullfile(D_load,[side, '_masked', suff1, '_thr0', th_string(3:end), '.curv']);
     disp(['loading ', fname]);
     [curv,fnum] = read_curv(fname);
     
     %% load masked curvature file
     %fname = fullfile(D_load_average,['lh_AllROIsExpansion_th_0.curv']); % lh_AC_
     %%fname = fullfile(D_load,[side, '_maskedLT', suff2, '_erosion_dilatation_', erosion_dilatation_order, '.curv']);
     fname = fullfile(D_load,[side, '_masked', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '.curv']);
     %fname = fullfile(D_load,[side, '_maskedLatFissure', suff2, '.curv']);
     disp(['loading ', fname])
     [curvMasked, fnum] = read_curv(fname);
     
     %% load surface
     fname = fullfile(D,subjectsID{isub}, 'surf', [side, '.inflated']);
     [vertexSurface, facesSurface] = read_surf(fname);
     
     facesSurface = facesSurface+1;
     
     stopFlag = 1;
     
     while stopFlag
         
         count = 0;
         
         %% find the vertices that are included in the curvature map
         curv = max(curv,curvMasked);
         vtxIdx = find(curv~=0);
         %vtxIdxMasked = find(curvMasked~=0);
         %vtxIdx = intersect(vtxIdx,vtxIdxMasked);
         
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
         
         %% check the neighbours of faces that have only one or two vertices
         for ii = 1:size(facesSurface_final,1)
             
             thisFace = facesSurface_final(ii,:);
             
             if ~isempty(find(thisFace==0))
                 
                 %% find indeces of other vertices that belong to the same face
                 thisVTX = facesSurface(idxFaces(ii),:);
                 temp = find(thisFace==0); 
                 for iVtx = 1:length(temp)
                    if curvMasked(thisVTX(temp(iVtx))) < 0  % include --> ADDed the check that you should include a vertex only if it was included in the ROI!
                         curv(thisVTX(temp(iVtx))) = curvMasked(thisVTX(temp(iVtx)));
                    else
                       count = count+1;
                   end
                 end
             else
                 continue
             end
         end
         
         if count == length(find(facesSurface_final==0));
             stopFlag=0;
         end      
        
     end 
     
     %% Saving results
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '.curv']);
     disp(['saving ', fname]);
     write_curv(fname, curv,fnum);
     
     Curv_w = curv(curv~=0);
     vcurv_index = find(curv~=0)-1;
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '.w']);
     disp(['saving ', fname]);
     write_wfile(fname, Curv_w, vcurv_index);     
     
     VertexNum = [];
     VertexPos = [];
     VertexVal = [];
     fname = fullfile(D_label,[side, '.expansion.label']);
     disp(['loading ', fname]);
     fid = fopen(fname);
     fgetl(fid);
     fgetl(fid);
     NumTotalVertex = textscan(ans,'%d');
     for i=1:NumTotalVertex{1}
        fgetl(fid);
        resp = textscan(ans,'%d %f %f %f %f');
        VertexNum(i) = resp{1};
        VertexPos(i,1) = resp{2};
        VertexPos(i,2) = resp{3};
        VertexPos(i,3) = resp{4};
        VertexVal(i) = resp{5};
     end
     fclose(fid);
     
     NumTotalVertex=length(vcurv_index);
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '.label']);
     fid = fopen(fname,'w');
     fprintf(fid, '# \n %d \n', NumTotalVertex);
     for i=1:NumTotalVertex
         ThisVertexNum = vcurv_index(i);
         [Lia,Locb] = ismember(ThisVertexNum,VertexNum);
         if Lia == 1
            ThisVertexPos = VertexPos(Locb,:);
            ThisVertexVal = VertexVal(Locb);
            fprintf(fid,'%d %.3f %.3f %.3f %.10f \n', [ThisVertexNum ThisVertexPos ThisVertexVal]');
         end
     end
     fclose(fid);
     disp(['saved ', fname]);

    catch   
    end
end
end