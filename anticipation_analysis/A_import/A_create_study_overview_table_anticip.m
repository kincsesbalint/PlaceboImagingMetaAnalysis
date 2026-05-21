function A_create_study_overview_table_anticip(intermedpath)
%% Creates an overview table for study-level information
% The table columns added. Where it is necessary, additional explanation
% can be found.
%     {'study_ID'                     }
%     {'datofdatacollection'          }
%     {'study_dir'                    }
%     {'n'                            }
%     {'study_design'                 }
%     {'img_modality'                 }
%     {'field_strength'               }
%     {'TR'                           }
%     {'TE'                           }
%     {'voxel_size_at_acq'            }
%     {'voxel_size_img'               } % for the new studies I checked with fslinfo the shared images dimension and put here.
%     {'slice_timing_correction'      }
%     {'temporal_high_pass_filter'    }
%     {'spatial_smoothing_FWHM'       }
%     {'contrast_imgs_only'           }
%     {'image_type'                   }
%     {'analysis_software'            }
%     {'modeled_stimulus_duration'    }
%     {'stimulus_duration'            }
%     {'modeled_anticipation_duration'}
%     {'painismodeled'                }
%     {'anticipation_duration'        }
%     {'anticipismodeled'             }
%     {'anticip_cueshowed'            } %
%     {'stim_type'                    }
%     {'stim_location'                }
%     {'placebo_form'                 }
%     {'placebo_induction'            }
%     {'contrast_ratings_only'        }
%     {'raw'                          } placeholder for image data-tables, contains the path to the imgs and other important infos.
%     {'excluded_conservative_sample' }
%     {'study_citations'              }
%     {'study_citations_conservative' }
% Added in later steps: 
%     {'placebo'                      } %path to the processed image and some additional info
%     {'control'                      }
%     {'placebo_minus_control'        }
%     {'GIV_stats_rating'             }
%     {'GIV_stats_rating101'          }
%     {'anticip_placebo'              }
%     {'anticip_control'              }
%     {'anticip_placebo_minus_control'}
%     {'modeled_anticipationphase'    }
% 
% 
% 
% 
% It saves the table in the provided (intermedpath) folder path as
% data_frame.mat. This table will be updated with additional columns  in later steps 
% which contains raw image file path, processed img file path, rating values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_ID={
'atlas'
'bingel06'
'bingel11'
'choi'
'eippert'
'ellingsen'
'elsenbruch'
'freeman'
'geuter'
'kessner'
'kong06'
'kong09'
'lui'
'ruetgen'
'schenk'
'theysohn'
'wager04a_princeton'
'wager04b_michigan'
'wrobel'
'zeidan'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_ID2021={
'fehse'
'hartmann'
'meulen'
'schenk17'
'schenk20'
'koban'
    };
study_ID=[study_ID;study_ID2021];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dateofdatacollection=[repmat(2015,length(study_ID)-length(study_ID2021),1);repmat(2021,length(study_ID2021),1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=[
21 %'atlas'
19 %'bingel06'
22 %'bingel11'
15%'choi'
40 %'eippert'
28 %'ellingsen'
36 %'elsenbruch'
24 %'freeman'
40 %'geuter'
39 %'kessner'
10 %'kong06'
12 %'kong09'
31 %'lui'
102 %'ruetgen'
32 %'schenk'
30 %'theysohn'
24 %'wager04a_princeton'
23 %'wager04b_michigan'
38 %'wrobel'
17]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2021=[
30 %     'fehse'
74 % 'hartmann'
30 % 'meulen'
24 % 'schenk2017'
38 % 'schenk2020'
20 %'koban'
];

n=[n;n2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 study_dir={
'Atlas_et_al_2012' %'atlas'
'Bingel_et_al_2006' %'bingel06'
'Bingel_et_al_2011' %'bingel11'
'Choi_et_al_2011' %'choi'
'Eippert_et_al_2009' %'eippert'
'Ellingsen_et_al_2013' %'ellingsen'
'Elsenbruch_et_al_2012' %'elsenbruch'
'Freeman_et_al_2015' %'freeman'
'Geuter_et_al_2013' %'geuter'
'Kessner_et_al_201314' %kessner
'Kong_et_al_2006' %'kong06'
'Kong_et_al_2009' %'kong009'
'Lui_et_al_2010' %'lui'
'Ruetgen_et_al_2015' %'ruetgen'
'Schenk_et_al_2014' %'schenk'
'Theysohn_et_al_2014' %'theysohn'
'Wager_et_al_2004a_Princeton_shock' %'wager04a'
'Wager_et_al_2004b_Michigan_heat' %'wager04b'
'Wrobel_et_al_2014' %'wrobel14'
'Zeidan_et_al_2015'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_dir2021={
'study-Fehse2015'   %     'fehse'
'study-Hartmann2020' % 'hartmann'
'study-Meulen2017' % 'meulen'
'study-Schenk2017' % 'schenk2017'
'study-Schenk2020' % 'schenk2020'
'study-Koban2017' %'koban'
};

study_dir=[study_dir;study_dir2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_design={
'within' %'atlas'
'within' %'bingel06'
'within' %'bingel11'
'within' %'choi'
'within' %'eippert'
'within' %'ellingsen'
'within' %'elsenbruch'
'within' %'freeman'
'within' %'geuter'
'between' %'kessner' (mixed design, but "between-group" in respect to placebo conditioning)
'within' %'kong06'
'within' %'kong09'
'within' %'lui'
'between' %'ruetgen'
'within' %'schenk'
'within' %'theysohn'
'within' %'wager04a_princeton'
'within' %'wager04b_michigan'
'within' %'wrobel'
'within'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_design2021={
'within' % 'fehse'
'within' % 'hartmann'
'within' % 'meulen'
'within' % 'schenk2017' two groups were used here, one with treatment and one with expectation modulation, we only use the the treatment group
'within' % 'schenk2020'
'within' % 'koban'
};

study_design=[study_design;study_design2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_modality={
'fMRI' %'atlas'
'fMRI' %'bingel06'
'fMRI' %'bingel11'
'fMRI' %'choi'
'fMRI' %'eippert'
'fMRI' %'ellingsen'
'fMRI' %'elsenbruch'
'fMRI' %'freeman'
'fMRI' %'geuter'
'fMRI' %'kessner'
'fMRI' %'kong06'
'fMRI' %'kong09'
'fMRI' %'lui'
'fMRI' %'ruetgen'
'fMRI' %'schenk'
'fMRI' %'theysohn'
'fMRI' %'wager04a_princeton'
'fMRI' %'wager04b_michigan'
'fMRI' %'wrobel'
'ASL'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_modality2021={
'fMRI' % 'fehse'
'fMRI' % 'hartmann'
'fMRI' % 'meulen'
'fMRI' % 'schenk2017'
'fMRI' % 'schenk2020'
'fMRI' % 'koban'
};

img_modality=[img_modality;img_modality2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
field_strength=[
1.5 %'atlas'
1.5 %'bingel06'
3.0 %'bingel11'
3.0 %'choi'
3.0 %'eippert'
3.0 %'ellingsen'
1.5 %'elsenbruch'
3.0 %'freeman'
3.0 %'geuter'
3.0 %'kessner'
3.0 %'kong06'
3.0 %'kong09'
3.0 %'lui'
3.0 %'ruetgen'
3.0 %'schenk'
1.5 %'theysohn'
3.0 %'wager04a_princeton'
3.0 %'wager04b_michigan'
3.0 %'wrobel'
3.0]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
field_strength2021=[
3.0 % 'fehse'
3.0 % 'hartmann'
1.5 % 'meulen'
3.0 % 'schenk2017'
3.0 % 'schenk2020'    
1.5 % 'koban'
];
field_strength=[field_strength;field_strength2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPM.xY.RT OR SPM.xX.K.RT
% in msec:
 TR=[
2000 %'atlas'
2600 %'bingel06'
3000 %'bingel11'
3000 %'choi'
2620 %'eippert'
2000 %'ellingsen'
3100 %'elsenbruch'
2000 %'freeman'
2580 %'geuter'
2580 %'kessner'
2000 %'kong06'
2000 %'kong09'
3014 %'lui'
1800 %'ruetgen'
2580 %'schenk'
2400 %'theysohn'
1800 %'wager04a_princeton'
1500 %'wager04b_michigan'
2580 %'wrobel'
4000]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR2021=[
2500 % 'fehse'
1200 % 'hartmann'
2000 % 'meulen'
2580 % 'schenk2017' %the corresponding SPM cell is empty, based on the manuscript
1520 % 'schenk2020'    
2000 % 'koban'
];
TR=[TR;TR2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% did not find in SPM.mat, get from the publication
 TE=[
34 %'atlas'
40 %'bingel06'
30 %'bingel11'
30 %'choi'
26 %'eippert'
30 %'ellingsen'
50 %'elsenbruch'
40 %'freeman'
26 %'geuter'
26 %'kessner'
40 %'kong06'
40 %'kong09'
35 %'lui'
33 %'ruetgen'
26 %'schenk'
26 %'theysohn'
22 %'wager04a_princeton'
20 %'wager04b_michigan'
25 %'wrobel'
12]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TE2021=[
30 % 'fehse'
34 % 'hartmann'
30 % 'meulen'
26 % 'schenk2017'
30 % 'schenk2020'    
40 % 'koban'
];
TE=[TE;TE2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the gap in the z-axis is added to the z direction(eg: Eippert used 2mm
% with 1mm gap-->resolution in the z-axis is 3mm)
voxel_size_at_acq=[
3.5 3.5 4.0 %'atlas'
3.3 3.3 4.0 %'bingel06'
3.5 3.5 3.0 %'bingel11'
3.8 3.8 4.0 %'choi'
2.0 2.0 3.0 %'eippert'
3.0 3.0 3.3 %'ellingsen'
3.8 3.8 3.3 %'elsenbruch'
3.1 3.1 5.0 %'freeman'
2.0 2.0 3.0 %'geuter'
2.0 2.0 3.0 %'kessner'
3.1 3.1 5.0 %'kong06'
3.1 3.1 5.0 %'kong09'
1.9 1.9 3.5 %'lui'
1.5 1.5 2.0 %'ruetgen'
2.0 2.0 2.0 %'schenk'
2.6 2.6 3.0 %'theysohn'
3.8 3.8 5.0 %'wager04a_princeton'
3.0 3.0 4.0 %'wager04b_michigan'
2.0 2.0 3.0 %'wrobel'
3.4 3.4 6.0]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
voxel_size_at_acq2021=[
3.0 3.0 3.33 % 'fehse'
2.2 2.2 2.0  % 'hartmann' 2.1875 is rounded(also in the publication)
3.0 3.0 5.0  % 'meulen' they used 1mm interslice gap
2.0 2.0 3.0  % 'schenk2017' they used 1mm interslice gap
2.0 2.0 2.0  % 'schenk2020'  
3.5 3.5 4.5  % 'koban'
];
voxel_size_at_acq=[voxel_size_at_acq;voxel_size_at_acq2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
voxel_size_img=[
2.0 2.0 2.0 %'atlas'
3.0 3.0 3.0 %'bingel06'
2.0 2.0 2.0 %'bingel11'
2.0 2.0 2.0 %'choi'
2.0 2.0 2.0 %'eippert'
2.0 2.0 2.0 %'ellingsen'
2.0 2.0 2.0 %'elsenbruch'
2.0 2.0 2.0 %'freeman'
2.0 2.0 2.0 %'geuter'
2.0 2.0 2.0 %'kessner'
2.0 2.0 2.0 %'kong06'
2.0 2.0 2.0 %'kong09'
2.0 2.0 2.0 %'lui'
2.0 2.0 2.0 %'ruetgen'
2.0 2.0 2.0 %'schenk'
2.0 2.0 2.0 %'theysohn'
2.0 2.0 2.0 %'wager04a_princeton'
3.75 3.75 5.0 %'wager04b_michigan'
2.0 2.0 2.0 %'wrobel'
2.0 2.0 2.0]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
voxel_size_img2021=[
2.0 2.0 2.0 % 'fehse' based on the shared imgs fslinfo
2.0 2.0 2.0 % 'hartmann' based on the shared imgs fslinfo
2.0 2.0 2.0 % 'meulen' based on the shared imgs fslinfo
1.5 1.5 1.5 % 'schenk2017' based on the shared imgs fslinfo
2.0 2.0 2.0 % 'schenk2020' based on the shared imgs fslinfo 
2.0 2.0 2.0 % 'koban' based on the shared imgs fslinfo, but 3mm based on the publication...
];
voxel_size_img=[voxel_size_img;voxel_size_img2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analysis_software={
'SPM5' %'atlas'
'SPM2' %'bingel06'
'SPM5' %'bingel11'
'FSL' %'choi'
'SPM5' %'eippert'
'FSL' %'ellingsen'
'SPM5' %'elsenbruch'
'SPM8' %'freeman'
'SPM8' %'geuter'
'SPM8' %'kessner'
'SPM2' %'kong06'
'SPM2' %'kong09'
'SPM5' %'lui'
'SPM12' %'ruetgen'
'SPM8' %'schenk'
'SPM8' %'theysohn'
'SPM99' %'wager04a_princeton'
'SPM99' %'wager04b_michigan'
'SPM8' %'wrobel'
'FSL'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analysis_software2021={
'SPM8'  % 'fehse'
'SPM12' % 'hartmann'
'SPM8'  % 'meulen'
'SPM12' % 'schenk2017'
'SPM12' % 'schenk2020'  
'SPM8'  % 'koban'
};
analysis_software=[analysis_software;analysis_software2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slice_timing_correction=[
1 %'atlas'
0 %'bingel06'
1 %'bingel11'
0 %'choi'
1 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
1 %'kessner'
0 %'kong06'
0 %'kong09'
1 %'lui'
1 %'ruetgen'
0 %'schenk'
0 %'theysohn'
1 %'wager04a_princeton'
1 %'wager04b_michigan'
1 %'wrobel'
NaN]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slice_timing_correction2021=[
0 % 'fehse'
1 % 'hartmann'
1 % 'meulen'
1 % 'schenk2017'
1 % 'schenk2020'    
1 % 'koban'
];
slice_timing_correction=[slice_timing_correction;slice_timing_correction2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spatial_smoothing_FWHM=[
8 8 8 %'atlas'
8 8 8 %'bingel06'
8 8 8 %'bingel11'
5 5 5 %'choi'
8 8 8 %'eippert'
5 5 5 %'ellingsen'
9 9 9 %'elsenbruch'
8 8 8 %'freeman'
6 6 6 %'geuter'
8 8 8 %'kessner'
8 8 8 %'kong06'
8 8 8 %'kong09'
4 4 8 %'lui'
6 6 6 %'ruetgen'
6 6 6 %'schenk'
8 8 8 %'theysohn'
6 6 6 %'wager04a_princeton'
9 9 9 %'wager04b_michigan'
8 8 8 %'wrobel'
9 9 9]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spatial_smoothing_FWHM2021=[
8 8 8 % 'fehse'
8 8 8 % 'hartmann'
8 8 8 % 'meulen'
6 6 6 % 'schenk2017'
8 8 8 % 'schenk2020'  
8 8 8 % 'koban'
];
spatial_smoothing_FWHM=[spatial_smoothing_FWHM;spatial_smoothing_FWHM2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the SPM.xX.K.HParam code this (based on the SPM.mat documentationas it is
% the  "low frequency cutoff value" which is the same as high-pass
% filter.)
temporal_high_pass_filter=[
180 %'atlas'
128 %'bingel06'
128 %'bingel11'
50 %'choi'
128 %'eippert'
120 %'ellingsen'
140 %'elsenbruch'
128 %'freeman'
128 %'geuter'
128 %'kessner'
128 %'kong06'
128 %'kong09'
128 %'lui'
128 %'ruetgen'
128 %'schenk'
120 %'theysohn'
128 %'wager04a_princeton'
100 %'wager04b_michigan'
128 %'wrobel'
NaN]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temporal_high_pass_filter2021=[
80  % 'fehse' based on SPM.xX.K
128 % 'hartmann'
128 % 'meulen'
128 % 'schenk2017'
125 % 'schenk2020' based on publication: "high pass filter (0.008 Hz)", but the parameter in the SPM.xX.K is Inf, which assume a "% Inf seconds (i.e. constant term only)" based on SPM
NaN % koban temporal filtering is not mentioned in the publication
];
temporal_high_pass_filter=[temporal_high_pass_filter;temporal_high_pass_filter2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

image_type={
'beta' %'atlas'
'con' %'bingel06'
'beta' %'bingel11'
'beta' %'choi'
'con' %'eippert'
'con' %'ellingsen'
'beta' %'elsenbruch'
'con' %'freeman'
'con' %'geuter'
'beta' %'kessner'
'con' %'kong06'
'con' %'kong09'
'con' %'lui'
'con' %'ruetgen'
'beta' %'schenk'
'beta' %'theysohn'
'con' %'wager04a_princeton'
'beta' %'wager04b_michigan'
'beta' %'wrobel'
'con'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image_type2021={
'con'  % 'fehse' we also have the beta images,but I work with the con as that is the simple mean of two ß images and calculated by the authors(based on SPM)
'beta' % 'hartmann' author rerun the analysis and shared the ß images only
'con'  % 'meulen' author only shared con images
'beta' % 'schenk2017' author shared ß images (and also con images)
'beta' % 'schenk2020' author shared ß images (and also con images)
'con'  % 'koban' " the individual Path a beta images which correspond roughly to the contrast Placebo vs Baseline"
};
image_type=[image_type;image_type2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
contrast_imgs_only=[
0 %'atlas'
0 %'bingel06'
0 %'bingel11'
0 %'choi'
0 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
0 %'kessner'
0 %'kong06'
0 %'kong09'
0 %'lui'
0 %'ruetgen'
0 %'schenk'
0 %'theysohn'
1 %'wager04a_princeton'
0 %'wager04b_michigan'
0 %'wrobel'
1]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
contrast_imgs_only2021=[
0 % 'fehse'
0 % 'hartmann'
0 % 'meulen' no beta images shared but the contrast basically the simple ßimages.
0 % 'schenk2017'
0 % 'schenk2020'    
1 % 'koban'
];
contrast_imgs_only=[contrast_imgs_only;contrast_imgs_only2021];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimulus_duration=[
10 %'atlas'
0.001 %'bingel06'
6 %'bingel11'
15 %'choi'
17 %'eippert'
10 %'ellingsen'
31 %'elsenbruch'
7 %'freeman'
16 %'geuter'
16 %'kessner'
5 %'kong06'
12 %'kong09'
0.005 %'lui'
0.5 %'ruetgen'
20 %'schenk'
16.8 %'theysohn'
6 %'wager04a_princeton'
17 %'wager04b_michigan'
17 %'wrobel'
12]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimulus_duration2021=[
20 % 'fehse'
0.5 % 'hartmann'
20 % 'meulen'
20 % 'schenk2017'
8 % 'schenk2020' 
15 % 'koban' 
];
stimulus_duration=[stimulus_duration;stimulus_duration2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

painismodeled=[
1 % 'atlas'
1 % 'bingel06'
1 % 'bingel11'
1 % 'choi'
1 % 'eippert'
1 % 'ellingsen'
1 % 'elsenbruch'
1 % 'freeman'
1 % 'geuter'
1 % 'kessner'
1 % 'kong06'
1 % 'kong09'
1 % 'lui'
1 % 'ruetgen'
1 % 'schenk'
1 % 'theysohn'
1 % 'wager04a_princeton'
1 % 'wager04b_michigan'
1 % 'wrobel'
1 % 'zeidan'
1 % 'fehse'
1 % 'hartmann'
1 % 'meulen'
1 % 'schenk2017'
1 % 'schenk2020'    
1 % 'koban'
];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the values here are equal to the values which calucalted from the SPM:
% SPM.xY.RT*SPM.Sess(1).U(4).dur if the SPM.xBF.UNITS is 'scans', if it
% says 'secs' simple use the the value here: SPM.Sess(yy).U(xx).dur 
% 
modeled_stimulus_duration={
14.2 %'atlas'
0.0 %'bingel06'
6.0 %'bingel11'
15.0 %'choi'
[10.0, 10.0] %'eippert' early+late 
10.0 %'ellingsen'
31.0 %'elsenbruch'
7.0 %'freeman'
[10.0, 10.0] %'geuter' early+late
[10.0, 10.0] %'kessner' early+late
5.0 %'kong06'
7.0 %'kong09'
0 %'lui'
4.4 %'ruetgen'
20.0 %'schenk'
16.8 %'theysohn'
6.0 %'wager04a_princeton'
20.0 %'wager04b_michigan'
[10.0, 10.0] %'wrobel'
12.0}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modeled_stimulus_duration2021={
16 % fehse - SPM.Sess(1).U(1).dur
1 % 'hartmann' - SPM.Sess(1).U(13).dur
[10.0 10.0]% 'meulen' early+late SPM.Sess(1/2).U(2/3).dur
[10.0 10.0]% 'schenk2017'  early+late SPM.xY.RT is empty, but from publication 2.58*SPM.Sess(2).U(4/5).dur
6 % 'schenk2020' SPM.xY.RT is empty, but from publication 1.52*SPM.Sess(3/4).U(2).dur
15 % 'koban' based on publication
};
modeled_stimulus_duration=[modeled_stimulus_duration;modeled_stimulus_duration2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this show if the participanst were presented with an anticipaiton cue
% during the task and if that was also a cue of placebo or control
% condition
anticip_cueshowed=[
1 %'atlas'  saw a cue (3 s) that provided information about upcoming heat intensity ("Hot" or "Warm”). This was followed by a 7–13 s jittered anticipation period (M ⫽ 10.16 s, SD ⫽ 2.64), and 10 s of noxious stimulation
1 %'bingel06'  the placebo cream was applied to the left hand and in the other to the right hand,... Within each trial, a vocal cue signaled pain on either the right or the left hand(
1 %'bingel11' At the beginning of each run, participants were instructed about the particular experimental condition...the color of the fixation cross switched to red to signal the impending painful stimulus This anticipatory phase was 4 to 8 s long.
1 %'choi' visual cue showed the different conditions, and "Visual cue was presented in 9-s periods before the pain stimulation"
1 %'eippert' different sessions for placebo and control and "At the start of the anticipation phase, a white cross-hair changed color to red, which signaled to the subjects that painful stimula- tion would follow soon.
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
1 %'geuter' white fixation cross which switched color at the beginning of the anticipation phase. The color was different for each condition; red for the control, blue for the strong, and green for the weak placebo. Subjects pressed a button after the fixation cross changed its color and the crosshair turned white again for the remainder of the 5 s anticipation period. 
1 %'kessner' between study design, The anticipation phase began when the white crosshair that was displayed on the computer screen turned into a red crosshair,
0 %'kong06'
0 %'kong09'
1 %'lui' At time 0, volunteers received a visual warning cue, i.e., the black screen they were looking at turned either Red (..Red" trials) or Green ( .Green" trials)....The volunteers had been informed that the Red cue would be followed by a brief painful laser stimulus, whereas the Green cue would be followed by an identical painful stimulus associated to a sub-threshold electric shock, which could induce analgesia (the placebo manipulation).
0 %'ruetgen'
1 %'schenk' Each trial started with a condition cue (3 seconds), which, depending on the experimental condition, indicated whether the subject should expect treatment (E+) or not (E ) in that session. ... anticipation phase, the fixation cross turned red, indicating that the painful stimulus would soon follow
1 %'theysohn' different session for placebo and control condition, and" The cue consisted of a visual signal (i.e., a blinking red cross, which stopped flashing during distensions) that appeared at pseudo-randomized intervals 2–5 scans prior to initiation of balloon distension
1 %'wager04a_princeton' control and palcebo in different sessions and "3-s warning cue—a red or blue spiral icon—that indicated whether the upcoming shock would be intense or mild, respectively... An ensuing anticipation epoch varied between 3 and 12 s" but no info wheather there was any cue during the anticipation phase
1 %'wager04b_michigan'  control and palcebo in different sessions and "The cue was the words "Get ready!" in red letters (1 s duration)." but no info about the ancitipation phase, but on the image it seems to be a ranomd interval between 1-16 sec
1 %'wrobel' control and palcebo in different sessions and "The anticipation phase began when the white crosshair that was displayed on the computer screen turned into a red crosshair, indicating that a painful stimulation would follow shortly. Subjects had to press a button as quickly as possible when the crosshair changed color 
0 %'zeidan'
1 % 'fehse'  control and palcebo in different sessions and "The respective ASA packaging was used for anticipation, and heat application via thermode was indicated by a red dot.
1 % 'hartmann' Each trial began with the written German words "DU" ("YOU", self-trials) or "SIE" ("HER”, other-trials) in either red or blue (for painful or non-painful stimulation, respectively), indicating the target and the intensity of the next stimulation (target cue; 2000 ms). Then, a circle icon in the same color of the word was shown on the hand receiving the next stimulation (hand cue; 2000 ms)...The two cues and the waiting phase can all be described as the anticipation period,
1 % 'meulen' control and placebo in different sessions and "This cross turned red during anticipation, signalling to participants that pain stimulation would soon start, and remained red during pain stimulation. "
1 % 'schenk2017'  Each trial started with a visual cue with a duration of 3–7 s (Fig. 1B). The cue consisted of a green or blue square in the middle of the screen, indicating to the volunteer whether they should expect a reduced or a baseline trial....After the visual cue, volunteers had to rate the ex- pected pain during the subsequent pain stimulation...A red fixation cross indicated that the pain stimulation would follow soon (3–7 s)
1 % 'schenk2020' control and palcebo in different sessions  each trial, a visual cue (green or blue cross) indicated that pain stimulation on the forearm location
0 % 'koban'
];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this is found in the article
anticipation_duration={
[10 16] %'atlas' mean value On each trial, participants saw a cue (3 s) that provided information about upcoming heat intensity ... followed by a 7–13 s jittered anticipation period  (M ⫽ 10.16 s, SD ⫽ 2.64)
[5 7] %'bingel06' vocal cue ( right  or  left ) signaled which hand would be stimulated next via headphones. Five to seven seconds after the cue  four consecutive laser pain stimuli was applied
[4 8] %'bingel11'  color of the fixation cross switched to red to signal the impending painful stimulus. This anticipatory phase was 4 to 8 s long.
9 %'choi' Visual cue was presented in 9-s periods before the pain stimulation (from supplementary), based on the table a 3sec "transition period" was also used
[4 11] %'eippert' anticipation 4-11sec
NaN %'ellingsen'
NaN %'elsenbruch' 
NaN %'freeman'
5 %'geuter'  Each trial started with a fixed anticipation period of 5 s
[4 11] %'kessner' The anticipation phase began when the white crosshair that was displayed on the computer screen turned into a red crosshair, indicating that a painful stimulation would follow shortly. Subjects had to press a button as quickly as possible when the crosshair changed color. After a variable delay...
NaN %'kong06'
NaN %'kong09'
12 %'lui'  At time 0, volunteers received a visual warning cue, i.e., the black screen they were looking at turned either Red (  Red” trials) or Green (‘‘Green” trials). Later (12 s)
NaN %'ruetgen'
5 %'schenk' based on piblication(Fig1B)
[4.8 7.2 9.6 12] %'theysohn'  The cue consisted of a visual signal (i.e., a blinking red cross, which stopped flashing during distensions) that appeared at pseudo-randomized intervals 2–5 scans(based on their TR=2.4s, it is 4.8-12sec)
[3 6 9 12] %'wager04a_princeton' 3,6,9sec or 12 based on image
[1 16] %'wager04b_michigan' 1-16sec with a mean of 9sec
[4 11] %'wrobel' 4-11sec, The anticipation phase began when the white crosshair that was displayed on the computer screen turned into a red crosshair, indicating that a painful stimulation would follow shortly. Subjects had to press a button as quickly as possible when the crosshair changed color. 
NaN}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
anticipation_duration2021={
10 % 'fehse' Each block comprised of a (control) picture (1 seconds),most probably this is a typo as the modeling seems to use 10 sec and also the onset is in every 40sec (the length of the block)
[7 11] % 'hartmann' 7-11sec based on publication+SPM.mat
[4 11] % 'meulen' Each stimulus was preceded by a variable anticipation period of 4-11 seconds based on publication+SPM.mat.
[3 7] % 'schenk2017' 3-7sec
[3 5] % 'schenk2020' a variable delay (3–5s), which after the pain stimulation started
NaN % 'koban' 
};
% modeled_anticipation_duration = [
%     ];
% anticipation_duration = [];
anticipation_duration=[anticipation_duration;anticipation_duration2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

anticipismodeled=[
1 % 'atlas'
1 % 'bingel06'
1 % 'bingel11'
1 % 'choi'
1 % 'eippert'
0 % 'ellingsen'
0 % 'elsenbruch' it was modelled, but fMRI data is not available
0 % 'freeman'
1 % 'geuter'
1 % 'kessner'
0 % 'kong06'
0 % 'kong09'
1 % 'lui'
0 % 'ruetgen'
1 % 'schenk'
1 % 'theysohn'
1 % 'wager04a_princeton'
1 % 'wager04b_michigan'
1 % 'wrobel'
0 % 'zeidan'
1 % 'fehse'
1 % 'hartmann'
1 % 'meulen'
1 % 'schenk2017'
1 % 'schenk2020'    
0 % 'koban'
];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the values here are equal to the values which calucalted from the SPM:
% SPM.xY.RT*SPM.Sess(1).U(4).dur if the SPM.xBF.UNITS is 'scans', if it
% says 'secs' simple use the the value here: SPM.Sess(yy).U(xx).dur
modeled_anticipation_duration={
[10.5 16.5] %'atlas' SPM.xY.RT*SPM.Sess.U(6:9).dur - checking two subjects, it seems the modelled anticipation period is between the sepcified values
0.0 %'bingel06' SPM.xY.RT*SPM.Sess.U(1/3).dur
4.8 %'bingel11' SPM.xY.RT*SPM.Sess(1:4).U(3).dur
NaN %'choi' the FSL design files(txt-s) are shared, but I am not sure how to find out the timing from that...
0.0 %'eippert' SPM.xY.RT*SPM.Sess(1/2).U(1).dur
NaN %'ellingsen'
NaN %'elsenbruch' 
NaN %'freeman'
5.0005 %'geuter' SPM.xY.RT*SPM.Sess(1:4).U(1).dur
[4 11] %'kessner' checking the SPM files: [min(SPM.xY.RT*SPM.Sess(2).U(1).dur) max(SPM.xY.RT*SPM.Sess(2).U(1).dur)] it seems to be between aorund 4 and 11 sec(3.9899   10.9931)
NaN %'kong06'
NaN %'kong09'
12.0560 %'lui' SPM.xY.RT*SPM.Sess(1/2).U(1).dur
NaN %'ruetgen'
5 %'schenk' SPM.xY.RT*SPM.Sess(1:4).U(3).dur
[4.8 7.2 9.6 12] %'theysohn' 2-5 scans, with a TR of 2.4 sec is is an average 8.4. SPM.xY.RT*SPM.Sess(2/3).U(2).dur
NaN %'wager04a_princeton' no info in the shared SPM files(SPM.mat is not sahred)
NaN %'wager04b_michigan' no info in the shared SPM files(SPM.mat is not sahred)
0.0 %'wrobel' SPM.xY.RT*SPM.Sess(1/2).U(2).dur
NaN}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modeled_anticipation_duration2021={
10 % 'fehse', SPM.Sess(1:4).U(2).dur
[7 11] % 'hartmann' 7-11sec based on publication and the SPM information SPM.Sess(1/2).U(5/7).dur
[4 5 6 7 8 9 10 11]  % 'meulen' 4-11 seconds based on publication and the SPM information SPM.Sess(1/2).U(1).dur
[3 7] % 'schenk2017' 3-7sec continously distributed based on publication and the SPM information SPM.Sess(2).U(3/9).dur*2.58(this is the TR based on publication)
[3 5] % 'schenk2020' 3–5s continously distributed based on publication and the SPM information 1.52*SPM.Sess(3/4).U(1).dur
NaN % 'koban' 
};
modeled_anticipation_duration=[modeled_anticipation_duration;modeled_anticipation_duration2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim_type={
'contact heat' %'atlas
'laser' %'bingel06'
'contact heat' %'bingel11'
'electrical' %'choi'
'contact heat' %'eippert'
'contact heat' %'ellingsen'
'rectal distension' %'elsenbruch'
'contact heat' %'freeman'
'contact heat' %'geuter'
'contact heat' %'kessner'
'contact heat' %'kong06'
'contact heat' %'kong09'
'laser' %'lui'
'electrical' %'ruetgen'
'capsaicin & contact heat' %'schenk'
'rectal distension' %'theysohn'
'electrical' %'wager04a_princeton'
'contact heat' %'wager04b_michigan'
'contact heat' %'wrobel'
'contact heat'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim_type2021={
'contact heat' % 'fehse'
'electrical'   % 'hartmann'
'contact heat' % 'meulen'
'contact heat' % 'schenk2017'
'contact heat' % 'schenk2020'
'contact heat' % 'koban' 
};
stim_type=[stim_type;stim_type2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim_location={
'L forearm (v)' %'atlas'
'L & R hand (d)' %'bingel06'
'R calf (d)' %'bingel11'
'L hand (d)' %'choi'
'L forearm (v)' %'eippert'
'L forearm (d)' %'ellingsen'
'C rectal' %'elsenbruch'
'R forearm (v)' %'freeman'
'L forearm (v)' %'geuter'
'L forearm (v)' %'kessner'
'R forearm (v)' %'kong06'
'R forearm (v)' %'kong09'
'L or R foot (d)' %'lui'
'L hand (d)' %'ruetgen'
'L & R forearm (v)' %'schenk'
'C rectal' %'theysohn'
'R forearm (v)' %'wager04a_princeton'
'L forearm (v)' %'wager04b_michigan'
'L forearm (v)' %'wrobel'
'R leg (d)'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim_location2021={
'L forearm (v)' % 'fehse'
'L & R hand (d)' % 'hartmann'
'L forearm (v)' % 'meulen'
'L forearm (v)' % 'schenk2017'
'XX forearm (v or d)'% 'schenk2020' not written in the manuscript, but the image in the publication (Fig1B, shows a right hand stimulation...)
'L forearm (v)' % 'koban' 
};
stim_location=[stim_location;stim_location2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
placebo_form={
'intravenous drip' %'atlas'
'topical cream/gel/patch' %'bingel06'
'intravenous drip' %'bingel11'
'intravenous drip' %'choi'
'topical cream/gel/patch' %'eippert'
'nasal spray' %'ellingsen'
'intravenous drip' %'elsenbruch'
'topical cream/gel/patch' %'freeman'
'topical cream/gel/patch' %'geuter'
'topical cream/gel/patch' %'kessner'
'sham acupuncture' %'kong06'
'sham acupuncture' %'kong09'
'sham TENS' %'lui'
'pill' %'ruetgen'
'topical cream/gel/patch' %'schenk'
'intravenous drip' %'theysohn'
'topical cream/gel/patch' %'wager04a_princeton'
'topical cream/gel/patch' %'wager04b_michigan'
'topical cream/gel/patch' %'wrobel'
'topical cream/gel/patch'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
placebo_form2021={
'pill' % 'fehse'
'topical cream/gel/patch' % 'hartmann'
'topical cream/gel/patch' % 'meulen'
'sham TENS' % 'schenk2017'
'topical cream/gel/patch' % 'schenk2020'    
'nasal spray' % 'koban' 
};
placebo_form=[placebo_form;placebo_form2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
placebo_induction={
'suggestions' %'atlas'
'suggestions & conditioning' %'bingel06'
'suggestions & conditioning' %'bingel11'
'suggestions & conditioning' %'choi'
'suggestions & conditioning' %'eippert'
'suggestions' %'ellingsen'
'suggestions' %'elsenbruch'
'suggestions & conditioning' %'freeman'
'suggestions & conditioning' %'geuter'
'conditioning' %'kessner' >> within group also suggestions, but the between group contrast only involves conditioning differences
'suggestions & conditioning' %'kong06'
'suggestions & conditioning' %'kong09'
'suggestions & conditioning' %'lui'
'suggestions & conditioning' %'ruetgen'
'suggestions' %'schenk'
'suggestions' %'theysohn'
'suggestions' %'wager04a_princeton'
'suggestions & conditioning' %'wager04b_michigan'
'suggestions & conditioning' %'wrobel'
'suggestions & conditioning'}; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
placebo_induction2021={
'suggestions' % 'fehse'
'suggestions & conditioning' % 'hartmann'
'suggestions & conditioning' % 'meulen'
'suggestions & conditioning' % 'schenk2017'
'suggestions(observational)'% 'schenk2020'
'suggestions' % 'koban' 
};
placebo_induction=[placebo_induction;placebo_induction2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is only needed bc of the Wager and Zeidan studies
contrast_ratings_only=[
0 %'atlas'
0 %'bingel06'
0 %'bingel11'
0 %'choi'
0 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
0 %'kessner'
0 %'kong06'
0 %'kong09'
0 %'lui'
0 %'ruetgen'
0 %'schenk'
0 %'theysohn'
1 %'wager04a_princeton'
1 %'wager04b_michigan'
0 %'wrobel'
1]; %'zeidan'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
contrast_ratings_only2021=[
0 %     'fehse'
0 % 'hartmann'
0 % 'meulen'
0 % 'schenk2017'
0 % 'schenk2020' 
0 % 'koban' 
];
contrast_ratings_only=[contrast_ratings_only;contrast_ratings_only2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
excluded_conservative_sample=logical([
0 %'atlas'
0 %'bingel06'
1 %'bingel11' due to fixed testing sequence of placebo and control
0 %'choi'
0 %'eippert'
0 %'ellingsen'
0 %'elsenbruch'
0 %'freeman'
0 %'geuter'
0 %'kessner'
1 %'kong06' due to missing data
0 %'kong09'
0 %'lui'
1 %'ruetgen' due to placebo responder selection
0 %'schenk'
0 %'theysohn'
0 %'wager04a_princeton'
1 %'wager04b_michigan' due to placebo responder selection
0 %'wrobel'
1]); %'zeidan' due to missing subjects and since this is the only ASL study
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
excluded_conservative_sample2021=logical([ ...
1 % 'fehse' due to fixed sequence of placebo and control
0 % 'hartmann' %now we inlcude everyone, so if we keep only the responders then we have to exclude
0 % 'meulen' 
0 % 'schenk2017' no information in the publication, but checkin randomly some subjects SPM.mat, the onset of the different events seem to be randomized.
0 % 'schenk2020' 
1 % 'koban' due to fixed sequence order of placebo and control in the placebo group(control group is not used here)
    ]);
excluded_conservative_sample=[excluded_conservative_sample;excluded_conservative_sample2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_citations={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015:';...
            'Schenk et al. 2015:';...
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:';...
            'Zeidan et al. 2015:';...
            };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
study_citations2021={
'Fehse et al. 2015:';...    % 'fehse'
'Hartmann et al. 2020:';... % 'hartmann'
'Meulen et al. 2017:';... % 'meulen'
'Schenk et al. 2017:';... % 'schenk2017'
'Schenk et al. 2020:';... % 'schenk2020'
'Koban et al. 2017:'; ...% 'koban' 
};
study_citations=[study_citations;study_citations2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_citations_conservative={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:*';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:**';...
            'Kong et al. 2009:';...
            'Lui et al. 2010:';...
            'Ruetgen et al. 2015:***'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:***';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:**';...
            };
  %* excluded due to fixed testing sequence
  %** excluded due to incomplete data-set
  %*** excluded due to pre-selection of placebo responders.        
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  study_citations_conservative2021={
'Fehse et al. 2015:';...    % 'fehse'
'Hartmann et al. 2020:';... % 'hartmann'
'Meulen et al. 2017:';... % 'meulen'
'Schenk et al. 2017:';... % 'schenk2017'
'Schenk et al. 2020:';... % 'schenk2020'
'Koban et al. 2017:'; ...% 'koban' 
};
  study_citations_conservative=[study_citations_conservative;study_citations_conservative2021];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
raw=cell(length(study_ID),1); %placeholder for image data-tables

df=table(study_ID,dateofdatacollection,study_dir,n,study_design,...
      img_modality,field_strength,TR,TE,voxel_size_at_acq,...
      voxel_size_img,slice_timing_correction,temporal_high_pass_filter,spatial_smoothing_FWHM,...
      contrast_imgs_only,image_type,analysis_software,...
      stimulus_duration,painismodeled,modeled_stimulus_duration, ...
      anticip_cueshowed,anticipation_duration,anticipismodeled,modeled_anticipation_duration,...
      stim_type,stim_location,...
      placebo_form, placebo_induction,contrast_ratings_only,...
      raw, excluded_conservative_sample, study_citations,...
      study_citations_conservative);

save(fullfile(intermedpath,'data_frame.mat'), 'df');
end                                         