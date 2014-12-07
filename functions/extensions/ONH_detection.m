% ONH_detection
% detects the ONH area
function ONH = ONH_detection(V2)

	[l1,l2] = structuretensor3d(V2,7,[3 9 1]*16,{'l1','l2'});


    planar = im2mat((l1 -l2)./(l1+l2));


    ONH = zeros(size(V2));
    for ind = 40:135

        pom = (planar(:,:,ind)>0.5);
    
        a = 1-sum(pom,1)./size(pom,1);
        if nnz(a==1)

            p2 = find(a==1,1,'first');
            k2 = find(a==1,1,'last');

            ONH(:,p2:k2,ind) = 1;
            
       
        end
    end

   clear  p2  k2 p k a pom pom1

end