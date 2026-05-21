function B_run_all_single_imports_anticip(datapath,datpathnew,intermedpath)
%% This fills the raw column in the data_frame table.
% The raw table is determined by MZ previously, I did not really change it.
% It contains the following columns, explanation is there where it is
% necessary.
%     {'img'                    } %the relative path to the study. This starts with the study folder as the highest level, but it is different for dc2015 and dc2021 as the folders are located basically different places(dc2015-we kept the rogiinal structure, while for the dc2021 we started a new folder).
%     {'study_ID'               }
%     {'sub_ID'                 }
%     {'male'                   }
%     {'age'                    }
%     {'healthy'                }
%     {'pla'                    } % 1-if the image is related to the placebo condition; 0 - control condition
%     {'pain'                   } % 1-if the image is related to the pain phase; 0 - otherwise
%     {'anticipation'           } % 1-if the image is related to the anticipation period; 0 - otherwise
%     {'predictable'            }
%     {'real_treat'             }
%     {'cond'                   } % the humanreadable format of the image condition
%     {'stim_side'              }
%     {'placebo_first'          }
%     {'i_condition_in_sequence'}
%     {'rating'                 } %original values of ratings (different scales from study to study)
%     {'rating101'              } %standardised scales of ratings, value between 0-100
%     {'stim_intensity'         }
%     {'imgs_per_stimulus_block'}
%     {'n_blocks'               }
%     {'n_imgs'                 }
%     {'x_span'                 }
%     {'con_span'               }
% The function sequentially do the loading of the data_frame.mat and fill
% the studies raw column. It is saved after each study.

%   These studies are from the 2015 collection with anticipation.
    Atlas_et_al_2012_anticip(datapath,intermedpath);
    Bingel_et_al_2006_anticip(datapath,intermedpath);
    Bingel_et_al_2011_anticip(datapath,intermedpath);
    Choi_et_al_2011_anticip(datapath,intermedpath);
    Eippert_et_al_2009_anticip(datapath,intermedpath);
    Geuter_et_al_2013_anticip(datapath,intermedpath);
    Kessner_et_al_201314_anticip(datapath,intermedpath);
    Lui_et_al_2010_anticip(datapath,intermedpath);
    Schenk_et_al_2014_anticip(datapath,intermedpath);
    Theysohn_et_al_2014_anticip(datapath,intermedpath);
    Wager_et_al_2004a_princeton_shock_anticip(datapath,intermedpath);
    Wager_et_al_2004b_michigan_heat_anticip(datapath,intermedpath);
    Wrobel_et_al_2014_anticip(datapath,intermedpath);
%   Studies with NO anticipation from the 2015 collection.
    Ellingsen_et_al_2013_anticip(datapath,intermedpath);
    Elsenbruch_et_al_2012_anticip(datapath,intermedpath);
    Freeman_et_al_2015_anticip(datapath,intermedpath);
    Kong_et_al_2006_anticip(datapath,intermedpath);
    Kong_et_al_2009_anticip(datapath,intermedpath);
    Ruetgen_et_al_2015_anticip(datapath,intermedpath);
    Zeidan_et_al_2015_anticip(datapath,intermedpath);
%   Studies from the collection of 2021 with anticipation.
    Fehse_et_al_2015_anticip(datpathnew,intermedpath);
    Hartmann_et_al_2020_anticip(datpathnew,intermedpath);
    Meulen_et_al_2017_anticip(datpathnew,intermedpath);    
    Schenk_et_al_2017_anticip(datpathnew,intermedpath);
    Schenk_et_al_2020_anticip(datpathnew,intermedpath);
%   Studies with NO anticipation from the 2021 collection.
    Koban_et_al_2017_anticip(datpathnew,intermedpath);
end