function TASH_threshold(side,Dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% things to change before running the script
SaveMode = 'c';
suff = '_Complete'; %'_Complete'%'_1tenthAnt15'%;%'_2thirds';%;  %suff = '_halfplus'; for first half %
subjectsID = TASH_DefineSubjects;
th_val = 0.1;  % threshold value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
th_string = num2str(th_val);

for isub = 1:length(subjectsID)     
    %% change these directories for new datasets
    D_load = fullfile(Dir,subjectsID{isub},'RestrictedFlatPatches');
    D_save = fullfile(Dir,subjectsID{isub},'surf');
    D_label = fullfile(Dir,subjectsID{isub},'label/labelsAtlas2009');

    try
     
        %% load curvature file 
            fname = fullfile(D_load,[side, '_masked', suff, '.curv']);
            [curv,fnum] = read_curv(fname);
            
            %% theshold
            new_curv = curv;
            new_curv(curv>-th_val) = 0;
            
            sum_curv_cortex(isub)=sum(curv);
            sum_curv_sulcus(isub)=sum(curv(curv>0));
            sum_curv_gyrus(isub)=sum(curv(curv<0));
            count_cortex(isub)=sum(curv~=0);
            count_sulcus(isub)=sum(curv>0);
            count_gyrus(isub)=sum(curv<0);
            average_cortex(isub)=sum_curv_cortex(isub)./count_cortex(isub);
            average_sulcus(isub)=sum_curv_sulcus(isub)./count_sulcus(isub);
            average_gyrus(isub)=sum_curv_gyrus(isub)./count_gyrus(isub);
            curv_hist(isub,:)=hist(curv(curv~=0),[-10 0]');
            
            fname = fullfile(D_load,[side, '_masked', suff,'_thr0', th_string(3:end), '.curv']);
            disp(['saving ', fname]);
            write_curv(fname, new_curv,fnum);
            
        %else
            
            fname = fullfile(D_load, [side, '_masked', suff, '.w']);
            [w,v] = read_wfile(fname);
            
            %% theshold
            new_w = w;
            new_w(w>-th_val) = 0;
            
            fname = fullfile(D_load, [side, '_masked', suff '_thr0', th_string(3:end), '.w']);
            disp(['saving ', fname]);
            write_wfile(fname, new_w,v);
            
            %%% reading label
            
     VertexNum = [];
     VertexPos = [];
     VertexVal = [];
     fname = fullfile(D_label,[side, '.AC.extended.label']);
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
     
     %% Saving results
     
     vcurv_index = find(new_curv~=0)-1;
     NumTotalVertex=length(vcurv_index);
     fname = fullfile(D_load, [side, '_masked', suff '_thr0', th_string(3:end), '.label']);
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
