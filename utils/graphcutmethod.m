function GClabels = graphcutmethod(Data_scaled,Label,prob_estimatesM)

[H, W, B] = size(Data_scaled);
nPixels = H * W;
nclasses = length(unique(Label(:)))-1;

%% Graph cut
% an object is created with npixels and their nclasses as labels
h = GCO_Create(nPixels,nclasses);

% potential determines which pixel has which strong potential label(the lesser the vale the more stronger the label)
potentials = int32(double(20000.0.*(-log(prob_estimatesM)))');

% determines pixels potential(likelihood) towards the respective classes .... weights to t-links
GCO_SetDataCost(h, potentials);

% the interactivness or the liklihood of a pixel with other pixels
interactions = sparse(nPixels, nPixels);

% compute interactions

currindex = 1;

for ind_width = 1:W
    for ind_height = 1:H % for a particular pixel position
        %indexes of 4 neighbors
        index4 = currindex + 1;
        index2 = currindex + H;
        index1 = index2 - 1;
        index3 = index2 + 1;
        %the 4 neighbourhood positions are
        indw1 = ind_width+1; indw2 = indw1; indw3 = indw2; indw4 = ind_width;
        indh1 = ind_height - 1; indh2 = ind_height; indh3 = ind_height + 1; indh4 = indh3;
        
        
        currvector = reshape(Data_scaled(ind_height, ind_width,:),B,1);% current pixel's band information is taken out in the currvector
        
        %neighbors 1-3
        if (indw1 < W)
            %neighbor 1
            if (indh1 > 0)% if indh1 is less then 0 then the current pixel lies in the first row
                currweight = 0;
                sum_currvec =0;sum_scaledvec=0;
                P=0;
                Q=0;
                for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                    sum_currvec = sum_currvec + abs(currvector(ind_band)) ;
                    sum_scaledvec = sum_scaledvec + abs(Data_scaled(indh1, indw1, ind_band));
                end %for ind_band = 1:B
                for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                    P = abs(currvector(ind_band))/(sum_currvec);
                    Q = abs(Data_scaled(indh1, indw1, ind_band))/sum_scaledvec;
                    currweight = currweight + (P*log2(P/Q) + Q*log2(Q/P));
                    
                end %for ind_band = 1:B
                %currweight = acos (double(num_SAM/(sum_currvec*sum_scaledvec)));
                
                currweight = 15000*exp(-(currweight)/((double(B))));%corelation gaussian
                interactions(currindex, index1) = int32(currweight);% updating the interaction matrix with the calculated weights with ts first neighbour
                interactions(index1, currindex) = int32(currweight);% maintaining the symmetricity of the matrix
            end %if (indh1 > 0)
            
            
            
            %neighbor2
            currweight = 0;
            sum_currvec =0;sum_scaledvec=0;
            P=0;Q=0;
            for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                sum_currvec = sum_currvec + abs(currvector(ind_band)) ;
                sum_scaledvec = sum_scaledvec + abs(Data_scaled(indh2, indw2, ind_band));
            end %for ind_band = 1:B
            for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                P = abs(currvector(ind_band))/(sum_currvec);
                Q = abs(Data_scaled(indh2, indw2, ind_band))/sum_scaledvec;
                currweight = currweight + (P*log2(P/Q) + Q*log2(Q/P));
                
            end %for ind_band = 1:B
            
            currweight = 15000*exp(-(currweight)/((double(B)))); % same updatation as above
            interactions(currindex, index2) = int32(currweight);
            interactions(index2, currindex) = int32(currweight);
            
            if (indh3 <= H)% only check for the row number with in case if the current pixel is the pixel in the last row
                currweight = 0;
                sum_currvec = 0; sum_scaledvec = 0;
                P = 0; Q = 0;
                for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                    sum_currvec = sum_currvec + abs(currvector(ind_band)) ;
                    sum_scaledvec = sum_scaledvec + abs(Data_scaled(indh3, indw3, ind_band));
                end %for ind_band = 1:B
                for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                    P = abs(currvector(ind_band))/(sum_currvec);
                    Q = abs(Data_scaled(indh3, indw3, ind_band))/sum_scaledvec;
                    currweight = currweight + (P*log2(P/Q) + Q*log2(Q/P));
                end %for ind_band = 1:B
                
                currweight = 15000*exp(-(currweight)/((double(B))));
                interactions(currindex, index3) = int32(currweight);
                interactions(index3, currindex) = int32(currweight);% same as above
            end %if (indh1 > 0)
            
        end %if (indw1 < W)
        
        if (indh4 <= H)
            currweight = 0;
            sum_currvec =0;sum_scaledvec=0;
            P=0;Q=0;
            for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                sum_currvec = sum_currvec + abs(currvector(ind_band)) ;
                sum_scaledvec = sum_scaledvec + abs(Data_scaled(indh4, indw4, ind_band));
            end %for ind_band = 1:B
            for ind_band = 1:B % takes the total relationship with its first neighbour with taking all bands into consideration
                P = abs(currvector(ind_band))/(sum_currvec);
                Q = abs(Data_scaled(indh4, indw4, ind_band))/sum_scaledvec;
                currweight = currweight + (P*log2(P/Q) + Q*log2(Q/P));
                
            end %for ind_band = 1:B
            %currweight = acos (double(num_SAM/(sum_currvec*sum_scaledvec)));
            currweight = 15000*exp(-(currweight)/((double(B))));
            interactions(currindex, index4) = int32(currweight);
            interactions(index4, currindex) = int32(currweight);
        end %if (indh4 <= H) % same as neighbour3
        
        currindex = currindex+1;
        
    end %for ind_height = 1:H
end %for ind_width = 1:W


GCO_SetNeighbors(h, interactions);%connected weights are applied representing the pixels relationship in the graph

GCO_Expansion(h); % application of the alpha expansion algorithm for computing the optimized labelling

GClabels = GCO_GetLabeling(h);%obtaining the optimized labeling

GClabels = reshape(GClabels,H,W);%transforming the labeling array into a matrix of H*w size

GCO_Delete(h);% the graph is deleted here