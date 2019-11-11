function TASH_cluster(side,D)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% things to change before running the script
subjectsID = TASH_DefineSubjects;
suff1 = '_Complete'; %'_Complete';% %suff = ''; for first half
suff2 = '_Complete'; %'_Complete';% %suff = ''; for first half
erosion_order_total=2;
expanded = 'LT'; %%LTCI
th_val = 0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
th_string = num2str(th_val);
erosion_dilatation_order=num2str(erosion_order_total);
clear sub_Pos_cluster 

for isub = 1:length(subjectsID)
   clear facesSurface_new Pos_cluster AntPost_cluster sorted_cluster    
   D_load = fullfile(D,subjectsID{isub},'RestrictedFlatPatches');
   D_label = fullfile(D,subjectsID{isub},'label/labelsAtlas2009');

   try
        
     %% load masked curvature file
     fname = fullfile(D_load,[side, '_masked', suff1, '.curv']);
     disp(['loading ', fname])
     [curv_complete, fnum] = read_curv(fname);     
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '.curv']); %CI?
     disp(['loading ', fname])
     [curv, fnum] = read_curv(fname);
     
     %% load surface
     fname = fullfile(D,subjectsID{isub}, 'surf', [side, '.inflated']);
     disp(['loading ', fname])
     [vertexSurface, facesSurface] = read_surf(fname);    
     facesSurface = facesSurface+1;
     
         
     %% find the vertices that are included in the curvature map
     vtxIdx_complete = find(curv_complete<0);
     
     vtxIdx = find(curv<0);
     vtx_curv = zeros(size(curv,1),1);
     for vtx=1:size(vtxIdx,1)
        vtx_curv(vtxIdx(vtx))=vtx;
     end
     f_pos=0;
     for face=1:size(facesSurface,1)
        v_pos=0;
        f_pos=f_pos+1;
        for vertex_face=1:3
            if curv(facesSurface(face,vertex_face))<0
                v_pos=v_pos+1;
                facesSurface_new{f_pos}(v_pos) = facesSurface(face,vertex_face);
            end
        end
        if v_pos<2
          clear facesSurface_new{f_pos};
          f_pos=f_pos-1; 
        end
     end
     
     vertex_connectivity=zeros([size(vtxIdx,1) size(vtxIdx,1)]);

     for face=1:size(facesSurface_new,2)
        try
        vertex_connectivity(vtx_curv(facesSurface_new{face}(1)),vtx_curv(facesSurface_new{face}(2)))=1;
        vertex_connectivity(vtx_curv(facesSurface_new{face}(2)),vtx_curv(facesSurface_new{face}(1)))=1;
        vertex_connectivity(vtx_curv(facesSurface_new{face}(1)),vtx_curv(facesSurface_new{face}(3)))=1;
        vertex_connectivity(vtx_curv(facesSurface_new{face}(2)),vtx_curv(facesSurface_new{face}(3)))=1;
        vertex_connectivity(vtx_curv(facesSurface_new{face}(3)),vtx_curv(facesSurface_new{face}(1)))=1;
        vertex_connectivity(vtx_curv(facesSurface_new{face}(3)),vtx_curv(facesSurface_new{face}(2)))=1;  
        catch
        end
     end
     
     clustered=zeros(size(vtxIdx,1),1)+1000000;
     for iturns=1:10
     cluster_num=0;
     for vtx1=1:size(vtxIdx,1)
         cluster_num=cluster_num+1;
         for vtx2=1:size(vtxIdx,1)
             if vertex_connectivity(vtx1,vtx2)==1
                 clustered(vtx1)=min(clustered(vtx1),clustered(vtx2));
                 clustered(vtx1)=min(clustered(vtx1),cluster_num);
                 clustered(vtx2)=clustered(vtx1);
                 %for
             end
         end
     end
     end
     
     ic=0;
     for vtx=1:size(vtxIdx,1)-99
         this_cluster = find(clustered==vtx);
         if length(this_cluster)>99
             ic=ic+1;
             cluster{ic}=vtxIdx(this_cluster);
         end
     end
     
     Ant_complete=min(vertexSurface(vtxIdx_complete,2));
     Post_complete=max(vertexSurface(vtxIdx_complete,2));
     for this_cluster=1:ic
        vertices=cluster{this_cluster};
        AntPost_cluster(this_cluster,1)=min(vertexSurface(vertices,2));
        Pos_cluster(this_cluster,:)=mean(vertexSurface(vertices,:),1);
     end
     sub_Pos_cluster{isub}=Pos_cluster;
     
     [t1,t2]=sort(Pos_cluster(:,2),'descend');
     Pos_sorted_cluster=Pos_cluster(t2,:);
     for this_cluster=1:ic
         sorted_cluster{this_cluster}=cluster{t2(this_cluster)};
     end
     
     for this_cluster=2:ic
 %%%%cutting point        
        if Pos_cluster(this_cluster,2)>=(Ant_complete+Post_complete)/2
           ic = this_cluster-1;
           break
        end
     end
     
             
     curv_g=zeros(size(curv,1),ic);
     for this_cluster=1:ic     
        curv_g(sorted_cluster{this_cluster},this_cluster)=curv(sorted_cluster{this_cluster});
     end
           
     %%%%%%Writing files
     
  for this_cluster=1:ic
     curv=curv_g(:,this_cluster);
     g_num=num2str(this_cluster);
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '_1halfnew_g', g_num, '.curv']);
     disp(['saving ', fname]);
     write_curv(fname, curv,fnum);
     
     Curv_w = curv(curv~=0);
     vcurv_index = find(curv~=0)-1;
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '_1halfnew_g', g_num, '.w']);
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
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '_1halfnew_g', g_num, '.label']);
     fid = fopen(fname,'w');
     fprintf(fid, '# \n %d \n', NumTotalVertex);
     teste=0;
     for i=1:NumTotalVertex
         ThisVertexNum = vcurv_index(i);
         [Lia,Locb] = ismember(ThisVertexNum,VertexNum);
         if Lia == 1
            teste=teste+1;
            ThisVertexPos = VertexPos(Locb,:);
            ThisVertexVal = VertexVal(Locb);
            fprintf(fid,'%d %.3f %.3f %.3f %.10f \n', [ThisVertexNum ThisVertexPos ThisVertexVal]');
         end
     end
     fclose(fid);
     disp(['saved ', fname]);
     
  end
  
     curv=sum(curv_g,2);
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '_1halfnew_g_all.curv']);
     disp(['saving ', fname]);
     write_curv(fname, curv,fnum);
     
     Curv_w = curv(curv~=0);
     vcurv_index = find(curv~=0)-1;
     
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '_1halfnew_g_all.w']);
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
     fname = fullfile(D_load,[side, '_masked_thr0', th_string(3:end), suff1, '_expanded', expanded, suff2, '_erosion_dilatation_', erosion_dilatation_order, '_1halfnew_g_all.label']);
     fid = fopen(fname,'w');
     fprintf(fid, '# \n %d \n', NumTotalVertex);
     teste=0;
     for i=1:NumTotalVertex
         ThisVertexNum = vcurv_index(i);
         [Lia,Locb] = ismember(ThisVertexNum,VertexNum);
         if Lia == 1
            teste=teste+1;
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