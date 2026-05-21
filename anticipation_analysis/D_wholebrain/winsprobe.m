for phases=1:length(phase) 
    for j = 1:length(consforwinsorizing)
        for i = 1:length(dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})))
            curr_matrix=dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})){i};
            if ~isempty(curr_matrix)
                curr_upper_prctile=prctile(curr_matrix(:),p_high);
                curr_lower_prctile=prctile(curr_matrix(:),p_low);
                winsorized.(strcat(phase(phases) ,consforwinsorizing{j})){i}=(curr_matrix>curr_upper_prctile) + (curr_matrix<curr_lower_prctile);
                curr_matrix(curr_matrix>curr_upper_prctile)=curr_upper_prctile;
                curr_matrix(curr_matrix<curr_lower_prctile)=curr_lower_prctile;
                dfv_masked.(strcat(phase(phases) ,consforwinsorizing{j})){i}=curr_matrix;
            end
        end
    end
end