function TASH_curv(side,Dir)

subjectsID = TASH_DefineSubjects;

for isub = 1:length(subjectsID)
    %% directory where results will be saved --> change for new data
    D_save = fullfile(Dir,subjectsID{isub},'RestrictedFlatPatches');
    if ~isdir(D_save)
        mkdir(D_save);
    end
    
    try 
        suff = 'Complete';
       
        %% find the vertices that correspond to the faces to keep
        vrt_toKeep = [];%%%%%%%%unique(f_index(:));
        
        %% load curvature
        fname = fullfile(Dir,subjectsID{isub}, 'surf', [side '.curv']);
        disp(['loading ', fname]);
        [curv, fnum] = read_curv(fname);

        %% save new curvature file for this ROI                      
         %%%% Adding all complete ROIS
        file_label1=['labelsAtlas2009/', side, '.S_temporal_transverse'];
        file_label2=['labelsAtlas2009/', side, '.G_temp_sup-G_T_transv'];
        file_label3=['labelsAtlas2009/', side, '.G_temp_sup-Plan_tempo'];
        label1 = read_label(subjectsID{isub},file_label1);
        label2 = read_label(subjectsID{isub},file_label2);
        label3 = read_label(subjectsID{isub},file_label3);
        for i_label=1:size(label1,1)
            Curv_thisROI(label1(i_label,1)+1) = curv(label1(i_label,1)+1);
            vrt_toKeep = [vrt_toKeep; label1(i_label,1)+1];
        end
        for i_label=1:size(label2,1)
            Curv_thisROI(label2(i_label,1)+1) = curv(label2(i_label,1)+1);
            vrt_toKeep = [vrt_toKeep; label2(i_label,1)+1];
        end
        for i_label=1:size(label3,1)
            Curv_thisROI(label3(i_label,1)+1) = curv(label3(i_label,1)+1);
            vrt_toKeep = [vrt_toKeep; label3(i_label,1)+1];
        end                
        
            Curv_thisROI = zeros(size(curv));
            Curv_thisROI(vrt_toKeep) = curv(vrt_toKeep);
            
            fname = fullfile(D_save,[side, '_masked_', suff, '.curv']);
            disp(['saving ', fname]);
            write_curv(fname, Curv_thisROI,fnum);
            
            %% load surface
            % get the vertices indices
            Curv_thisROI_w = curv(vrt_toKeep);
            vcurv_index = vrt_toKeep-1;
            
            fname = fullfile(D_save,[side, '_masked_', suff, '.w']); 
            disp(['saving ', fname]);
            write_wfile(fname, Curv_thisROI_w, vcurv_index);     
        
%%% write Expansion mask
        file_label=['labelsAtlas2009/', side, '.Lat_Fis-post'];
        LatFissure_label = read_label(subjectsID{isub},file_label);
        for i_label=1:size(LatFissure_label,1)
            Curv_thisROI(LatFissure_label(i_label,1)+1) = curv(LatFissure_label(i_label,1)+1);
            vrt_toKeep = [vrt_toKeep; LatFissure_label(i_label,1)+1];
        end     
            
            fname = fullfile(D_save,[side, '_masked_', suff, '_LT.curv']);
            disp(['saving ', fname]);
            write_curv(fname, Curv_thisROI, fnum);
            
            Curv_thisROI_w = curv(vrt_toKeep);                     
            vcurv_index = vrt_toKeep-1;
            fname = fullfile(D_save,[side, '_masked_', suff, '_LT.w']); 
            disp(['saving ', fname]);
            write_wfile(fname, Curv_thisROI_w, vcurv_index);         
            
  %%% write 2nd Expansion mask
        file_label=['labelsAtlas2009/', side, '.S_circular_insula_inf'];
        CirInsula_label = read_label(subjectsID{isub},file_label);
        for i_label=1:size(CirInsula_label,1)
            Curv_thisROI(CirInsula_label(i_label,1)+1) = curv(CirInsula_label(i_label,1)+1);
            vrt_toKeep = [vrt_toKeep; CirInsula_label(i_label,1)+1];
        end
                
            fname = fullfile(D_save,[side, '_masked_', suff, '_LT_CI.curv']);
            disp(['saving ', fname]);
            write_curv(fname, Curv_thisROI, fnum);
            
            Curv_thisROI_w = curv(vrt_toKeep);                     
            vcurv_index = vrt_toKeep-1;
            fname = fullfile(D_save,[side, '_masked_', suff, '_LT_CI.w']); 
            disp(['saving ', fname]);
            write_wfile(fname, Curv_thisROI_w, vcurv_index);         
            
     %%% write 3rd Expansion mask       
        file_label=['labelsAtlas2009/', side, '.G_temp_sup-Plan_polar']; %start - plus_josue_22aug17
        sup_plan_polar_label = read_label(subjectsID{isub},file_label);
        for i_label=1:size(sup_plan_polar_label,1)
            Curv_thisROI(sup_plan_polar_label(i_label,1)+1) = curv(sup_plan_polar_label(i_label,1)+1);
            vrt_toKeep = [vrt_toKeep; sup_plan_polar_label(i_label,1)+1];
        end %end - plus_josue_22aug17
        
            fname = fullfile(D_save,[side, '_masked_', suff, '_LT_CI_PP.curv']);
            disp(['saving ', fname]);
            write_curv(fname, Curv_thisROI, fnum);
            
            Curv_thisROI_w = curv(vrt_toKeep);                     
            vcurv_index = vrt_toKeep-1;
            fname = fullfile(D_save,[side, '_masked_', suff, '_LT_CI_PP.w']); 
            disp(['saving ', fname]);
            write_wfile(fname, Curv_thisROI_w, vcurv_index);              
 
   catch       
   end
end

end